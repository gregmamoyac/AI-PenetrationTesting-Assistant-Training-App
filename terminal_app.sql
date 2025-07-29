REATE DATABASE IF NOT EXISTS `terminal_app` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `terminal_app`;

CREATE TABLE `command_history` (
  `id` int(11) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `session_id` varchar(64) DEFAULT NULL,
  `is_interactive` tinyint(1) DEFAULT 0,
  `working_directory` text DEFAULT NULL,
  `command` text NOT NULL,
  `output` longtext DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `execution_start` timestamp NULL DEFAULT NULL,
  `response_timestamp` timestamp NULL DEFAULT NULL,
  `execution_time` decimal(10,6) DEFAULT NULL,
  `exit_code` int(11) DEFAULT NULL,
  `status` enum('pending','executing','completed','failed','timeout') DEFAULT 'pending',
  `context_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `command_source` enum('terminal','interactive') DEFAULT 'terminal'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `command_statistics` (
  `id` int(11) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `command_base` varchar(100) NOT NULL,
  `execution_count` int(11) DEFAULT 1,
  `avg_execution_time` decimal(10,6) DEFAULT NULL,
  `last_executed` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `success_rate` decimal(5,2) DEFAULT 100.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `hosts` (
  `id` int(11) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `hostname` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `os_info` text DEFAULT NULL,
  `last_seen` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `connected` tinyint(1) DEFAULT 1,
  `first_seen` timestamp NOT NULL DEFAULT current_timestamp(),
  `total_sessions` int(11) DEFAULT 0,
  `total_commands` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `host_instance_mappings` (
  `id` int(11) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `instance_token` varchar(128) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `mapped_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `interactive_command_patterns` (
  `id` int(11) NOT NULL,
  `command_pattern` varchar(255) NOT NULL,
  `pattern_type` enum('exact','prefix','regex','contains') DEFAULT 'exact',
  `is_interactive` tinyint(1) DEFAULT 1,
  `is_continuous` tinyint(1) DEFAULT 0,
  `timeout_seconds` int(11) DEFAULT 1800,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `shell_sessions` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `current_directory` text DEFAULT NULL,
  `initial_directory` text DEFAULT NULL,
  `environment_vars` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `streaming_output` (
  `id` int(11) NOT NULL,
  `command_id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `output_chunk` longtext NOT NULL,
  `chunk_sequence` int(11) DEFAULT 1,
  `is_partial` tinyint(1) DEFAULT 1,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `streaming_sessions` (
  `id` int(11) NOT NULL,
  `command_id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `status` enum('active','paused','completed','terminated') DEFAULT 'active',
  `start_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `end_time` timestamp NULL DEFAULT NULL,
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `total_input_lines` int(11) DEFAULT 0,
  `total_output_size` bigint(20) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `user_input_queue` (
  `id` int(11) NOT NULL,
  `session_id` varchar(64) NOT NULL,
  `host_id` varchar(50) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `command_id` int(11) DEFAULT NULL,
  `input_data` text NOT NULL,
  `input_type` enum('command','response','ctrl_signal') DEFAULT 'response',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `processed` tinyint(1) DEFAULT 0,
  `processed_at` timestamp NULL DEFAULT NULL,
  `priority` tinyint(4) DEFAULT 5
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;