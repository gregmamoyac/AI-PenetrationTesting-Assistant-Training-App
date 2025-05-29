SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

CREATE DATABASE IF NOT EXISTS ghostcrew_admin DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ghostcrew_admin;

CREATE TABLE audit_log (
  id int(11) NOT NULL,
  user_id int(11) DEFAULT NULL,
  action_type enum('login','logout','command_execute','session_start','session_end','chat_message','system_access') NOT NULL,
  action_details longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(action_details)),
  ip_address varchar(45) DEFAULT NULL,
  user_agent text DEFAULT NULL,
  timestamp timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE chatbot_conversations (
  id int(11) NOT NULL,
  user_id int(11) NOT NULL,
  session_id varchar(64) DEFAULT NULL,
  conversation_id varchar(64) NOT NULL,
  parent_message_id int(11) DEFAULT NULL,
  message_type enum('user','bot') NOT NULL,
  message text NOT NULL,
  timestamp timestamp NOT NULL DEFAULT current_timestamp(),
  context_data longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(context_data)),
  response_time decimal(8,3) DEFAULT NULL,
  message_tokens int(11) DEFAULT NULL,
  model_used varchar(50) DEFAULT 'local',
  suggested_command text DEFAULT NULL,
  command_executed tinyint(1) DEFAULT 0,
  rating tinyint(1) DEFAULT NULL,
  flagged tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE chatbot_feedback (
  id int(11) NOT NULL,
  conversation_id varchar(64) NOT NULL,
  message_id int(11) NOT NULL,
  user_id int(11) NOT NULL,
  feedback_type enum('helpful','not_helpful','incorrect','suggestion') NOT NULL,
  feedback_text text DEFAULT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE chatbot_knowledge_base (
  id int(11) NOT NULL,
  category varchar(100) NOT NULL,
  question text NOT NULL,
  answer text NOT NULL,
  keywords text DEFAULT NULL,
  command_example text DEFAULT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  is_active tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO chatbot_knowledge_base (id, category, question, answer, keywords, command_example, created_at, updated_at, is_active) VALUES
(1, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:26:13', '2025-05-29 11:26:13', 1),
(2, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:26:13', '2025-05-29 11:26:13', 1),
(3, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:26:13', '2025-05-29 11:26:13', 1),
(4, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:26:13', '2025-05-29 11:26:13', 1),
(5, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:26:13', '2025-05-29 11:26:13', 1),
(6, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:26:13', '2025-05-29 11:26:13', 1),
(7, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:26:13', '2025-05-29 11:26:13', 1),
(8, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:28:29', '2025-05-29 11:28:29', 1),
(9, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:28:29', '2025-05-29 11:28:29', 1),
(10, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:28:29', '2025-05-29 11:28:29', 1),
(11, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:28:29', '2025-05-29 11:28:29', 1),
(12, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:28:29', '2025-05-29 11:28:29', 1),
(13, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:28:29', '2025-05-29 11:28:29', 1),
(14, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:28:29', '2025-05-29 11:28:29', 1),
(15, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:29:00', '2025-05-29 11:29:00', 1),
(16, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:29:00', '2025-05-29 11:29:00', 1),
(17, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:29:00', '2025-05-29 11:29:00', 1),
(18, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:29:00', '2025-05-29 11:29:00', 1),
(19, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:29:00', '2025-05-29 11:29:00', 1),
(20, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:29:00', '2025-05-29 11:29:00', 1),
(21, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:29:00', '2025-05-29 11:29:00', 1),
(22, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:29:13', '2025-05-29 11:29:13', 1),
(23, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:29:13', '2025-05-29 11:29:13', 1),
(24, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:29:13', '2025-05-29 11:29:13', 1),
(25, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:29:13', '2025-05-29 11:29:13', 1),
(26, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:29:13', '2025-05-29 11:29:13', 1),
(27, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:29:13', '2025-05-29 11:29:13', 1),
(28, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:29:13', '2025-05-29 11:29:13', 1),
(29, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:29:20', '2025-05-29 11:29:20', 1),
(30, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:29:20', '2025-05-29 11:29:20', 1),
(31, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:29:20', '2025-05-29 11:29:20', 1),
(32, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:29:20', '2025-05-29 11:29:20', 1),
(33, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:29:20', '2025-05-29 11:29:20', 1),
(34, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:29:20', '2025-05-29 11:29:20', 1),
(35, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:29:20', '2025-05-29 11:29:20', 1),
(36, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:29:29', '2025-05-29 11:29:29', 1),
(37, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:29:29', '2025-05-29 11:29:29', 1),
(38, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:29:29', '2025-05-29 11:29:29', 1),
(39, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:29:29', '2025-05-29 11:29:29', 1),
(40, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:29:29', '2025-05-29 11:29:29', 1),
(41, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:29:29', '2025-05-29 11:29:29', 1),
(42, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:29:29', '2025-05-29 11:29:29', 1),
(43, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:29:49', '2025-05-29 11:29:49', 1),
(44, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:29:49', '2025-05-29 11:29:49', 1),
(45, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:29:49', '2025-05-29 11:29:49', 1),
(46, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:29:49', '2025-05-29 11:29:49', 1),
(47, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:29:49', '2025-05-29 11:29:49', 1),
(48, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:29:49', '2025-05-29 11:29:49', 1),
(49, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:29:49', '2025-05-29 11:29:49', 1),
(50, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:29:55', '2025-05-29 11:29:55', 1),
(51, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:29:55', '2025-05-29 11:29:55', 1),
(52, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:29:55', '2025-05-29 11:29:55', 1),
(53, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:29:55', '2025-05-29 11:29:55', 1),
(54, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:29:55', '2025-05-29 11:29:55', 1),
(55, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:29:55', '2025-05-29 11:29:55', 1),
(56, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:29:55', '2025-05-29 11:29:55', 1),
(57, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:29:59', '2025-05-29 11:29:59', 1),
(58, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:29:59', '2025-05-29 11:29:59', 1),
(59, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:29:59', '2025-05-29 11:29:59', 1),
(60, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:29:59', '2025-05-29 11:29:59', 1),
(61, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:29:59', '2025-05-29 11:29:59', 1),
(62, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:29:59', '2025-05-29 11:29:59', 1),
(63, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:29:59', '2025-05-29 11:29:59', 1),
(64, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:30:03', '2025-05-29 11:30:03', 1),
(65, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:30:03', '2025-05-29 11:30:03', 1),
(66, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:30:03', '2025-05-29 11:30:03', 1),
(67, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:30:03', '2025-05-29 11:30:03', 1),
(68, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:30:03', '2025-05-29 11:30:03', 1),
(69, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:30:03', '2025-05-29 11:30:03', 1),
(70, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:30:03', '2025-05-29 11:30:03', 1),
(71, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 11:30:09', '2025-05-29 11:30:09', 1),
(72, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 11:30:09', '2025-05-29 11:30:09', 1),
(73, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 11:30:09', '2025-05-29 11:30:09', 1),
(74, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 11:30:09', '2025-05-29 11:30:09', 1),
(75, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 11:30:09', '2025-05-29 11:30:09', 1),
(76, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 11:30:09', '2025-05-29 11:30:09', 1),
(77, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 11:30:09', '2025-05-29 11:30:09', 1);

CREATE TABLE command_log (
  id int(11) NOT NULL,
  session_id varchar(64) NOT NULL,
  user_id int(11) NOT NULL,
  command text NOT NULL,
  output longtext DEFAULT NULL,
  execution_time decimal(10,6) DEFAULT NULL,
  status enum('pending','completed','failed','timeout') DEFAULT 'pending',
  timestamp timestamp NOT NULL DEFAULT current_timestamp(),
  response_timestamp timestamp NULL DEFAULT NULL,
  error_message text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE command_patterns (
  id int(11) NOT NULL,
  pattern varchar(255) NOT NULL,
  category varchar(50) NOT NULL,
  description text NOT NULL,
  suggested_commands text NOT NULL,
  response_template text NOT NULL,
  match_type enum('exact','contains','regex') DEFAULT 'contains',
  priority tinyint(1) DEFAULT 5,
  is_active tinyint(1) DEFAULT 1,
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE command_suggestions (
  id int(11) NOT NULL,
  conversation_id varchar(64) NOT NULL,
  user_id int(11) NOT NULL,
  suggested_command text NOT NULL,
  command_description text DEFAULT NULL,
  priority tinyint(1) DEFAULT 5,
  category varchar(50) DEFAULT 'general',
  suggestion_context text DEFAULT NULL,
  executed tinyint(1) DEFAULT 0,
  executed_at timestamp NULL DEFAULT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE hosts_info (
  id int(11) NOT NULL,
  host_id varchar(50) NOT NULL,
  hostname varchar(255) NOT NULL,
  ip_address varchar(45) NOT NULL,
  os_info text DEFAULT NULL,
  first_seen timestamp NOT NULL DEFAULT current_timestamp(),
  last_seen timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  total_sessions int(11) DEFAULT 0,
  total_commands int(11) DEFAULT 0,
  is_active tinyint(1) DEFAULT 1,
  notes text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE remote_sessions (
  id int(11) NOT NULL,
  session_id varchar(64) NOT NULL,
  user_id int(11) NOT NULL,
  host_id varchar(50) NOT NULL,
  hostname varchar(255) NOT NULL,
  ip_address varchar(45) NOT NULL,
  os_info text DEFAULT NULL,
  start_time timestamp NOT NULL DEFAULT current_timestamp(),
  end_time timestamp NULL DEFAULT NULL,
  status enum('active','disconnected','terminated') DEFAULT 'active',
  last_activity timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  total_commands int(11) DEFAULT 0,
  session_notes text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE session_contexts (
  id int(11) NOT NULL,
  session_id varchar(64) NOT NULL,
  conversation_id varchar(64) NOT NULL,
  context_type enum('command_history','system_info','working_directory') NOT NULL,
  context_data longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(context_data)),
  updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE system_config (
  id int(11) NOT NULL,
  config_key varchar(100) NOT NULL,
  config_value text DEFAULT NULL,
  description text DEFAULT NULL,
  updated_by int(11) DEFAULT NULL,
  updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO system_config (id, config_key, config_value, description, updated_by, updated_at) VALUES
(1, 'session_timeout', '3600', 'User session timeout in seconds', NULL, '2025-05-26 17:03:43'),
(2, 'max_command_history', '1000', 'Maximum commands to keep in history per session', NULL, '2025-05-26 17:03:43'),
(3, 'chatbot_enabled', '1', 'Enable/disable chatbot functionality', NULL, '2025-05-26 17:03:43'),
(4, 'audit_retention_days', '90', 'Days to retain audit logs', NULL, '2025-05-26 17:03:43'),
(5, 'max_concurrent_sessions', '10', 'Maximum concurrent sessions per user', NULL, '2025-05-26 17:03:43');

CREATE TABLE users (
  id int(11) NOT NULL,
  username varchar(50) NOT NULL,
  password_hash varchar(255) NOT NULL,
  full_name varchar(100) NOT NULL,
  email varchar(100) NOT NULL,
  role enum('admin','manager','operator') DEFAULT 'operator',
  is_active tinyint(1) DEFAULT 1,
  last_login timestamp NULL DEFAULT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  created_by int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO users (id, username, password_hash, full_name, email, role, is_active, last_login, created_at, updated_at, created_by) VALUES
(1, 'admin', '$2y$10$CbcUnO1/A58cRKiGXOJLo.dV3WHYBdvbUOkGT.GBf/3SO/2KGr9Fu', 'System Administrator', 'admin@ghostcrew.local', 'admin', 1, '2025-05-29 11:55:13', '2025-05-26 17:03:43', '2025-05-29 11:55:13', NULL);

CREATE TABLE user_instance_tokens (
  id int(11) NOT NULL,
  user_id int(11) NOT NULL,
  instance_token varchar(128) NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  expires_at timestamp NOT NULL DEFAULT current_timestamp(),
  is_active tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_sessions (
  id int(11) NOT NULL,
  user_id int(11) NOT NULL,
  session_token varchar(128) NOT NULL,
  ip_address varchar(45) NOT NULL,
  user_agent text DEFAULT NULL,
  login_time timestamp NOT NULL DEFAULT current_timestamp(),
  last_activity timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  logout_time timestamp NULL DEFAULT NULL,
  is_active tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


ALTER TABLE audit_log
  ADD PRIMARY KEY (id),
  ADD KEY idx_user_audit (user_id,timestamp),
  ADD KEY idx_action_time (action_type,timestamp);

ALTER TABLE chatbot_conversations
  ADD PRIMARY KEY (id),
  ADD KEY idx_user_conversation (user_id,conversation_id,timestamp),
  ADD KEY idx_session_chat (session_id,timestamp),
  ADD KEY idx_flagged_review (flagged,timestamp),
  ADD KEY idx_parent_message (parent_message_id),
  ADD KEY idx_conversation_thread (conversation_id,timestamp),
  ADD KEY idx_conversation_messages (conversation_id,timestamp),
  ADD KEY idx_user_conversations (user_id,timestamp),
  ADD KEY idx_message_search (message_type,timestamp);

ALTER TABLE chatbot_feedback
  ADD PRIMARY KEY (id),
  ADD KEY idx_conversation_feedback (conversation_id,created_at),
  ADD KEY idx_message_feedback (message_id),
  ADD KEY user_id (user_id);

ALTER TABLE chatbot_knowledge_base
  ADD PRIMARY KEY (id),
  ADD KEY idx_category (category,is_active),
  ADD KEY idx_keywords (keywords(255));
ALTER TABLE chatbot_knowledge_base ADD FULLTEXT KEY idx_question_answer (question,answer,keywords);

ALTER TABLE command_log
  ADD PRIMARY KEY (id),
  ADD KEY idx_session_time (session_id,timestamp),
  ADD KEY idx_user_commands (user_id,timestamp);

ALTER TABLE command_patterns
  ADD PRIMARY KEY (id),
  ADD KEY idx_pattern_category (category,is_active,priority),
  ADD KEY idx_pattern_active (is_active,priority);

ALTER TABLE command_suggestions
  ADD PRIMARY KEY (id),
  ADD KEY idx_conversation_suggestions (conversation_id,created_at),
  ADD KEY user_id (user_id),
  ADD KEY idx_executed_suggestions (executed,created_at),
  ADD KEY idx_user_suggestions (user_id,executed,created_at),
  ADD KEY idx_priority_category (category,priority,created_at);

ALTER TABLE hosts_info
  ADD PRIMARY KEY (id),
  ADD UNIQUE KEY host_id (host_id),
  ADD KEY idx_host_activity (is_active,last_seen);

ALTER TABLE remote_sessions
  ADD PRIMARY KEY (id),
  ADD UNIQUE KEY session_id (session_id),
  ADD KEY idx_user_host (user_id,host_id),
  ADD KEY idx_session_status (status,start_time);

ALTER TABLE session_contexts
  ADD PRIMARY KEY (id),
  ADD UNIQUE KEY unique_session_context (session_id,conversation_id,context_type),
  ADD KEY idx_session_context (session_id,context_type),
  ADD KEY idx_context_lookup (session_id,context_type,updated_at);

ALTER TABLE system_config
  ADD PRIMARY KEY (id),
  ADD UNIQUE KEY config_key (config_key),
  ADD KEY updated_by (updated_by);

ALTER TABLE users
  ADD PRIMARY KEY (id),
  ADD UNIQUE KEY username (username),
  ADD KEY created_by (created_by);

ALTER TABLE user_instance_tokens
  ADD PRIMARY KEY (id),
  ADD UNIQUE KEY instance_token (instance_token),
  ADD KEY user_id (user_id);

ALTER TABLE user_sessions
  ADD PRIMARY KEY (id),
  ADD UNIQUE KEY session_token (session_token),
  ADD KEY user_id (user_id);


ALTER TABLE audit_log
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE chatbot_conversations
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE chatbot_feedback
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE chatbot_knowledge_base
  MODIFY id int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

ALTER TABLE command_log
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE command_patterns
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE command_suggestions
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE hosts_info
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE remote_sessions
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE session_contexts
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE system_config
  MODIFY id int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

ALTER TABLE users
  MODIFY id int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE user_instance_tokens
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE user_sessions
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;


ALTER TABLE audit_log
  ADD CONSTRAINT audit_log_ibfk_1 FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE SET NULL;

ALTER TABLE chatbot_conversations
  ADD CONSTRAINT chatbot_conversations_ibfk_1 FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE CASCADE,
  ADD CONSTRAINT chatbot_conversations_ibfk_2 FOREIGN KEY (session_id) REFERENCES remote_sessions (session_id) ON DELETE SET NULL;

ALTER TABLE chatbot_feedback
  ADD CONSTRAINT chatbot_feedback_ibfk_1 FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE CASCADE,
  ADD CONSTRAINT chatbot_feedback_ibfk_2 FOREIGN KEY (message_id) REFERENCES chatbot_conversations (id) ON DELETE CASCADE;

ALTER TABLE command_log
  ADD CONSTRAINT command_log_ibfk_1 FOREIGN KEY (session_id) REFERENCES remote_sessions (session_id) ON DELETE CASCADE,
  ADD CONSTRAINT command_log_ibfk_2 FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE CASCADE;

ALTER TABLE command_suggestions
  ADD CONSTRAINT command_suggestions_ibfk_1 FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE CASCADE;

ALTER TABLE remote_sessions
  ADD CONSTRAINT remote_sessions_ibfk_1 FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE CASCADE;

ALTER TABLE session_contexts
  ADD CONSTRAINT session_contexts_ibfk_1 FOREIGN KEY (session_id) REFERENCES remote_sessions (session_id) ON DELETE CASCADE;

ALTER TABLE system_config
  ADD CONSTRAINT system_config_ibfk_1 FOREIGN KEY (updated_by) REFERENCES `users` (id) ON DELETE SET NULL;

ALTER TABLE users
  ADD CONSTRAINT users_ibfk_1 FOREIGN KEY (created_by) REFERENCES `users` (id) ON DELETE SET NULL;

ALTER TABLE user_instance_tokens
  ADD CONSTRAINT user_instance_tokens_ibfk_1 FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE CASCADE;

ALTER TABLE user_sessions
  ADD CONSTRAINT user_sessions_ibfk_1 FOREIGN KEY (user_id) REFERENCES `users` (id) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
