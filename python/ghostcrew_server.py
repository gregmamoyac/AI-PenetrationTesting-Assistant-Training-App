#!/usr/bin/env python3
"""
GHOSTCREW RAG Server
A Python server that listens on http://localhost:8090 and provides intelligent responses
based on the GHOSTCREW penetration testing tools corpus.
"""

import json
import re
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse
import logging
from typing import Dict, List, Tuple, Optional
import difflib
from datetime import datetime
import random

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class PenTestingRAG:
    """RAG system for penetration testing tools knowledge"""
    
    def __init__(self):
        self.corpus = self._load_corpus()
        self.tools_index = self._build_index()
        self.categories = self._categorize_tools()
        
    def _load_corpus(self) -> List[Dict]:
        """Load the GHOSTCREW RAG corpus"""
        # This is a simplified version of the corpus - in production, load from file
        corpus_data = [
            {
                "name": "Metasploit Framework",
                "description": "Metasploit is an open-source penetration testing framework with a vast library of exploits, payloads, and post-exploitation modules to simulate real-world attacks and validate vulnerabilities. It supports network, web, and database exploitation.",
                "usage": "Used for identifying and exploiting vulnerabilities in systems, networks, and applications. Automates attack simulations, tests defenses, and generates reports.",
                "key_features": ["Over 4,000 exploit modules", "Payload generation (reverse shells, Meterpreter)", "Post-exploitation for privilege escalation", "Integration with Nmap, Nessus", "Antivirus evasion and phishing wizards"],
                "example_commands": ["msfconsole", "use exploit/windows/smb/ms17_010_eternalblue", "set RHOSTS 192.168.1.100", "set PAYLOAD windows/x64/meterpreter/reverse_tcp", "exploit"],
                "category": "exploitation"
            },
            {
                "name": "Nmap",
                "description": "Nmap is an open-source tool for network discovery and security auditing, used to scan networks, identify hosts, and enumerate services.",
                "usage": "Used for network reconnaissance to map topology, detect vulnerabilities, and integrate with tools like Metasploit.",
                "key_features": ["Port scanning (TCP, UDP, SYN)", "OS and service detection", "Nmap Scripting Engine (NSE)", "Firewall evasion", "Cross-platform"],
                "example_commands": ["nmap -sS 192.168.1.0/24", "nmap -sV -p 1-65535 192.168.1.100", "nmap --script vuln 192.168.1.100"],
                "category": "reconnaissance"
            },
            {
                "name": "Burp Suite",
                "description": "Burp Suite is a platform for web application security testing, offering tools for intercepting and manipulating HTTP/S traffic.",
                "usage": "Used to identify and exploit web vulnerabilities like SQL injection and XSS through manual and automated testing.",
                "key_features": ["Proxy for HTTP/S traffic", "Scanner (Pro version)", "Intruder for brute-forcing", "Repeater for request manipulation", "Spider and Crawler"],
                "example_commands": ["Configure browser proxy to 127.0.0.1:8080", "Use Intruder to brute-force login", "Use Repeater to modify HTTP request"],
                "category": "web_testing"
            },
            {
                "name": "John the Ripper",
                "description": "John the Ripper is a fast password cracker for auditing weak passwords using dictionary, brute-force, and hybrid attacks, supporting multiple hash types.",
                "usage": "Used to crack password hashes from Windows SAM or Unix /etc/shadow files to assess credential security.",
                "key_features": ["Supports MD5, SHA, NTLM", "Dictionary and brute-force modes", "GPU support in pro version", "Customizable wordlists", "Cross-platform"],
                "example_commands": ["john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt", "john --format=nt hash.txt", "john --incremental hash.txt"],
                "category": "password_cracking"
            },
            {
                "name": "Wireshark",
                "description": "Wireshark is a network protocol analyzer for capturing and inspecting network traffic in real-time.",
                "usage": "Used for network reconnaissance and analysis to identify protocols, capture credentials, or detect anomalies.",
                "key_features": ["Real-time packet capture", "Supports multiple protocols", "Filtering and search", "Tshark CLI", "Cross-platform"],
                "example_commands": ["wireshark &", "tshark -i eth0 -f 'tcp port 80'", "tshark -r capture.pcap -Y 'http.request'"],
                "category": "network_analysis"
            },
            {
                "name": "SQLMap",
                "description": "SQLMap automates the detection and exploitation of SQL injection vulnerabilities in web applications.",
                "usage": "Used to identify SQL injection flaws, extract database information, and bypass authentication.",
                "key_features": ["Supports multiple DBMS", "Automated detection", "Data extraction", "WAF bypass", "CLI interface"],
                "example_commands": ["sqlmap -u 'http://192.168.1.100/login.php' --forms", "sqlmap -u 'http://192.168.1.100?id=1' --dbs", "sqlmap -u 'http://192.168.1.100?id=1' -D testdb -T users --dump"],
                "category": "web_testing"
            },
            {
                "name": "Hydra",
                "description": "Hydra is a password cracking tool for brute-forcing network services like SSH, FTP, and HTTP.",
                "usage": "Used to test login credential strength by attempting multiple username-password combinations.",
                "key_features": ["Supports multiple protocols", "Parallelized attacks", "Customizable wordlists", "Cross-platform", "Automation integration"],
                "example_commands": ["hydra -l admin -P /usr/share/wordlists/rockyou.txt 192.168.1.100 ssh", "hydra -L users.txt -P passwords.txt 192.168.1.100 ftp"],
                "category": "password_cracking"
            },
            {
                "name": "Aircrack-ng",
                "description": "Aircrack-ng is a suite of tools for auditing and cracking wireless networks, focusing on WEP and WPA/WPA2.",
                "usage": "Used to capture packets, crack encryption keys, and assess Wi-Fi security.",
                "key_features": ["Packet capture and injection", "Cracks WEP and WPA/WPA2-PSK", "Multiple wireless interfaces", "Tools like Airodump-ng", "Cross-platform"],
                "example_commands": ["airodump-ng wlan0", "aireplay-ng --deauth 10 -a 00:14:22:01:23:45 wlan0", "aircrack-ng -w /usr/share/wordlists/rockyou.txt capture.cap"],
                "category": "wireless"
            },
            {
                "name": "Mimikatz",
                "description": "Mimikatz is a post-exploitation tool for extracting credentials and Kerberos tickets from Windows systems.",
                "usage": "Used to harvest credentials and escalate privileges in Windows environments.",
                "key_features": ["Extracts passwords, NTLM hashes", "Pass-the-hash/ticket", "Kerberos ticket manipulation", "Dumps LSASS memory", "Metasploit integration"],
                "example_commands": ["mimikatz", "sekurlsa::logonpasswords", "sekurlsa::msv", "kerberos::golden /user:admin /domain:example.com /sid:S-1-5-21-123 /krbtgt:abc123"],
                "category": "post_exploitation"
            },
            {
                "name": "Nikto",
                "description": "Nikto is an open-source web server scanner that identifies vulnerabilities, misconfigurations, and outdated software.",
                "usage": "Used for web server reconnaissance to detect insecure files and server issues.",
                "key_features": ["Scans over 6,700 dangerous files", "Checks outdated software", "Identifies misconfigurations", "Supports SSL", "Multiple output formats"],
                "example_commands": ["nikto -h http://192.168.1.100", "nikto -h https://example.com -ssl", "nikto -h 192.168.1.100 -p 80,443"],
                "category": "web_testing"
            }
        ]
        return corpus_data
        
    def _build_index(self) -> Dict[str, List[str]]:
        """Build a searchable index of tools and their keywords"""
        index = {}
        for tool in self.corpus:
            # Index by tool name
            tool_name = tool['name'].lower()
            words = tool_name.split()
            for word in words:
                if word not in index:
                    index[word] = []
                if tool['name'] not in index[word]:
                    index[word].append(tool['name'])
            
            # Index by key features and description words
            description_words = tool['description'].lower().split()
            for word in description_words[:20]:  # Limit to first 20 words
                if len(word) > 3:  # Skip short words
                    if word not in index:
                        index[word] = []
                    if tool['name'] not in index[word]:
                        index[word].append(tool['name'])
        
        return index
    
    def _categorize_tools(self) -> Dict[str, List[str]]:
        """Categorize tools by their primary function"""
        categories = {
            'exploitation': ['Metasploit Framework', 'Social-Engineer Toolkit (SET)', 'BeEF'],
            'reconnaissance': ['Nmap', 'Recon-ng', 'TheHarvester', 'Maltego', 'Amass'],
            'web_testing': ['Burp Suite', 'SQLMap', 'Nikto', 'ZAP (Zed Attack Proxy)', 'W3AF'],
            'password_cracking': ['John the Ripper', 'Hydra', 'Hashcat', 'Medusa'],
            'wireless': ['Aircrack-ng', 'Kismet', 'Wifite'],
            'network_analysis': ['Wireshark', 'Netcat', 'Ettercap'],
            'post_exploitation': ['Mimikatz', 'PowerSploit', 'Empire', 'Responder'],
            'vulnerability_scanning': ['Nessus', 'OpenVAS', 'Nikto'],
            'forensics': ['Cain & Abel', 'YARA']
        }
        return categories
    
    def find_relevant_tools(self, query: str) -> List[Dict]:
        """Find tools relevant to the user's query"""
        query_lower = query.lower()
        words = query_lower.split()
        
        # Track relevance scores
        tool_scores = {}
        
        # Check for exact tool name matches
        for tool in self.corpus:
            tool_name_lower = tool['name'].lower()
            if tool_name_lower in query_lower:
                tool_scores[tool['name']] = 100
            elif any(word in tool_name_lower for word in words):
                tool_scores[tool['name']] = 80
                
        # Check index matches
        for word in words:
            if word in self.tools_index:
                for tool_name in self.tools_index[word]:
                    if tool_name not in tool_scores:
                        tool_scores[tool_name] = 0
                    tool_scores[tool_name] += 20
                    
        # Check category keywords
        category_keywords = {
            'exploit': 'exploitation',
            'scan': 'reconnaissance',
            'web': 'web_testing',
            'password': 'password_cracking',
            'crack': 'password_cracking',
            'wifi': 'wireless',
            'wireless': 'wireless',
            'network': 'network_analysis',
            'post': 'post_exploitation',
            'vulnerability': 'vulnerability_scanning'
        }
        
        relevant_categories = []
        for word in words:
            for keyword, category in category_keywords.items():
                if keyword in word:
                    relevant_categories.append(category)
                    
        # Add tools from relevant categories
        for category in relevant_categories:
            if category in self.categories:
                for tool_name in self.categories[category]:
                    if tool_name not in tool_scores:
                        tool_scores[tool_name] = 0
                    tool_scores[tool_name] += 30
                    
        # Get top tools by score
        sorted_tools = sorted(tool_scores.items(), key=lambda x: x[1], reverse=True)
        top_tools = [name for name, score in sorted_tools[:3] if score > 0]
        
        # Return tool data
        relevant_tools = []
        for tool in self.corpus:
            if tool['name'] in top_tools:
                relevant_tools.append(tool)
                
        return relevant_tools
    
    def generate_response(self, message: str) -> Dict:
        """Generate a response based on the user's message"""
        # Find relevant tools
        relevant_tools = self.find_relevant_tools(message)
        
        # Check for specific query types
        is_how_to = any(phrase in message.lower() for phrase in ['how to', 'how do i', 'how can i'])
        is_what_is = any(phrase in message.lower() for phrase in ['what is', 'what are', 'what\'s'])
        is_command = any(phrase in message.lower() for phrase in ['command', 'example', 'usage'])
        
        # Generate response based on query type and relevant tools
        if not relevant_tools:
            return self._generate_general_response(message)
        
        if is_what_is:
            return self._generate_description_response(relevant_tools[0])
        elif is_how_to:
            return self._generate_howto_response(relevant_tools[0], message)
        elif is_command:
            return self._generate_command_response(relevant_tools[0])
        else:
            return self._generate_recommendation_response(relevant_tools, message)
    
    def _generate_general_response(self, message: str) -> Dict:
        """Generate a general response when no specific tools are found"""
        responses = [
            "I can help you with various penetration testing tools. Try asking about specific tools like Metasploit, Nmap, or Burp Suite, or describe what you're trying to accomplish.",
            "I'm knowledgeable about penetration testing tools and techniques. What specific task are you trying to perform? For example, network scanning, web application testing, or password cracking?",
            "I specialize in penetration testing tools. You can ask me about tools for exploitation, reconnaissance, web testing, password cracking, wireless testing, and more."
        ]
        
        return {
            'bot_response': random.choice(responses),
            'suggested_command': None,
            'command_description': None,
            'category': 'general'
        }
    
    def _generate_description_response(self, tool: Dict) -> Dict:
        """Generate a response describing a tool"""
        response = f"{tool['name']} is {tool['description'].lower()}\n\n"
        response += f"Key features:\n"
        for feature in tool['key_features'][:3]:
            response += f"• {feature}\n"
        
        return {
            'bot_response': response,
            'suggested_command': tool['example_commands'][0] if tool['example_commands'] else None,
            'command_description': f"Basic {tool['name']} command",
            'category': tool.get('category', 'tools')
        }
    
    def _generate_howto_response(self, tool: Dict, message: str) -> Dict:
        """Generate a how-to response for using a tool"""
        response = f"To use {tool['name']}: {tool['usage']}\n\n"
        
        if tool['example_commands']:
            response += "Here are some example commands:\n"
            for i, cmd in enumerate(tool['example_commands'][:3], 1):
                response += f"{i}. `{cmd}`\n"
        
        suggested_cmd = tool['example_commands'][0] if tool['example_commands'] else None
        
        return {
            'bot_response': response,
            'suggested_command': suggested_cmd,
            'command_description': f"Example {tool['name']} usage",
            'category': tool.get('category', 'tools')
        }
    
    def _generate_command_response(self, tool: Dict) -> Dict:
        """Generate a response with command examples"""
        response = f"Here are common {tool['name']} commands:\n\n"
        
        for i, cmd in enumerate(tool['example_commands'][:5], 1):
            response += f"{i}. `{cmd}`\n"
        
        response += f"\n{tool['name']} is commonly used for {tool['usage'].lower()}"
        
        return {
            'bot_response': response,
            'suggested_command': tool['example_commands'][0],
            'command_description': f"Try this {tool['name']} command",
            'category': tool.get('category', 'tools')
        }
    
    def _generate_recommendation_response(self, tools: List[Dict], message: str) -> Dict:
        """Generate a response recommending tools"""
        if len(tools) == 1:
            tool = tools[0]
            response = f"For your query, I recommend {tool['name']}. {tool['description']}\n\n"
            response += f"It's commonly used for {tool['usage'].lower()}"
            
            suggested_cmd = tool['example_commands'][0] if tool['example_commands'] else None
        else:
            response = "Based on your query, here are some relevant tools:\n\n"
            for i, tool in enumerate(tools[:3], 1):
                response += f"{i}. **{tool['name']}**: {tool['description'].split('.')[0]}.\n"
            
            response += "\nWhich tool would you like to know more about?"
            suggested_cmd = tools[0]['example_commands'][0] if tools[0]['example_commands'] else None
        
        return {
            'bot_response': response,
            'suggested_command': suggested_cmd,
            'command_description': f"Example command for {tools[0]['name']}" if tools else None,
            'category': tools[0].get('category', 'tools') if tools else 'general'
        }


class GhostCrewHandler(BaseHTTPRequestHandler):
    """HTTP request handler for the GHOSTCREW RAG server"""
    
    def __init__(self, *args, **kwargs):
        self.rag = PenTestingRAG()
        super().__init__(*args, **kwargs)
    
    def do_POST(self):
        """Handle POST requests"""
        if self.path == '/api.php' or self.path == '/chat':
            self._handle_chat_request()
        else:
            self.send_error(404, "Endpoint not found")
    
    def do_OPTIONS(self):
        """Handle CORS preflight requests"""
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()
    
    def _send_cors_headers(self):
        """Send CORS headers"""
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
    
    def _handle_chat_request(self):
        """Handle chat message requests"""
        try:
            # Read request body
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            # Parse form data or JSON
            if self.headers.get('Content-Type', '').startswith('application/json'):
                data = json.loads(post_data.decode('utf-8'))
                message = data.get('message', '')
                session_id = data.get('session_id', 'welcome')
            else:
                # Parse form data
                parsed_data = parse_qs(post_data.decode('utf-8'))
                message = parsed_data.get('message', [''])[0]
                session_id = parsed_data.get('session_id', ['welcome'])[0]
            
            logger.info(f"Received message: {message} (session: {session_id})")
            
            # Generate response using RAG
            rag_response = self.rag.generate_response(message)
            
            # Create response
            response = {
                'status': 'success',
                'bot_response': rag_response['bot_response'],
                'suggested_command': rag_response['suggested_command'],
                'command_description': rag_response['command_description'],
                'suggestion_id': f"suggest_{datetime.now().timestamp()}",
                'category': rag_response['category'],
                'bot_message_id': f"bot_msg_{datetime.now().timestamp()}"
            }
            
            # Send response
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps(response).encode('utf-8'))
            
            logger.info(f"Sent response for: {message[:50]}...")
            
        except Exception as e:
            logger.error(f"Error handling request: {e}")
            self.send_error(500, f"Internal server error: {str(e)}")
    
    def log_message(self, format, *args):
        """Override to use custom logger"""
        logger.info(f"{self.address_string()} - {format % args}")


def run_server(port=8090):
    """Run the GHOSTCREW RAG server"""
    server_address = ('', port)
    httpd = HTTPServer(server_address, GhostCrewHandler)
    
    logger.info(f"GHOSTCREW RAG Server starting on http://localhost:{port}")
    logger.info("Ready to handle penetration testing queries...")
    logger.info("Press Ctrl+C to stop the server")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("\nShutting down server...")
        httpd.shutdown()


if __name__ == "__main__":
    run_server()