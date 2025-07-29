<?php
// test_summary.php - Remove this file after testing

// Include your database connection or the SessionSummaryGenerator class
require_once 'generate_session_summary.php';

if (!defined('ADMIN_DB_HOST')) {
    define('ADMIN_DB_HOST', '192.168.1.171');
}
if (!defined('ADMIN_DB_USER')) {
    define('ADMIN_DB_USER', 'svc_ghostcrew_admin');
}
if (!defined('ADMIN_DB_PASS')) {
    define('ADMIN_DB_PASS', '!Password123!');
}
if (!defined('ADMIN_DB_NAME')) {
    define('ADMIN_DB_NAME', 'ghostcrew_admin');
}

// Database configuration
$host = ADMIN_DB_HOST;
$username = ADMIN_DB_USER;
$password = ADMIN_DB_PASS;
$dbname = ADMIN_DB_NAME;

echo "<h2>Session Summary Generator Test</h2>";

try {
    $processor = new SessionSummaryGenerator();
    
    echo "<h3>Before Processing:</h3>";
    
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
        
    $stmt = $pdo->query("
        SELECT rs.session_id, rs.hostname, rs.end_time, ss.session_id as has_summary
        FROM remote_sessions rs
        LEFT JOIN session_summaries ss ON rs.session_id = ss.session_id
        WHERE rs.status = 'terminated'
        ORDER BY rs.end_time DESC
        LIMIT 10
    ");
    
    echo "<table border='1'>";
    echo "<tr><th>Session ID</th><th>Hostname</th><th>End Time</th><th>Has Summary</th></tr>";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "<tr>";
        echo "<td>" . htmlspecialchars($row['session_id']) . "</td>";
        echo "<td>" . htmlspecialchars($row['hostname']) . "</td>";
        echo "<td>" . $row['end_time'] . "</td>";
        echo "<td>" . ($row['has_summary'] ? 'Yes' : 'No') . "</td>";
        echo "</tr>";
    }
    echo "</table>";
    
    echo "<h3>Processing...</h3>";
    ob_flush();
    flush();
    
    // Run the processor
    $processor->processTerminatedSessions();
    
    echo "<h3>Done!</h3>";
    echo "<a href='test_summary.php'>Refresh to see results</a>";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>Error: " . htmlspecialchars($e->getMessage()) . "</p>";
}
?>