<?php

/* api.php - Enhanced with improved chatbot integration */

// Enable error logging for debugging
ini_set('log_errors', 1);
ini_set('error_log', 'php_errors.log');
error_reporting(E_ALL);

// Enhanced API with authentication and session management
require_once 'config.php';
require_once 'auth_config.php';
require_once 'chatbot_engine.php';

// Set header to return JSON
header('Content-Type: application/json');

// Get the action from the request
$action = isset($_REQUEST['action']) ? sanitize($_REQUEST['action']) : '';

// Define which actions don't require authentication (for HTA clients)
$unauthenticatedActions = ['register_host', 'ping_host', 'get_command', 'submit_result'];

// Only require authentication for web-based actions
if (!in_array($action, $unauthenticatedActions) && !isset($_REQUEST['internal_call'])) {
    requireAuth();
}

// Handle different API actions
switch ($action) {
    case 'register_host':
        registerHost();
        break;
        
    case 'ping_host':
        pingHost();
        break;
        
    case 'get_hosts':
        getHosts();
        break;
        
    case 'send_command':
        sendCommand();
        break;
        
    case 'get_command':
        getCommand();
        break;
        
    case 'submit_result':
        submitResult();
        break;
        
    case 'get_system_info':
        getSystemInfo();
        break;
        
    case 'get_command_history':
        getCommandHistory();
        break;
        
    case 'start_session':
        startSession();
        break;
        
    case 'end_session':
        endSession();
        break;
        
    case 'get_historical_sessions':
        getHistoricalSessions();
        break;
        
    case 'get_session_history':
        getSessionHistory();
        break;
        
    case 'chat_message':
        handleChatMessage();
        break;
        
    case 'get_chat_history':
        getChatHistory();
        break;
        
    case 'execute_suggested_command':
        executeSuggestedCommand();
        break;
        
    case 'get_setup_command':
        getSetupCommand();
        break;
        
    case 'rate_chat_message':
        rateChatMessage();
        break;
        
    case 'get_command_suggestions':
        getCommandSuggestions();
        break;
        
    case 'ping_session':
        pingSession();
        break;

    case 'log_terminal_clear':
        logTerminalClear();
        break;
        
    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
        break;
}

// Function to ping session (keep alive)
function pingSession() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    echo json_encode(['status' => 'success', 'message' => 'Session refreshed']);
}

// Function to get setup command with instance token
function getSetupCommand() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $instanceToken = getCurrentInstanceToken();
    if (!$instanceToken) {
        echo json_encode(['status' => 'error', 'message' => 'Failed to generate instance token']);
        return;
    }
    
    $setupUrl = APP_URL . "/local/autoconnect.hta?token=" . urlencode($instanceToken);
    
    echo json_encode([
        'status' => 'success',
        'command' => "mshta \"$setupUrl\"",
        'instance_token' => $instanceToken
    ]);
}

// Function to register a new host
function registerHost() {
    global $conn;
    
    // Get host information from the request
    $hostId = isset($_POST['host_id']) ? sanitize($_POST['host_id']) : uniqid('host_');
    $hostname = isset($_POST['hostname']) ? sanitize($_POST['hostname']) : 'Unknown';
    $ipAddress = isset($_POST['ip_address']) ? sanitize($_POST['ip_address']) : $_SERVER['REMOTE_ADDR'];
    $osInfo = isset($_POST['os_info']) ? sanitize($_POST['os_info']) : 'Unknown';
    $instanceToken = isset($_POST['instance_token']) ? sanitize($_POST['instance_token']) : '';
    
    // Validate instance token if provided
    $userId = null;
    if (!empty($instanceToken)) {
        if (!validateInstanceToken($instanceToken)) {
            echo json_encode(['status' => 'error', 'message' => 'Invalid or expired instance token']);
            return;
        }
        
        // Get user ID from instance token
        $adminDb = getAdminDB();
        $stmt = $adminDb->prepare("SELECT user_id FROM user_instance_tokens WHERE instance_token = ? AND is_active = 1");
        $stmt->bind_param("s", $instanceToken);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($result->num_rows > 0) {
            $userId = $result->fetch_assoc()['user_id'];
        }
    }
    
    // Check if the host already exists in the main database
    $stmt = $conn->prepare("SELECT id FROM hosts WHERE host_id = ?");
    $stmt->bind_param("s", $hostId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        // Update existing host
        $stmt = $conn->prepare("UPDATE hosts SET hostname = ?, ip_address = ?, os_info = ?, connected = 1, last_seen = CURRENT_TIMESTAMP WHERE host_id = ?");
        $stmt->bind_param("ssss", $hostname, $ipAddress, $osInfo, $hostId);
    } else {
        // Insert new host
        $stmt = $conn->prepare("INSERT INTO hosts (host_id, hostname, ip_address, os_info) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $hostId, $hostname, $ipAddress, $osInfo);
    }
    
    if ($stmt->execute()) {
        // Map host to instance token if provided
        if (!empty($instanceToken) && $userId) {
            $expiresAt = date('Y-m-d H:i:s', time() + INSTANCE_TOKEN_LIFETIME);
            $stmt = $conn->prepare("INSERT INTO host_instance_mappings (host_id, instance_token, user_id, expires_at) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE user_id = VALUES(user_id), expires_at = VALUES(expires_at), is_active = 1");
            $stmt->bind_param("ssis", $hostId, $instanceToken, $userId, $expiresAt);
            $stmt->execute();
        }
        
        // Also update/insert in admin database for tracking
        $adminDb = getAdminDB();
        $adminStmt = $adminDb->prepare("INSERT INTO hosts_info (host_id, hostname, ip_address, os_info) 
                                       VALUES (?, ?, ?, ?) 
                                       ON DUPLICATE KEY UPDATE 
                                       hostname = VALUES(hostname), 
                                       ip_address = VALUES(ip_address), 
                                       os_info = VALUES(os_info), 
                                       last_seen = CURRENT_TIMESTAMP,
                                       is_active = 1");
        $adminStmt->bind_param("ssss", $hostId, $hostname, $ipAddress, $osInfo);
        $adminStmt->execute();
        
        echo json_encode(['status' => 'success', 'host_id' => $hostId]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to register host']);
    }
    
    $stmt->close();
}

// Function to ping a host
function pingHost() {
    global $conn;
    
    $hostId = isset($_POST['host_id']) ? sanitize($_POST['host_id']) : '';
    $instanceToken = isset($_POST['instance_token']) ? sanitize($_POST['instance_token']) : '';
    
    if (empty($hostId)) {
        echo json_encode(['status' => 'error', 'message' => 'Host ID is required']);
        return;
    }
    
    // Update host's last seen timestamp
    $stmt = $conn->prepare("UPDATE hosts SET last_seen = CURRENT_TIMESTAMP, connected = 1 WHERE host_id = ?");
    $stmt->bind_param("s", $hostId);
    
    if ($stmt->execute()) {
        // Update instance mapping if token provided
        if (!empty($instanceToken)) {
            $stmt = $conn->prepare("UPDATE host_instance_mappings SET mapped_at = CURRENT_TIMESTAMP WHERE host_id = ? AND instance_token = ? AND is_active = 1");
            $stmt->bind_param("ss", $hostId, $instanceToken);
            $stmt->execute();
        }
        
        // Also update admin database
        $adminDb = getAdminDB();
        $adminStmt = $adminDb->prepare("UPDATE hosts_info SET last_seen = CURRENT_TIMESTAMP, is_active = 1 WHERE host_id = ?");
        $adminStmt->bind_param("s", $hostId);
        $adminStmt->execute();
        
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to update host status']);
    }
    
    $stmt->close();
}

// Function to get all connected hosts (filtered by user's instance token)
function getHosts() {
    global $conn;
    
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $instanceToken = getCurrentInstanceToken();
    if (!$instanceToken) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid instance token']);
        return;
    }
    
    // Get hosts mapped to this user's instance token
    $sql = "SELECT h.*, him.mapped_at 
            FROM hosts h 
            LEFT JOIN host_instance_mappings him ON h.host_id = him.host_id 
            WHERE h.connected = 1 
            AND h.last_seen > DATE_SUB(NOW(), INTERVAL 5 MINUTE)
            AND (him.instance_token = ? AND him.is_active = 1 AND him.expires_at > NOW())
            ORDER BY h.last_seen DESC";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $instanceToken);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $hosts = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            // Calculate seconds since last seen
            $lastSeen = strtotime($row['last_seen']);
            $now = time();
            $secondsSinceLastSeen = $now - $lastSeen;
            
            // Add this information to the host data
            $row['seconds_since_last_seen'] = $secondsSinceLastSeen;
            
            $hosts[] = $row;
        }
    }
    
    echo json_encode(['status' => 'success', 'hosts' => $hosts]);
}

// Function to start a new session
function startSession() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $hostId = isset($_POST['host_id']) ? sanitize($_POST['host_id']) : '';
    
    if (empty($hostId)) {
        echo json_encode(['status' => 'error', 'message' => 'Host ID is required']);
        return;
    }
    
    // Verify user has access to this host
    $instanceToken = getCurrentInstanceToken();
    $stmt = $GLOBALS['conn']->prepare("SELECT h.* FROM hosts h 
                                      JOIN host_instance_mappings him ON h.host_id = him.host_id 
                                      WHERE h.host_id = ? AND him.instance_token = ? AND him.is_active = 1");
    $stmt->bind_param("ss", $hostId, $instanceToken);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['status' => 'error', 'message' => 'Host not found or access denied']);
        return;
    }
    
    $host = $result->fetch_assoc();
    
    // Generate unique session ID
    $sessionId = generateSessionId();
    
    // Create session in admin database
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("INSERT INTO remote_sessions (session_id, user_id, host_id, hostname, ip_address, os_info) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sissss", $sessionId, $user['id'], $hostId, $host['hostname'], $host['ip_address'], $host['os_info']);
    
    if ($stmt->execute()) {
        // Log audit event
        logAuditEvent($user['id'], 'session_start', [
            'session_id' => $sessionId,
            'host_id' => $hostId,
            'hostname' => $host['hostname'],
            'ip_address' => $host['ip_address']
        ]);
        
        echo json_encode([
            'status' => 'success', 
            'session_id' => $sessionId,
            'host' => $host
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to create session']);
    }
}

// Function to update command statistics
function updateCommandStatistics($hostId, $command, $executionTime, $success) {
    global $conn;
    
    $commandBase = strtolower(explode(' ', trim($command))[0]);
    
    $stmt = $conn->prepare("
        INSERT INTO command_statistics (host_id, command_base, execution_count, avg_execution_time, success_rate) 
        VALUES (?, ?, 1, ?, ?) 
        ON DUPLICATE KEY UPDATE 
        execution_count = execution_count + 1,
        avg_execution_time = (avg_execution_time * (execution_count - 1) + ?) / execution_count,
        success_rate = (success_rate * (execution_count - 1) + ?) / execution_count
    ");
    
    $successRate = $success ? 100.0 : 0.0;
    $stmt->bind_param("ssdddd", $hostId, $commandBase, $executionTime, $successRate, $executionTime, $successRate);
    $stmt->execute();
}

// Function to get system information
function getSystemInfo() {
    global $conn;
    
    $hostCount = 0;
    $commandCount = 0;
    $activeSessionCount = 0;
    
    $user = getCurrentUser();
    $instanceToken = getCurrentInstanceToken();
    
    // Get the count of connected hosts for this user
    if ($instanceToken) {
        $sql = "SELECT COUNT(DISTINCT h.id) as host_count 
                FROM hosts h 
                JOIN host_instance_mappings him ON h.host_id = him.host_id 
                WHERE h.connected = 1 AND him.instance_token = ? AND him.is_active = 1";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $instanceToken);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($result->num_rows > 0) {
            $hostCount = $result->fetch_assoc()['host_count'];
        }
    }
    
    // Get the count of commands executed by this user
    if ($user) {
        $adminDb = getAdminDB();
        $stmt = $adminDb->prepare("SELECT COUNT(*) as command_count FROM command_log WHERE user_id = ?");
        $stmt->bind_param("i", $user['id']);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($result->num_rows > 0) {
            $commandCount = $result->fetch_assoc()['command_count'];
        }
        
        // Get active session count
        $stmt = $adminDb->prepare("SELECT COUNT(*) as session_count FROM remote_sessions WHERE status = 'active' AND user_id = ?");
        $stmt->bind_param("i", $user['id']);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($result->num_rows > 0) {
            $activeSessionCount = $result->fetch_assoc()['session_count'];
        }
    }
    
    // Get server information
    $serverInfo = [
        'php_version' => PHP_VERSION,
        'server_software' => $_SERVER['SERVER_SOFTWARE'],
        'server_name' => $_SERVER['SERVER_NAME'],
        'document_root' => $_SERVER['DOCUMENT_ROOT'],
        'user' => $user ? $user['username'] : 'Unknown'
    ];
    
    echo json_encode([
        'status' => 'success',
        'host_count' => $hostCount,
        'command_count' => $commandCount,
        'active_sessions' => $activeSessionCount,
        'server_info' => $serverInfo
    ]);
}

// Function to get command history for a session
function getCommandHistory() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    $limit = isset($_POST['limit']) ? (int)$_POST['limit'] : 50;
    
    if (empty($sessionId)) {
        echo json_encode(['status' => 'error', 'message' => 'Session ID is required']);
        return;
    }
    
    // Get the command history for the session
    global $conn;
    $stmt = $conn->prepare("SELECT id, command, output, timestamp, execution_time, working_directory, exit_code FROM command_history 
                           WHERE session_id = ? 
                           ORDER BY timestamp DESC LIMIT ?");
    $stmt->bind_param("si", $sessionId, $limit);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $commands = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $commands[] = $row;
        }
    }
    
    echo json_encode(['status' => 'success', 'commands' => $commands]);
    
    $stmt->close();
}

// Function to get historical sessions for current user
function getHistoricalSessions() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("SELECT session_id, host_id, hostname, ip_address, start_time, end_time, status, total_commands 
                              FROM remote_sessions 
                              WHERE user_id = ? AND status != 'active'
                              ORDER BY start_time DESC 
                              LIMIT 100");
    $stmt->bind_param("i", $user['id']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $sessions = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $sessions[] = $row;
        }
    }
    
    echo json_encode(['status' => 'success', 'sessions' => $sessions]);
}

// Function to get session history (read-only)
function getSessionHistory() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    
    if (empty($sessionId)) {
        echo json_encode(['status' => 'error', 'message' => 'Session ID is required']);
        return;
    }
    
    // Verify user owns this session or has appropriate permissions
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("SELECT * FROM remote_sessions WHERE session_id = ? AND (user_id = ? OR ? = 'admin')");
    $stmt->bind_param("sis", $sessionId, $user['id'], $user['role']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['status' => 'error', 'message' => 'Session not found or access denied']);
        return;
    }
    
    $sessionInfo = $result->fetch_assoc();
    
    // Get command history
    $stmt = $adminDb->prepare("SELECT command, output, timestamp, execution_time, status 
                              FROM command_log 
                              WHERE session_id = ? 
                              ORDER BY timestamp ASC");
    $stmt->bind_param("s", $sessionId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $commands = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $commands[] = $row;
        }
    }
    
    echo json_encode([
        'status' => 'success', 
        'session' => $sessionInfo,
        'commands' => $commands,
        'readonly' => true
    ]);
}

// Enhanced function to handle chat messages
function handleChatMessage() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    $message = isset($_POST['message']) ? trim($_POST['message']) : '';
    
    if (empty($message)) {
        echo json_encode(['status' => 'error', 'message' => 'Message is required']);
        return;
    }
    
    try {
        // Initialize chatbot engine
        $chatbot = new ChatbotEngine($user['id'], $sessionId);
        
        // Get session context
        $context = $chatbot->getSessionContext();
        
        // Process the message
        $response = $chatbot->processMessage($message, $context);
        
        echo json_encode([
            'status' => 'success',
            'message_id' => $response['message_id'],
            'bot_message_id' => $response['bot_message_id'],
            'bot_response' => $response['bot_response'],
            'suggested_command' => $response['suggested_command'],
            'command_description' => $response['command_description'],
            'suggestion_id' => $response['suggestion_id'],
            'category' => $response['category'] ?? 'general',
            'response_time' => $response['response_time']
        ]);
        
    } catch (Exception $e) {
        error_log("Chatbot error: " . $e->getMessage());
        echo json_encode([
            'status' => 'error',
            'message' => 'Sorry, I encountered an error processing your request. Please try again.',
            'bot_response' => 'I apologize, but I\'m having technical difficulties right now. Please try asking your question again.'
        ]);
    }
}

// Function to get chat history
function getChatHistory() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    $limit = isset($_POST['limit']) ? (int)$_POST['limit'] : 50;
    
    if (empty($sessionId)) {
        echo json_encode(['status' => 'error', 'message' => 'Session ID is required']);
        return;
    }
    
    try {
        $messages = getChatbotHistory($sessionId, $user['id'], $limit);
        echo json_encode(['status' => 'success', 'messages' => $messages]);
    } catch (Exception $e) {
        error_log("Get chat history error: " . $e->getMessage());
        echo json_encode(['status' => 'error', 'message' => 'Failed to load chat history']);
    }
}

// Function to execute suggested command
function executeSuggestedCommand() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $suggestionId = isset($_POST['suggestion_id']) ? (int)$_POST['suggestion_id'] : 0;
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    $hostId = isset($_POST['host_id']) ? sanitize($_POST['host_id']) : '';
    
    if ($suggestionId <= 0 || empty($sessionId) || empty($hostId)) {
        echo json_encode(['status' => 'error', 'message' => 'Suggestion ID, session ID, and host ID are required']);
        return;
    }
    
    // Get the suggested command
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("SELECT suggested_command FROM command_suggestions WHERE id = ? AND user_id = ? AND executed = 0");
    $stmt->bind_param("ii", $suggestionId, $user['id']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['status' => 'error', 'message' => 'Suggestion not found or already executed']);
        return;
    }
    
    $suggestion = $result->fetch_assoc();
    $command = $suggestion['suggested_command'];
    
    // Mark suggestion as executed
    executeChatbotSuggestion($suggestionId, $sessionId, $hostId, $user['id']);
    
    // Execute the command using existing sendCommand logic
    $_POST['host_id'] = $hostId;
    $_POST['command'] = $command;
    $_POST['session_id'] = $sessionId;
    
    sendCommand();
}

// Function to rate chat message
function rateChatMessage() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $messageId = isset($_POST['message_id']) ? (int)$_POST['message_id'] : 0;
    $rating = isset($_POST['rating']) ? (int)$_POST['rating'] : 0;
    
    if ($messageId <= 0 || ($rating < 1 || $rating > 5)) {
        echo json_encode(['status' => 'error', 'message' => 'Valid message ID and rating (1-5) are required']);
        return;
    }
    
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("UPDATE chatbot_conversations SET rating = ? WHERE id = ? AND user_id = ?");
    $stmt->bind_param("iii", $rating, $messageId, $user['id']);
    
    if ($stmt->execute() && $stmt->affected_rows > 0) {
        echo json_encode(['status' => 'success', 'message' => 'Rating saved']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to save rating']);
    }
}

// Function to get command suggestions
function getCommandSuggestions() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    $limit = isset($_POST['limit']) ? (int)$_POST['limit'] : 10;
    
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("
        SELECT cs.*, cc.conversation_id 
        FROM command_suggestions cs
        LEFT JOIN chatbot_conversations cc ON cs.conversation_id = cc.conversation_id
        WHERE cs.user_id = ? AND cs.executed = 0
        " . ($sessionId ? "AND cc.session_id = ?" : "") . "
        ORDER BY cs.priority DESC, cs.created_at DESC
        LIMIT ?
    ");
    
    if ($sessionId) {
        $stmt->bind_param("isi", $user['id'], $sessionId, $limit);
    } else {
        $stmt->bind_param("ii", $user['id'], $limit);
    }
    
    $stmt->execute();
    $result = $stmt->get_result();
    
    $suggestions = [];
    while ($row = $result->fetch_assoc()) {
        $suggestions[] = $row;
    }
    
    echo json_encode(['status' => 'success', 'suggestions' => $suggestions]);
}
// Function to end a session
function endSession() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    
    if (empty($sessionId)) {
        echo json_encode(['status' => 'error', 'message' => 'Session ID is required']);
        return;
    }
    
    // End session in admin database
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("UPDATE remote_sessions SET end_time = CURRENT_TIMESTAMP, status = 'terminated' WHERE session_id = ? AND user_id = ?");
    $stmt->bind_param("si", $sessionId, $user['id']);
    
    if ($stmt->execute()) {
        // Log audit event
        logAuditEvent($user['id'], 'session_end', [
            'session_id' => $sessionId,
            'end_type' => 'manual'
        ]);
        
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to end session']);
    }
}

// Function to send a command to a host with persistent shell
function sendCommand() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $hostId = isset($_POST['host_id']) ? sanitize($_POST['host_id']) : '';
    $command = isset($_POST['command']) ? $_POST['command'] : '';
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    
    if (empty($hostId) || empty($command) || empty($sessionId)) {
        echo json_encode(['status' => 'error', 'message' => 'Host ID, command, and session ID are required']);
        return;
    }
    
    // Store the command in the main database with session context
    global $conn;
    $stmt = $conn->prepare("INSERT INTO command_history (host_id, command, session_id) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $hostId, $command, $sessionId);
    
    if ($stmt->execute()) {
        $commandId = $stmt->insert_id;
        
        // Log command in admin database
        $adminDb = getAdminDB();
        $adminStmt = $adminDb->prepare("INSERT INTO command_log (session_id, user_id, command, status) VALUES (?, ?, ?, 'pending')");
        $adminStmt->bind_param("sis", $sessionId, $user['id'], $command);
        $adminStmt->execute();
        
        // Update session activity
        $adminStmt = $adminDb->prepare("UPDATE remote_sessions SET last_activity = CURRENT_TIMESTAMP, total_commands = total_commands + 1 WHERE session_id = ?");
        $adminStmt->bind_param("s", $sessionId);
        $adminStmt->execute();
        
        // Log audit event
        logAuditEvent($user['id'], 'command_execute', [
            'session_id' => $sessionId,
            'host_id' => $hostId,
            'command' => $command,
            'command_id' => $commandId
        ]);
        
        // Update session context for chatbot
        updateChatbotContext($sessionId, 'command_history', [
            'command' => $command,
            'timestamp' => date('Y-m-d H:i:s'),
            'status' => 'pending'
        ], $user['id']);
        
        echo json_encode(['status' => 'success', 'command_id' => $commandId]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to store command']);
    }
    
    $stmt->close();
}

// Function for a host to get pending commands (modified for persistent shell)
function getCommand() {
    global $conn;
    
    $hostId = isset($_POST['host_id']) ? sanitize($_POST['host_id']) : '';
    $instanceToken = isset($_POST['instance_token']) ? sanitize($_POST['instance_token']) : '';
    
    if (empty($hostId)) {
        echo json_encode(['status' => 'error', 'message' => 'Host ID is required']);
        return;
    }
    
    // Validate instance token if provided
    if (!empty($instanceToken) && !validateInstanceToken($instanceToken)) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid or expired instance token']);
        return;
    }
    
    // Update host's last seen timestamp
    $stmt = $conn->prepare("UPDATE hosts SET last_seen = CURRENT_TIMESTAMP WHERE host_id = ?");
    if ($stmt) {
        $stmt->bind_param("s", $hostId);
        $stmt->execute();
        $stmt->close();
    }
    
    // Get the oldest command without output
    $sql = "SELECT id, command, session_id FROM command_history 
            WHERE host_id = ? AND output IS NULL 
            ORDER BY timestamp ASC LIMIT 1";
    
    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        echo json_encode(['status' => 'error', 'message' => 'Database prepare error: ' . $conn->error]);
        return;
    }
    
    $stmt->bind_param("s", $hostId);
    
    if (!$stmt->execute()) {
        echo json_encode(['status' => 'error', 'message' => 'Query execution failed: ' . $stmt->error]);
        $stmt->close();
        return;
    }
    
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $response = [
            'status' => 'success', 
            'command_id' => $row['id'], 
            'command' => $row['command'],
            'session_id' => $row['session_id'] ?? ''
        ];
        
        echo json_encode($response);
    } else {
        echo json_encode([
            'status' => 'success', 
            'command_id' => 0, 
            'command' => '',
            'session_id' => ''
        ]);
    }
    
    $stmt->close();
}

// Function for a host to submit command results
function submitResult() {
    global $conn;
    
    $commandId = isset($_POST['command_id']) ? (int)$_POST['command_id'] : 0;
    $output = isset($_POST['output']) ? $_POST['output'] : '';
    $executionTime = isset($_POST['execution_time']) ? (float)$_POST['execution_time'] : null;
    $workingDirectory = isset($_POST['working_directory']) ? sanitize($_POST['working_directory']) : null;
    $exitCode = isset($_POST['exit_code']) ? (int)$_POST['exit_code'] : null;
    
    if ($commandId <= 0) {
        echo json_encode(['status' => 'error', 'message' => 'Command ID is required']);
        return;
    }
    
    // Get command details for logging
    $stmt = $conn->prepare("SELECT command, session_id, host_id FROM command_history WHERE id = ?");
    $stmt->bind_param("i", $commandId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['status' => 'error', 'message' => 'Command not found']);
        return;
    }
    
    $commandData = $result->fetch_assoc();
    
    // Store the command output in the main database
    $stmt = $conn->prepare("UPDATE command_history SET output = ?, execution_time = ?, working_directory = ?, exit_code = ?, response_timestamp = CURRENT_TIMESTAMP WHERE id = ?");
    $stmt->bind_param("sdsii", $output, $executionTime, $workingDirectory, $exitCode, $commandId);
    
    if ($stmt->execute()) {
        // Update admin database
        $adminDb = getAdminDB();
        $adminStmt = $adminDb->prepare("UPDATE command_log SET output = ?, execution_time = ?, status = 'completed', response_timestamp = CURRENT_TIMESTAMP WHERE session_id = ? AND command = ?");
        $adminStmt->bind_param("sdss", $output, $executionTime, $commandData['session_id'], $commandData['command']);
        $adminStmt->execute();
        
        // Update command statistics
        updateCommandStatistics($commandData['host_id'], $commandData['command'], $executionTime, $exitCode === 0);
        
        // Update session context for chatbot
        if (!empty($commandData['session_id'])) {
            updateChatbotContext($commandData['session_id'], 'command_history', [
                'command' => $commandData['command'],
                'output' => $output,
                'working_directory' => $workingDirectory,
                'exit_code' => $exitCode,
                'execution_time' => $executionTime,
                'timestamp' => date('Y-m-d H:i:s'),
                'status' => 'completed'
            ]);
            
            // Update working directory context
            if (!empty($workingDirectory)) {
                updateChatbotContext($commandData['session_id'], 'working_directory', [
                    'current_directory' => $workingDirectory,
                    'updated_at' => date('Y-m-d H:i:s')
                ]);
            }
        }
        
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to store command output']);
    }
    
    $stmt->close();
}
// Function to mark suggestion as used (but not executed)
function markSuggestionUsed() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $suggestionId = isset($_POST['suggestion_id']) ? (int)$_POST['suggestion_id'] : 0;
    
    if ($suggestionId <= 0) {
        echo json_encode(['status' => 'error', 'message' => 'Valid suggestion ID required']);
        return;
    }
    
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("UPDATE command_suggestions SET executed = 1, executed_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?");
    $stmt->bind_param("ii", $suggestionId, $user['id']);
    
    if ($stmt->execute() && $stmt->affected_rows > 0) {
        echo json_encode(['status' => 'success', 'message' => 'Suggestion marked as used']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to mark suggestion']);
    }
}

// Function to log terminal clear action
function logTerminalClear() {
    $user = getCurrentUser();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'Authentication required']);
        return;
    }
    
    $sessionId = isset($_POST['session_id']) ? sanitize($_POST['session_id']) : '';
    
    if (empty($sessionId)) {
        echo json_encode(['status' => 'error', 'message' => 'Session ID is required']);
        return;
    }
    
    // Log the clear action in admin database
    $adminDb = getAdminDB();
    $stmt = $adminDb->prepare("INSERT INTO command_log (session_id, user_id, command, output, status) VALUES (?, ?, '--- user cleared terminal ---', 'Terminal display cleared by user', 'completed')");
    $stmt->bind_param("sis", $sessionId, $user['id']);
    
    if ($stmt->execute()) {
        // Log audit event
        logAuditEvent($user['id'], 'system_access', [
            'action' => 'terminal_clear',
            'session_id' => $sessionId
        ]);
        
        echo json_encode(['status' => 'success', 'message' => 'Terminal clear logged']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to log terminal clear']);
    }
}

?>