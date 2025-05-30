-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 29, 2025 at 11:38 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `ghostcrew_admin`
--

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action_type` enum('login','logout','command_execute','session_start','session_end','chat_message','system_access') NOT NULL,
  `action_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`action_details`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_log`
--

INSERT INTO `audit_log` (`id`, `user_id`, `action_type`, `action_details`, `ip_address`, `user_agent`, `timestamp`) VALUES
(1, 1, 'login', '{\"success\":true,\"username\":\"admin\",\"session_token\":\"b84c368e...\",\"instance_token\":\"inst_1_1...\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:58:21'),
(2, 1, 'session_start', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"hostname\":\"CALEB-\",\"ip_address\":\"127.0.0.1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:58:34'),
(3, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"whoami\",\"command_id\":1}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:58:37'),
(4, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"cd C:\\\\\",\"command_id\":2}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:58:47'),
(5, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"dir\",\"command_id\":3}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:58:54'),
(6, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"mkdir NewFolder\",\"command_id\":4}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:59:15'),
(7, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"dir\",\"command_id\":5}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:59:22'),
(8, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"cd NewFolder\",\"command_id\":6}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:59:34'),
(9, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"dir\",\"command_id\":7}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:59:38'),
(10, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"systeminfo\",\"command_id\":8}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:00:31'),
(11, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"ver\",\"command_id\":9}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:00:37'),
(12, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"ipconfig \\/all\",\"command_id\":10}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:00:45'),
(13, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"netstat\",\"command_id\":11}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:00:53'),
(14, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"net user\",\"command_id\":12}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:01:03'),
(15, 1, 'command_execute', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"net localgroup administrators\",\"command_id\":13}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:01:11'),
(16, 1, 'session_end', '{\"session_id\":\"sess_20250529_185834_fc10ae62fa62c329\",\"end_type\":\"manual\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:01:58'),
(17, 1, 'session_start', '{\"session_id\":\"sess_20250529_190207_fb1b077402c1c170\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"hostname\":\"CALEB-\",\"ip_address\":\"127.0.0.1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:02:07'),
(18, 1, 'session_end', '{\"session_id\":\"sess_20250529_190207_fb1b077402c1c170\",\"end_type\":\"manual\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:02:12'),
(19, 1, 'session_end', '{\"session_id\":\"sess_20250529_190207_fb1b077402c1c170\",\"end_type\":\"manual\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:07:33'),
(20, 1, 'session_start', '{\"session_id\":\"sess_20250529_191330_45dead32be3f9478\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"hostname\":\"CALEB-\",\"ip_address\":\"127.0.0.1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:13:30'),
(21, 1, 'command_execute', '{\"session_id\":\"sess_20250529_191330_45dead32be3f9478\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"whoami\",\"command_id\":14}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:13:37'),
(22, 1, 'session_end', '{\"session_id\":\"sess_20250529_191330_45dead32be3f9478\",\"end_type\":\"manual\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:15:29'),
(23, 1, 'session_start', '{\"session_id\":\"sess_20250529_191554_42258c33108d2467\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"hostname\":\"CALEB-\",\"ip_address\":\"127.0.0.1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:15:54'),
(24, 1, 'command_execute', '{\"session_id\":\"sess_20250529_191554_42258c33108d2467\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"whoami\",\"command_id\":15}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:15:56'),
(25, 1, 'session_end', '{\"session_id\":\"sess_20250529_191554_42258c33108d2467\",\"end_type\":\"manual\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 19:17:14'),
(26, 1, 'session_start', '{\"session_id\":\"sess_20250529_200847_28ee0eae6803b169\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"hostname\":\"CALEB-\",\"ip_address\":\"127.0.0.1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 20:08:47'),
(27, 1, 'session_end', '{\"session_id\":\"sess_20250529_200847_28ee0eae6803b169\",\"end_type\":\"manual\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 20:21:31'),
(28, 1, 'session_start', '{\"session_id\":\"sess_20250529_202134_cdbfef44f3f38071\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"hostname\":\"CALEB-\",\"ip_address\":\"127.0.0.1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 20:21:34'),
(29, 1, 'session_end', '{\"session_id\":\"sess_20250529_202134_cdbfef44f3f38071\",\"end_type\":\"manual\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 20:21:37'),
(30, 1, 'session_end', '{\"session_id\":\"sess_20250529_202134_cdbfef44f3f38071\",\"end_type\":\"manual\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 20:21:42'),
(31, 1, 'session_start', '{\"session_id\":\"sess_20250529_202204_df1d83d0968f3cf8\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"hostname\":\"CALEB-\",\"ip_address\":\"127.0.0.1\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 20:22:04'),
(32, 1, 'command_execute', '{\"session_id\":\"sess_20250529_202204_df1d83d0968f3cf8\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"whoami\",\"command_id\":16}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 20:22:07'),
(33, 1, 'command_execute', '{\"session_id\":\"sess_20250529_202204_df1d83d0968f3cf8\",\"host_id\":\"host_1748314525735_tj8efkqc\",\"command\":\"help\",\"command_id\":17}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 20:22:21');

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_conversations`
--

CREATE TABLE `chatbot_conversations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `session_id` varchar(64) DEFAULT NULL,
  `conversation_id` varchar(64) NOT NULL,
  `parent_message_id` int(11) DEFAULT NULL,
  `message_type` enum('user','bot') NOT NULL,
  `message` text NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `context_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context_data`)),
  `response_time` decimal(8,3) DEFAULT NULL,
  `message_tokens` int(11) DEFAULT NULL,
  `model_used` varchar(50) DEFAULT 'local',
  `suggested_command` text DEFAULT NULL,
  `command_executed` tinyint(1) DEFAULT 0,
  `rating` tinyint(1) DEFAULT NULL,
  `flagged` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chatbot_conversations`
--

INSERT INTO `chatbot_conversations` (`id`, `user_id`, `session_id`, `conversation_id`, `parent_message_id`, `message_type`, `message`, `timestamp`, `context_data`, `response_time`, `message_tokens`, `model_used`, `suggested_command`, `command_executed`, `rating`, `flagged`) VALUES
(1, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'user', 'make a new folder', '2025-05-29 18:59:10', '[]', NULL, NULL, 'local', NULL, 0, NULL, 0),
(2, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'bot', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', '2025-05-29 18:59:10', '{\"knowledge_id\":2}', 0.058, NULL, 'local', 'mkdir NewFolder', 0, NULL, 0),
(3, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'user', 'make a file named hi.txt', '2025-05-29 18:59:49', '[]', NULL, NULL, 'local', NULL, 0, NULL, 0),
(4, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'bot', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', '2025-05-29 18:59:49', '{\"knowledge_id\":3}', 0.041, NULL, 'local', 'copy document.txt backup_document.txt', 0, NULL, 0),
(5, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'user', 'make a file', '2025-05-29 18:59:55', '[]', NULL, NULL, 'local', NULL, 0, NULL, 0),
(6, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'bot', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', '2025-05-29 18:59:55', '{\"knowledge_id\":3}', 0.032, NULL, 'local', 'copy document.txt backup_document.txt', 0, NULL, 0),
(7, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'user', 'new file', '2025-05-29 19:00:08', '[]', NULL, NULL, 'local', NULL, 0, NULL, 0),
(8, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'bot', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', '2025-05-29 19:00:08', '{\"knowledge_id\":2}', 0.032, NULL, 'local', 'mkdir NewFolder', 0, NULL, 0),
(9, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'user', 'Help with network commands', '2025-05-29 19:00:21', '[]', NULL, NULL, 'local', NULL, 0, NULL, 0),
(10, 1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', NULL, 'bot', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', '2025-05-29 19:00:21', '{\"knowledge_id\":7}', 0.034, NULL, 'local', 'help', 0, NULL, 0),
(11, 1, 'sess_20250529_202204_df1d83d0968f3cf8', 'conv_sess_20250529_202204_df1d83d0968f3cf8_1748550138', NULL, 'user', 'help me', '2025-05-29 20:22:18', '[]', NULL, NULL, 'local', NULL, 0, NULL, 0),
(12, 1, 'sess_20250529_202204_df1d83d0968f3cf8', 'conv_sess_20250529_202204_df1d83d0968f3cf8_1748550138', NULL, 'bot', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', '2025-05-29 20:22:18', '{\"knowledge_id\":7}', 0.047, NULL, 'local', 'help', 0, NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_feedback`
--

CREATE TABLE `chatbot_feedback` (
  `id` int(11) NOT NULL,
  `conversation_id` varchar(64) NOT NULL,
  `message_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `feedback_type` enum('helpful','not_helpful','incorrect','suggestion') NOT NULL,
  `feedback_text` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_knowledge_base`
--

CREATE TABLE `chatbot_knowledge_base` (
  `id` int(11) NOT NULL,
  `category` varchar(100) NOT NULL,
  `question` text NOT NULL,
  `answer` text NOT NULL,
  `keywords` text DEFAULT NULL,
  `command_example` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chatbot_knowledge_base`
--

INSERT INTO `chatbot_knowledge_base` (`id`, `category`, `question`, `answer`, `keywords`, `command_example`, `created_at`, `updated_at`, `is_active`) VALUES
(1, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:26:13', '2025-05-29 16:26:13', 1),
(2, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:26:13', '2025-05-29 16:26:13', 1),
(3, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:26:13', '2025-05-29 16:26:13', 1),
(4, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:26:13', '2025-05-29 16:26:13', 1),
(5, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:26:13', '2025-05-29 16:26:13', 1),
(6, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:26:13', '2025-05-29 16:26:13', 1),
(7, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:26:13', '2025-05-29 16:26:13', 1),
(8, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:28:29', '2025-05-29 16:28:29', 1),
(9, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:28:29', '2025-05-29 16:28:29', 1),
(10, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:28:29', '2025-05-29 16:28:29', 1),
(11, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:28:29', '2025-05-29 16:28:29', 1),
(12, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:28:29', '2025-05-29 16:28:29', 1),
(13, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:28:29', '2025-05-29 16:28:29', 1),
(14, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:28:29', '2025-05-29 16:28:29', 1),
(15, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:29:00', '2025-05-29 16:29:00', 1),
(16, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:29:00', '2025-05-29 16:29:00', 1),
(17, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:29:00', '2025-05-29 16:29:00', 1),
(18, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:29:00', '2025-05-29 16:29:00', 1),
(19, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:29:00', '2025-05-29 16:29:00', 1),
(20, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:29:00', '2025-05-29 16:29:00', 1),
(21, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:29:00', '2025-05-29 16:29:00', 1),
(22, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:29:13', '2025-05-29 16:29:13', 1),
(23, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:29:13', '2025-05-29 16:29:13', 1),
(24, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:29:13', '2025-05-29 16:29:13', 1),
(25, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:29:13', '2025-05-29 16:29:13', 1),
(26, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:29:13', '2025-05-29 16:29:13', 1),
(27, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:29:13', '2025-05-29 16:29:13', 1),
(28, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:29:13', '2025-05-29 16:29:13', 1),
(29, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:29:20', '2025-05-29 16:29:20', 1),
(30, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:29:20', '2025-05-29 16:29:20', 1),
(31, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:29:20', '2025-05-29 16:29:20', 1),
(32, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:29:20', '2025-05-29 16:29:20', 1),
(33, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:29:20', '2025-05-29 16:29:20', 1),
(34, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:29:20', '2025-05-29 16:29:20', 1),
(35, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:29:20', '2025-05-29 16:29:20', 1),
(36, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:29:29', '2025-05-29 16:29:29', 1),
(37, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:29:29', '2025-05-29 16:29:29', 1),
(38, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:29:29', '2025-05-29 16:29:29', 1),
(39, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:29:29', '2025-05-29 16:29:29', 1),
(40, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:29:29', '2025-05-29 16:29:29', 1),
(41, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:29:29', '2025-05-29 16:29:29', 1),
(42, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:29:29', '2025-05-29 16:29:29', 1),
(43, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:29:49', '2025-05-29 16:29:49', 1),
(44, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:29:49', '2025-05-29 16:29:49', 1),
(45, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:29:49', '2025-05-29 16:29:49', 1),
(46, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:29:49', '2025-05-29 16:29:49', 1),
(47, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:29:49', '2025-05-29 16:29:49', 1),
(48, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:29:49', '2025-05-29 16:29:49', 1),
(49, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:29:49', '2025-05-29 16:29:49', 1),
(50, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:29:55', '2025-05-29 16:29:55', 1),
(51, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:29:55', '2025-05-29 16:29:55', 1),
(52, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:29:55', '2025-05-29 16:29:55', 1),
(53, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:29:55', '2025-05-29 16:29:55', 1),
(54, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:29:55', '2025-05-29 16:29:55', 1),
(55, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:29:55', '2025-05-29 16:29:55', 1),
(56, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:29:55', '2025-05-29 16:29:55', 1),
(57, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:29:59', '2025-05-29 16:29:59', 1),
(58, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:29:59', '2025-05-29 16:29:59', 1),
(59, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:29:59', '2025-05-29 16:29:59', 1),
(60, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:29:59', '2025-05-29 16:29:59', 1),
(61, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:29:59', '2025-05-29 16:29:59', 1),
(62, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:29:59', '2025-05-29 16:29:59', 1),
(63, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:29:59', '2025-05-29 16:29:59', 1),
(64, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:30:03', '2025-05-29 16:30:03', 1),
(65, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:30:03', '2025-05-29 16:30:03', 1),
(66, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:30:03', '2025-05-29 16:30:03', 1),
(67, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:30:03', '2025-05-29 16:30:03', 1),
(68, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:30:03', '2025-05-29 16:30:03', 1),
(69, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:30:03', '2025-05-29 16:30:03', 1),
(70, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:30:03', '2025-05-29 16:30:03', 1),
(71, 'file_operations', 'How do I list files and directories?', 'To list files and directories in Windows, you can use several commands:\n\n• **dir** - Basic directory listing\n• **dir /a** - Show all files including hidden\n• **dir /s** - Include subdirectories\n• **tree** - Show directory structure as a tree\n\nThe most common is simply **dir** to see what\'s in the current directory.', 'list files directories folder dir tree', 'dir', '2025-05-29 16:30:09', '2025-05-29 16:30:09', 1),
(72, 'file_operations', 'How do I create a new folder?', 'To create a new folder (directory) in Windows:\n\n**mkdir [folder_name]**\n\nFor example: `mkdir NewFolder`\n\nYou can also create multiple nested folders at once:\n`mkdir \"Parent Folder\\Child Folder\"`', 'create folder directory mkdir', 'mkdir NewFolder', '2025-05-29 16:30:09', '2025-05-29 16:30:09', 1),
(73, 'file_operations', 'How do I copy files?', 'To copy files in Windows, you have several options:\n\n• **copy [source] [destination]** - Copy single file\n• **xcopy [source] [dest] /s** - Copy folders and subfolders\n• **robocopy [source] [dest]** - Advanced copying with more options\n\nExample: `copy document.txt backup_document.txt`', 'copy files xcopy robocopy', 'copy document.txt backup_document.txt', '2025-05-29 16:30:09', '2025-05-29 16:30:09', 1),
(74, 'system_info', 'How do I check system information?', 'To get system information in Windows:\n\n• **systeminfo** - Comprehensive system details\n• **wmic computersystem get model,name,manufacturer** - Hardware info\n• **ver** - Windows version\n• **hostname** - Computer name\n\nThe **systeminfo** command gives you the most complete overview.', 'system information hardware details systeminfo', 'systeminfo', '2025-05-29 16:30:09', '2025-05-29 16:30:09', 1),
(75, 'network', 'How do I test network connectivity?', 'To test network connectivity:\n\n• **ping [host]** - Test basic connectivity\n• **ping -t [host]** - Continuous ping\n• **tracert [host]** - Trace route to destination\n• **nslookup [domain]** - DNS lookup\n• **ipconfig** - Show network configuration\n\nStart with **ping google.com** to test internet connectivity.', 'network ping connectivity test tracert ipconfig', 'ping google.com', '2025-05-29 16:30:09', '2025-05-29 16:30:09', 1),
(76, 'processes', 'How do I see running processes?', 'To view and manage processes:\n\n• **tasklist** - Show all running processes\n• **tasklist /svc** - Show processes with services\n• **taskkill /pid [ID]** - Kill process by ID\n• **taskkill /im [name]** - Kill process by name\n\nExample: First run `tasklist` to see processes, then `taskkill /im notepad.exe` to close Notepad.', 'processes running tasks tasklist taskkill', 'tasklist', '2025-05-29 16:30:09', '2025-05-29 16:30:09', 1),
(77, 'help', 'What commands are available?', 'Here are the main categories of Windows commands I can help with:\n\n• **File Operations** - dir, copy, move, del, mkdir\n• **System Information** - systeminfo, ver, hostname\n• **Network Commands** - ping, ipconfig, netstat\n• **Process Management** - tasklist, taskkill\n• **User Management** - whoami, net user\n• **Service Management** - sc query, net start/stop\n\nAsk me about any specific category or command!', 'help commands available categories', 'help', '2025-05-29 16:30:09', '2025-05-29 16:30:09', 1);

-- --------------------------------------------------------

--
-- Table structure for table `command_log`
--

CREATE TABLE `command_log` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `user_id` int(11) NOT NULL,
  `command` text NOT NULL,
  `output` longtext DEFAULT NULL,
  `execution_time` decimal(10,6) DEFAULT NULL,
  `status` enum('pending','completed','failed','timeout') DEFAULT 'pending',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `response_timestamp` timestamp NULL DEFAULT NULL,
  `error_message` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `command_log`
--

INSERT INTO `command_log` (`id`, `session_id`, `user_id`, `command`, `output`, `execution_time`, `status`, `timestamp`, `response_timestamp`, `error_message`) VALUES
(1, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'whoami', 'caleb-\\caleb', 1.505000, 'completed', '2025-05-29 18:58:37', '2025-05-29 18:58:40', NULL),
(2, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'cd C:\\', 'C:\\', 0.003000, 'completed', '2025-05-29 18:58:47', '2025-05-29 18:58:47', NULL),
(3, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'dir', 'Volume in drive C is Windows\r\n Volume Serial Number is E88F-9F2D\r\n\r\n Directory of C:\\NewFolder\r\n\r\n05/29/2025  01:59 PM    <DIR>          .\r\n               0 File(s)              0 bytes\r\n               1 Dir(s)  717,596,352,512 bytes free', 1.518000, 'completed', '2025-05-29 18:58:54', '2025-05-29 18:59:41', NULL),
(4, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'mkdir NewFolder', 'Command completed successfully (no output).', 1.441000, 'completed', '2025-05-29 18:59:15', '2025-05-29 18:59:17', NULL),
(5, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'dir', 'Volume in drive C is Windows\r\n Volume Serial Number is E88F-9F2D\r\n\r\n Directory of C:\\NewFolder\r\n\r\n05/29/2025  01:59 PM    <DIR>          .\r\n               0 File(s)              0 bytes\r\n               1 Dir(s)  717,596,352,512 bytes free', 1.518000, 'completed', '2025-05-29 18:59:22', '2025-05-29 18:59:41', NULL),
(6, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'cd NewFolder', 'C:\\NewFolder\\', 0.004000, 'completed', '2025-05-29 18:59:34', '2025-05-29 18:59:34', NULL),
(7, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'dir', 'Volume in drive C is Windows\r\n Volume Serial Number is E88F-9F2D\r\n\r\n Directory of C:\\NewFolder\r\n\r\n05/29/2025  01:59 PM    <DIR>          .\r\n               0 File(s)              0 bytes\r\n               1 Dir(s)  717,596,352,512 bytes free', 1.518000, 'completed', '2025-05-29 18:59:38', '2025-05-29 18:59:41', NULL),
(8, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'systeminfo', 'Host Name:                     CALEB-\r\nOS Name:                       Microsoft Windows 11 Home\r\nOS Version:                    10.0.26100 N/A Build 26100\r\nOS Manufacturer:               Microsoft Corporation\r\nOS Configuration:              Standalone Workstation\r\nOS Build Type:                 Multiprocessor Free\r\nRegistered Owner:              calebiinfinger@gmail.com\r\nRegistered Organization:       HP\r\nProduct ID:                    00342-22172-19006-AAOEM\r\nOriginal Install Date:         11/1/2024, 5:16:19 AM\r\nSystem Boot Time:              5/29/2025, 4:12:33 AM\r\nSystem Manufacturer:           HP\r\nSystem Model:                  HP Envy x360 2-in-1 Laptop 14-es0xxx\r\nSystem Type:                   x64-based PC\r\nProcessor(s):                  1 Processor(s) Installed.\r\n                               [01]: Intel64 Family 6 Model 186 Stepping 3 GenuineIntel ~1457 Mhz\r\nBIOS Version:                  Insyde F.09, 4/19/2024\r\nWindows Directory:             C:\\WINDOWS\r\nSystem Directory:              C:\\WINDOWS\\system32\r\nBoot Device:                   \\Device\\HarddiskVolume1\r\nSystem Locale:                 en-us;English (United States)\r\nInput Locale:                  en-us;English (United States)\r\nTime Zone:                     (UTC-06:00) Central Time (US & Canada)\r\nTotal Physical Memory:         16,095 MB\r\nAvailable Physical Memory:     4,928 MB\r\nVirtual Memory: Max Size:      55,007 MB\r\nVirtual Memory: Available:     38,718 MB\r\nVirtual Memory: In Use:        16,289 MB\r\nPage File Location(s):         C:\\pagefile.sys\r\nDomain:                        WORKGROUP\r\nLogon Server:                  \\\\CALEB-\r\nHotfix(s):                     4 Hotfix(s) Installed.\r\n                               [01]: KB5056579\r\n                               [02]: KB5058499\r\n                               [03]: KB5058523\r\n                               [04]: KB5059502\r\nNetwork Card(s):               7 NIC(s) Installed.\r\n                               [01]: ExpressVPN TUN Driver\r\n                                     Connection Name: Local Area Connection\r\n                                     Status:          Media disconnected\r\n                               [02]: Realtek 8852CE WiFi 6E PCI-E NIC\r\n                                     Connection Name: Wi-Fi\r\n                                     DHCP Enabled:    Yes\r\n                                     DHCP Server:     192.168.68.1\r\n                                     IP address(es)\r\n                                     [01]: 192.168.68.64\r\n                                     [02]: fe80::1793:6c98:8cd:ad7d\r\n                               [03]: Wintun Userspace Tunnel\r\n                                     Connection Name: OpenVPN Wintun\r\n                                     Status:          Media disconnected\r\n                               [04]: TAP-Windows Adapter V9\r\n                                     Connection Name: OpenVPN TAP-Windows6\r\n                                     Status:          Media disconnected\r\n                               [05]: OpenVPN Data Channel Offload\r\n                                     Connection Name: OpenVPN Data Channel Offload\r\n                                     Status:          Media disconnected\r\n                               [06]: Bluetooth Device (Personal Area Network)\r\n                                     Connection Name: Bluetooth Network Connection\r\n                                     Status:          Media disconnected\r\n                               [07]: VirtualBox Host-Only Ethernet Adapter\r\n                                     Connection Name: Ethernet 5\r\n                                     DHCP Enabled:    No\r\n                                     IP address(es)\r\n                                     [01]: 192.168.56.1\r\n                                     [02]: fe80::4f17:2b8d:7d5e:d7b8\r\nVirtualization-based security: Status: Running\r\n                               Required Security Properties:\r\n                               Available Security Properties:\r\n                                     Base Virtualization Support\r\n                                     Secure Boot\r\n                                     DMA Protection\r\n                                     UEFI Code Readonly\r\n                                     SMM Security Mitigations 1.0\r\n                                     Mode Based Execution Control\r\n                                     APIC Virtualization\r\n                               Services Configured:\r\n                                     Hypervisor enforced Code Integrity\r\n                               Services Running:\r\n                                     Hypervisor enforced Code Integrity\r\n                               App Control for Business policy: Enforced\r\n                               App Control for Business user mode policy: Off\r\n                               Security Features Enabled:\r\nHyper-V Requirements:          A hypervisor has been detected. Features required for Hyper-V will not be displayed.', 8.209000, 'completed', '2025-05-29 19:00:31', '2025-05-29 19:00:39', NULL),
(9, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'ver', 'Microsoft Windows [Version 10.0.26100.4202]', 1.293000, 'completed', '2025-05-29 19:00:37', '2025-05-29 19:00:42', NULL),
(10, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'ipconfig /all', 'Windows IP Configuration\r\n\r\n   Host Name . . . . . . . . . . . . : Caleb-\r\n   Primary Dns Suffix  . . . . . . . : \r\n   Node Type . . . . . . . . . . . . : Hybrid\r\n   IP Routing Enabled. . . . . . . . : No\r\n   WINS Proxy Enabled. . . . . . . . : No\r\n\r\nUnknown adapter Local Area Connection:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : ExpressVPN TUN Driver\r\n   Physical Address. . . . . . . . . : \r\n   DHCP Enabled. . . . . . . . . . . : No\r\n   Autoconfiguration Enabled . . . . : Yes\r\n\r\nUnknown adapter OpenVPN Wintun:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : Wintun Userspace Tunnel\r\n   Physical Address. . . . . . . . . : \r\n   DHCP Enabled. . . . . . . . . . . : No\r\n   Autoconfiguration Enabled . . . . : Yes\r\n\r\nUnknown adapter OpenVPN TAP-Windows6:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : TAP-Windows Adapter V9\r\n   Physical Address. . . . . . . . . : 00-FF-5A-09-01-61\r\n   DHCP Enabled. . . . . . . . . . . : Yes\r\n   Autoconfiguration Enabled . . . . : Yes\r\n\r\nEthernet adapter Ethernet 5:\r\n\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : VirtualBox Host-Only Ethernet Adapter\r\n   Physical Address. . . . . . . . . : 0A-00-27-00-00-09\r\n   DHCP Enabled. . . . . . . . . . . : No\r\n   Autoconfiguration Enabled . . . . : Yes\r\n   Link-local IPv6 Address . . . . . : fe80::4f17:2b8d:7d5e:d7b8%9(Preferred) \r\n   IPv4 Address. . . . . . . . . . . : 192.168.56.1(Preferred) \r\n   Subnet Mask . . . . . . . . . . . : 255.255.255.0\r\n   Default Gateway . . . . . . . . . : \r\n   DHCPv6 IAID . . . . . . . . . . . : 1141506087\r\n   DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-2E-B6-61-4D-00-41-0E-66-EC-A5\r\n   NetBIOS over Tcpip. . . . . . . . : Enabled\r\n\r\nUnknown adapter OpenVPN Data Channel Offload:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : OpenVPN Data Channel Offload\r\n   Physical Address. . . . . . . . . : \r\n   DHCP Enabled. . . . . . . . . . . : Yes\r\n   Autoconfiguration Enabled . . . . : Yes\r\n\r\nWireless LAN adapter Local Area Connection* 1:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : Microsoft Wi-Fi Direct Virtual Adapter\r\n   Physical Address. . . . . . . . . : 02-41-0E-66-EC-A5\r\n   DHCP Enabled. . . . . . . . . . . : Yes\r\n   Autoconfiguration Enabled . . . . : Yes\r\n\r\nWireless LAN adapter Local Area Connection* 2:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : Microsoft Wi-Fi Direct Virtual Adapter #2\r\n   Physical Address. . . . . . . . . : 06-41-0E-66-EC-A5\r\n   DHCP Enabled. . . . . . . . . . . : No\r\n   Autoconfiguration Enabled . . . . : Yes\r\n\r\nWireless LAN adapter Wi-Fi:\r\n\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : Realtek 8852CE WiFi 6E PCI-E NIC\r\n   Physical Address. . . . . . . . . : 00-41-0E-66-EC-A5\r\n   DHCP Enabled. . . . . . . . . . . : Yes\r\n   Autoconfiguration Enabled . . . . : Yes\r\n   Link-local IPv6 Address . . . . . : fe80::1793:6c98:8cd:ad7d%14(Preferred) \r\n   IPv4 Address. . . . . . . . . . . : 192.168.68.64(Preferred) \r\n   Subnet Mask . . . . . . . . . . . : 255.255.252.0\r\n   Lease Obtained. . . . . . . . . . : Thursday, May 29, 2025 9:23:08 AM\r\n   Lease Expires . . . . . . . . . . : Thursday, May 29, 2025 3:36:59 PM\r\n   Default Gateway . . . . . . . . . : 192.168.68.1\r\n   DHCP Server . . . . . . . . . . . : 192.168.68.1\r\n   DHCPv6 IAID . . . . . . . . . . . : 134234382\r\n   DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-2E-B6-61-4D-00-41-0E-66-EC-A5\r\n   DNS Servers . . . . . . . . . . . : 192.168.1.1\r\n                                       192.168.68.1\r\n   NetBIOS over Tcpip. . . . . . . . : Enabled\r\n\r\nEthernet adapter Bluetooth Network Connection:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n   Description . . . . . . . . . . . : Bluetooth Device (Personal Area Network)\r\n   Physical Address. . . . . . . . . : 00-41-0E-66-EC-A6\r\n   DHCP Enabled. . . . . . . . . . . : Yes\r\n   Autoconfiguration Enabled . . . . : Yes', 1.527000, 'completed', '2025-05-29 19:00:45', '2025-05-29 19:00:48', NULL),
(11, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'netstat', 'Active Connections\r\n\r\n  Proto  Local Address          Foreign Address        State\r\n  TCP    127.0.0.1:4767         www:50134              ESTABLISHED\r\n  TCP    127.0.0.1:5354         www:49686              ESTABLISHED\r\n  TCP    127.0.0.1:5354         www:49691              ESTABLISHED\r\n  TCP    127.0.0.1:49670        www:49671              ESTABLISHED\r\n  TCP    127.0.0.1:49671        www:49670              ESTABLISHED\r\n  TCP    127.0.0.1:49674        www:49675              ESTABLISHED\r\n  TCP    127.0.0.1:49675        www:49674              ESTABLISHED\r\n  TCP    127.0.0.1:49686        www:5354               ESTABLISHED\r\n  TCP    127.0.0.1:49691        www:5354               ESTABLISHED\r\n  TCP    127.0.0.1:49725        www:49726              ESTABLISHED\r\n  TCP    127.0.0.1:49726        www:49725              ESTABLISHED\r\n  TCP    127.0.0.1:49727        www:49728              ESTABLISHED\r\n  TCP    127.0.0.1:49728        www:49727              ESTABLISHED\r\n  TCP    127.0.0.1:49729        www:49730              ESTABLISHED\r\n  TCP    127.0.0.1:49730        www:49729              ESTABLISHED\r\n  TCP    127.0.0.1:49839        www:49840              ESTABLISHED\r\n  TCP    127.0.0.1:49840        www:49839              ESTABLISHED\r\n  TCP    127.0.0.1:50108        www:50109              ESTABLISHED\r\n  TCP    127.0.0.1:50109        www:50108              ESTABLISHED\r\n  TCP    127.0.0.1:50116        www:50117              ESTABLISHED\r\n  TCP    127.0.0.1:50117        www:50116              ESTABLISHED\r\n  TCP    127.0.0.1:50120        www:50121              ESTABLISHED\r\n  TCP    127.0.0.1:50121        www:50120              ESTABLISHED\r\n  TCP    127.0.0.1:50134        www:4767               ESTABLISHED\r\n  TCP    127.0.0.1:50174        www:50176              ESTABLISHED\r\n  TCP    127.0.0.1:50176        www:50174              ESTABLISHED\r\n  TCP    192.168.68.64:4191     104.17.107.108:https   ESTABLISHED\r\n  TCP    192.168.68.64:4463     lb-140-82-112-25-iad:https  ESTABLISHED\r\n  TCP    192.168.68.64:4464     33:https               ESTABLISHED\r\n  TCP    192.168.68.64:5767     103:https              ESTABLISHED\r\n  TCP    192.168.68.64:6062     ec2-54-236-104-103:https  ESTABLISHED\r\n  TCP    192.168.68.64:6110     104.17.25.14:https     ESTABLISHED\r\n  TCP    192.168.68.64:6114     150.171.27.11:https    ESTABLISHED\r\n  TCP    192.168.68.64:6122     yb-in-f95:https        ESTABLISHED\r\n  TCP    192.168.68.64:6153     server-3-166-96-65:https  ESTABLISHED\r\n  TCP    192.168.68.64:6393     13.107.253.40:https    ESTABLISHED\r\n  TCP    192.168.68.64:49409    104.208.203.88:https   ESTABLISHED\r\n  TCP    192.168.68.64:50597    a1370dc23e25e46ce:https  ESTABLISHED\r\n  TCP    192.168.68.64:50603    server-3-160-28-87:http  CLOSE_WAIT\r\n  TCP    192.168.68.64:65371    33:https               ESTABLISHED\r\n  TCP    [::1]:80               Caleb-:6115            ESTABLISHED\r\n  TCP    [::1]:80               Caleb-:6275            ESTABLISHED\r\n  TCP    [::1]:80               Caleb-:6539            FIN_WAIT_2\r\n  TCP    [::1]:3306             Caleb-:6598            TIME_WAIT\r\n  TCP    [::1]:6115             Caleb-:http            ESTABLISHED\r\n  TCP    [::1]:6275             Caleb-:http            ESTABLISHED\r\n  TCP    [::1]:6539             Caleb-:http            CLOSE_WAIT\r\n  TCP    [::1]:6570             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6571             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6572             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6573             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6574             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6575             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6576             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6577             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6578             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6579             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6580             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6581             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6582             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6583             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6584             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6585             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6586             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6587             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6588             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6589             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6590             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6591             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6592             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6593             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6594             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6595             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6596             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6597             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6598             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6599             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6600             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6601             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6602             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6603             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6604             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6605             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6606             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6607             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6608             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6609             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6610             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6611             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6612             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6613             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6614             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6615             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6616             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6617             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6618             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6619             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6620             Caleb-:3306            TIME_WAIT\r\n  TCP    [::1]:6621             Caleb-:3306            TIME_WAIT', 25.935000, 'completed', '2025-05-29 19:00:53', '2025-05-29 19:01:19', NULL),
(12, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'net user', 'User accounts for \\\\CALEB-\r\n\r\n-------------------------------------------------------------------------------\r\nAdministrator            caleb                    DefaultAccount           \r\nGuest                    WDAGUtilityAccount       \r\nThe command completed successfully.', 1.683000, 'completed', '2025-05-29 19:01:03', '2025-05-29 19:01:22', NULL),
(13, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'net localgroup administrators', 'Alias name     administrators\r\nComment        Administrators have complete and unrestricted access to the computer/domain\r\n\r\nMembers\r\n\r\n-------------------------------------------------------------------------------\r\nAdministrator\r\ncaleb\r\nThe command completed successfully.', 1.623000, 'completed', '2025-05-29 19:01:11', '2025-05-29 19:01:25', NULL),
(14, 'sess_20250529_191330_45dead32be3f9478', 1, 'whoami', '\'/Q\' is not recognized as an internal or external command,\r\noperable program or batch file.', 1.336000, 'completed', '2025-05-29 19:13:37', '2025-05-29 19:13:39', NULL),
(15, 'sess_20250529_191554_42258c33108d2467', 1, 'whoami', '\'/q\' is not recognized as an internal or external command,\r\noperable program or batch file.', 1.449000, 'completed', '2025-05-29 19:15:56', '2025-05-29 19:15:59', NULL),
(16, 'sess_20250529_202204_df1d83d0968f3cf8', 1, 'whoami', NULL, NULL, 'pending', '2025-05-29 20:22:07', NULL, NULL),
(17, 'sess_20250529_202204_df1d83d0968f3cf8', 1, 'help', NULL, NULL, 'pending', '2025-05-29 20:22:21', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `command_patterns`
--

CREATE TABLE `command_patterns` (
  `id` int(11) NOT NULL,
  `pattern` varchar(255) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `suggested_commands` text NOT NULL,
  `response_template` text NOT NULL,
  `match_type` enum('exact','contains','regex') DEFAULT 'contains',
  `priority` tinyint(1) DEFAULT 5,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `command_suggestions`
--

CREATE TABLE `command_suggestions` (
  `id` int(11) NOT NULL,
  `conversation_id` varchar(64) NOT NULL,
  `user_id` int(11) NOT NULL,
  `suggested_command` text NOT NULL,
  `command_description` text DEFAULT NULL,
  `priority` tinyint(1) DEFAULT 5,
  `category` varchar(50) DEFAULT 'general',
  `suggestion_context` text DEFAULT NULL,
  `executed` tinyint(1) DEFAULT 0,
  `executed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `command_suggestions`
--

INSERT INTO `command_suggestions` (`id`, `conversation_id`, `user_id`, `suggested_command`, `command_description`, `priority`, `category`, `suggestion_context`, `executed`, `executed_at`, `created_at`) VALUES
(1, 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', 1, 'mkdir NewFolder', 'Example for: How do I create a new folder?', 8, 'file_operations', '', 0, NULL, '2025-05-29 18:59:10'),
(2, 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', 1, 'copy document.txt backup_document.txt', 'Example for: How do I copy files?', 8, 'file_operations', '', 0, NULL, '2025-05-29 18:59:49'),
(3, 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', 1, 'copy document.txt backup_document.txt', 'Example for: How do I copy files?', 8, 'file_operations', '', 0, NULL, '2025-05-29 18:59:55'),
(4, 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', 1, 'mkdir NewFolder', 'Example for: How do I create a new folder?', 8, 'file_operations', '', 0, NULL, '2025-05-29 19:00:08'),
(5, 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', 1, 'help', 'Example for: What commands are available?', 8, 'help', '', 0, NULL, '2025-05-29 19:00:21'),
(6, 'conv_sess_20250529_202204_df1d83d0968f3cf8_1748550138', 1, 'help', 'Example for: What commands are available?', 8, 'help', '', 0, NULL, '2025-05-29 20:22:18');

-- --------------------------------------------------------

--
-- Table structure for table `hosts_info`
--

CREATE TABLE `hosts_info` (
  `id` int(11) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `hostname` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `os_info` text DEFAULT NULL,
  `first_seen` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_seen` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `total_sessions` int(11) DEFAULT 0,
  `total_commands` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `hosts_info`
--

INSERT INTO `hosts_info` (`id`, `host_id`, `hostname`, `ip_address`, `os_info`, `first_seen`, `last_seen`, `total_sessions`, `total_commands`, `is_active`, `notes`) VALUES
(1, 'host_1748314525735_tj8efkqc', 'CALEB-', '127.0.0.1', 'Microsoft Windows 11 Home 10.0.26100 (64-bit)', '2025-05-29 18:58:30', '2025-05-29 20:21:19', 0, 0, 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `remote_sessions`
--

CREATE TABLE `remote_sessions` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `user_id` int(11) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `hostname` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `os_info` text DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `end_time` timestamp NULL DEFAULT NULL,
  `status` enum('active','disconnected','terminated') DEFAULT 'active',
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `total_commands` int(11) DEFAULT 0,
  `session_notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `remote_sessions`
--

INSERT INTO `remote_sessions` (`id`, `session_id`, `user_id`, `host_id`, `hostname`, `ip_address`, `os_info`, `start_time`, `end_time`, `status`, `last_activity`, `total_commands`, `session_notes`) VALUES
(1, 'sess_20250529_185834_fc10ae62fa62c329', 1, 'host_1748314525735_tj8efkqc', 'CALEB-', '127.0.0.1', 'Microsoft Windows 11 Home 10.0.26100 (64-bit)', '2025-05-29 18:58:34', '2025-05-29 19:01:58', 'terminated', '2025-05-29 19:01:58', 13, NULL),
(2, 'sess_20250529_190207_fb1b077402c1c170', 1, 'host_1748314525735_tj8efkqc', 'CALEB-', '127.0.0.1', 'Microsoft Windows 11 Home 10.0.26100 (64-bit)', '2025-05-29 19:02:07', '2025-05-29 19:07:33', 'terminated', '2025-05-29 19:07:33', 0, NULL),
(3, 'sess_20250529_191330_45dead32be3f9478', 1, 'host_1748314525735_tj8efkqc', 'CALEB-', '127.0.0.1', 'Microsoft Windows 11 Home 10.0.26100 (64-bit)', '2025-05-29 19:13:30', '2025-05-29 19:15:29', 'terminated', '2025-05-29 19:15:29', 1, NULL),
(4, 'sess_20250529_191554_42258c33108d2467', 1, 'host_1748314525735_tj8efkqc', 'CALEB-', '127.0.0.1', 'Microsoft Windows 11 Home 10.0.26100 (64-bit)', '2025-05-29 19:15:54', '2025-05-29 19:17:14', 'terminated', '2025-05-29 19:17:14', 1, NULL),
(5, 'sess_20250529_200847_28ee0eae6803b169', 1, 'host_1748314525735_tj8efkqc', 'CALEB-', '127.0.0.1', 'Microsoft Windows 11 Home 10.0.26100 (64-bit)', '2025-05-29 20:08:47', '2025-05-29 20:21:31', 'terminated', '2025-05-29 20:21:31', 0, NULL),
(6, 'sess_20250529_202134_cdbfef44f3f38071', 1, 'host_1748314525735_tj8efkqc', 'CALEB-', '127.0.0.1', 'Microsoft Windows 11 Home 10.0.26100 (64-bit)', '2025-05-29 20:21:34', '2025-05-29 20:21:42', 'terminated', '2025-05-29 20:21:42', 0, NULL),
(7, 'sess_20250529_202204_df1d83d0968f3cf8', 1, 'host_1748314525735_tj8efkqc', 'CALEB-', '127.0.0.1', 'Microsoft Windows 11 Home 10.0.26100 (64-bit)', '2025-05-29 20:22:04', NULL, 'active', '2025-05-29 20:22:21', 2, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `session_contexts`
--

CREATE TABLE `session_contexts` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `conversation_id` varchar(64) NOT NULL,
  `context_type` enum('command_history','system_info','working_directory') NOT NULL,
  `context_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context_data`)),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `session_contexts`
--

INSERT INTO `session_contexts` (`id`, `session_id`, `conversation_id`, `context_type`, `context_data`, `updated_at`) VALUES
(1, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545117', 'command_history', '{\"command\":\"whoami\",\"timestamp\":\"2025-05-29 18:58:37\",\"status\":\"pending\"}', '2025-05-29 18:58:37'),
(2, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545127', 'command_history', '{\"command\":\"cd C:\\\\\",\"timestamp\":\"2025-05-29 18:58:47\",\"status\":\"pending\"}', '2025-05-29 18:58:47'),
(3, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545134', 'command_history', '{\"command\":\"dir\",\"timestamp\":\"2025-05-29 18:58:54\",\"status\":\"pending\"}', '2025-05-29 18:58:54'),
(4, 'sess_20250529_185834_fc10ae62fa62c329', 'conv_sess_20250529_185834_fc10ae62fa62c329_1748545150', 'command_history', '{\"command\":\"net localgroup administrators\",\"timestamp\":\"2025-05-29 19:01:11\",\"status\":\"pending\"}', '2025-05-29 19:01:11'),
(14, 'sess_20250529_191330_45dead32be3f9478', 'conv_sess_20250529_191330_45dead32be3f9478_1748546017', 'command_history', '{\"command\":\"whoami\",\"timestamp\":\"2025-05-29 19:13:37\",\"status\":\"pending\"}', '2025-05-29 19:13:37'),
(15, 'sess_20250529_191554_42258c33108d2467', 'conv_sess_20250529_191554_42258c33108d2467_1748546156', 'command_history', '{\"command\":\"whoami\",\"timestamp\":\"2025-05-29 19:15:56\",\"status\":\"pending\"}', '2025-05-29 19:15:56'),
(16, 'sess_20250529_202204_df1d83d0968f3cf8', 'conv_sess_20250529_202204_df1d83d0968f3cf8_1748550127', 'command_history', '{\"command\":\"whoami\",\"timestamp\":\"2025-05-29 20:22:07\",\"status\":\"pending\"}', '2025-05-29 20:22:07'),
(17, 'sess_20250529_202204_df1d83d0968f3cf8', 'conv_sess_20250529_202204_df1d83d0968f3cf8_1748550138', 'command_history', '{\"command\":\"help\",\"timestamp\":\"2025-05-29 20:22:21\",\"status\":\"pending\"}', '2025-05-29 20:22:21');

-- --------------------------------------------------------

--
-- Table structure for table `system_config`
--

CREATE TABLE `system_config` (
  `id` int(11) NOT NULL,
  `config_key` varchar(100) NOT NULL,
  `config_value` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `system_config`
--

INSERT INTO `system_config` (`id`, `config_key`, `config_value`, `description`, `updated_by`, `updated_at`) VALUES
(1, 'session_timeout', '3600', 'User session timeout in seconds', NULL, '2025-05-26 22:03:43'),
(2, 'max_command_history', '1000', 'Maximum commands to keep in history per session', NULL, '2025-05-26 22:03:43'),
(3, 'chatbot_enabled', '1', 'Enable/disable chatbot functionality', NULL, '2025-05-26 22:03:43'),
(4, 'audit_retention_days', '90', 'Days to retain audit logs', NULL, '2025-05-26 22:03:43'),
(5, 'max_concurrent_sessions', '10', 'Maximum concurrent sessions per user', NULL, '2025-05-26 22:03:43');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` enum('admin','manager','operator') DEFAULT 'operator',
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `role`, `is_active`, `last_login`, `created_at`, `updated_at`, `created_by`) VALUES
(1, 'admin', '$2y$10$CbcUnO1/A58cRKiGXOJLo.dV3WHYBdvbUOkGT.GBf/3SO/2KGr9Fu', 'System Administrator', 'admin@ghostcrew.local', 'admin', 1, '2025-05-29 18:58:21', '2025-05-26 22:03:43', '2025-05-29 18:58:21', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_instance_tokens`
--

CREATE TABLE `user_instance_tokens` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `instance_token` varchar(128) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_instance_tokens`
--

INSERT INTO `user_instance_tokens` (`id`, `user_id`, `instance_token`, `created_at`, `expires_at`, `is_active`) VALUES
(1, 1, 'inst_1_1748545101_504cb8c943086020bf1d13522ee109c1', '2025-05-29 18:58:21', '2025-05-30 02:58:21', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `session_token` varchar(128) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `login_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `logout_time` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_sessions`
--

INSERT INTO `user_sessions` (`id`, `user_id`, `session_token`, `ip_address`, `user_agent`, `login_time`, `last_activity`, `logout_time`, `is_active`) VALUES
(1, 1, 'b84c368e5538a4d6615e07602c1a0243ac09bd3fff333136eb8172e6537375d8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', '2025-05-29 18:58:21', '2025-05-29 20:24:37', NULL, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_audit` (`user_id`,`timestamp`),
  ADD KEY `idx_action_time` (`action_type`,`timestamp`);

--
-- Indexes for table `chatbot_conversations`
--
ALTER TABLE `chatbot_conversations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_conversation` (`user_id`,`conversation_id`,`timestamp`),
  ADD KEY `idx_session_chat` (`session_id`,`timestamp`),
  ADD KEY `idx_flagged_review` (`flagged`,`timestamp`),
  ADD KEY `idx_parent_message` (`parent_message_id`),
  ADD KEY `idx_conversation_thread` (`conversation_id`,`timestamp`),
  ADD KEY `idx_conversation_messages` (`conversation_id`,`timestamp`),
  ADD KEY `idx_user_conversations` (`user_id`,`timestamp`),
  ADD KEY `idx_message_search` (`message_type`,`timestamp`);

--
-- Indexes for table `chatbot_feedback`
--
ALTER TABLE `chatbot_feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conversation_feedback` (`conversation_id`,`created_at`),
  ADD KEY `idx_message_feedback` (`message_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `chatbot_knowledge_base`
--
ALTER TABLE `chatbot_knowledge_base`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_category` (`category`,`is_active`),
  ADD KEY `idx_keywords` (`keywords`(255));
ALTER TABLE `chatbot_knowledge_base` ADD FULLTEXT KEY `idx_question_answer` (`question`,`answer`,`keywords`);

--
-- Indexes for table `command_log`
--
ALTER TABLE `command_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_session_time` (`session_id`,`timestamp`),
  ADD KEY `idx_user_commands` (`user_id`,`timestamp`);

--
-- Indexes for table `command_patterns`
--
ALTER TABLE `command_patterns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pattern_category` (`category`,`is_active`,`priority`),
  ADD KEY `idx_pattern_active` (`is_active`,`priority`);

--
-- Indexes for table `command_suggestions`
--
ALTER TABLE `command_suggestions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conversation_suggestions` (`conversation_id`,`created_at`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_executed_suggestions` (`executed`,`created_at`),
  ADD KEY `idx_user_suggestions` (`user_id`,`executed`,`created_at`),
  ADD KEY `idx_priority_category` (`category`,`priority`,`created_at`);

--
-- Indexes for table `hosts_info`
--
ALTER TABLE `hosts_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `host_id` (`host_id`),
  ADD KEY `idx_host_activity` (`is_active`,`last_seen`);

--
-- Indexes for table `remote_sessions`
--
ALTER TABLE `remote_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_id` (`session_id`),
  ADD KEY `idx_user_host` (`user_id`,`host_id`),
  ADD KEY `idx_session_status` (`status`,`start_time`);

--
-- Indexes for table `session_contexts`
--
ALTER TABLE `session_contexts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_session_context` (`session_id`,`conversation_id`,`context_type`),
  ADD KEY `idx_session_context` (`session_id`,`context_type`),
  ADD KEY `idx_context_lookup` (`session_id`,`context_type`,`updated_at`);

--
-- Indexes for table `system_config`
--
ALTER TABLE `system_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `config_key` (`config_key`),
  ADD KEY `updated_by` (`updated_by`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `user_instance_tokens`
--
ALTER TABLE `user_instance_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `instance_token` (`instance_token`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_token` (`session_token`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `chatbot_conversations`
--
ALTER TABLE `chatbot_conversations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `chatbot_feedback`
--
ALTER TABLE `chatbot_feedback`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chatbot_knowledge_base`
--
ALTER TABLE `chatbot_knowledge_base`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT for table `command_log`
--
ALTER TABLE `command_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `command_patterns`
--
ALTER TABLE `command_patterns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `command_suggestions`
--
ALTER TABLE `command_suggestions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `hosts_info`
--
ALTER TABLE `hosts_info`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `remote_sessions`
--
ALTER TABLE `remote_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `session_contexts`
--
ALTER TABLE `session_contexts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `system_config`
--
ALTER TABLE `system_config`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_instance_tokens`
--
ALTER TABLE `user_instance_tokens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD CONSTRAINT `audit_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `chatbot_conversations`
--
ALTER TABLE `chatbot_conversations`
  ADD CONSTRAINT `chatbot_conversations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chatbot_conversations_ibfk_2` FOREIGN KEY (`session_id`) REFERENCES `remote_sessions` (`session_id`) ON DELETE SET NULL;

--
-- Constraints for table `chatbot_feedback`
--
ALTER TABLE `chatbot_feedback`
  ADD CONSTRAINT `chatbot_feedback_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chatbot_feedback_ibfk_2` FOREIGN KEY (`message_id`) REFERENCES `chatbot_conversations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `command_log`
--
ALTER TABLE `command_log`
  ADD CONSTRAINT `command_log_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `remote_sessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `command_log_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `command_suggestions`
--
ALTER TABLE `command_suggestions`
  ADD CONSTRAINT `command_suggestions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `remote_sessions`
--
ALTER TABLE `remote_sessions`
  ADD CONSTRAINT `remote_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `session_contexts`
--
ALTER TABLE `session_contexts`
  ADD CONSTRAINT `session_contexts_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `remote_sessions` (`session_id`) ON DELETE CASCADE;

--
-- Constraints for table `system_config`
--
ALTER TABLE `system_config`
  ADD CONSTRAINT `system_config_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_instance_tokens`
--
ALTER TABLE `user_instance_tokens`
  ADD CONSTRAINT `user_instance_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;
