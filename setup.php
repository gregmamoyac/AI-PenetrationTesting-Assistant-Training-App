<?php
/* setup.php - Database setup and initial admin user creation */

// Include configuration files
require_once 'config.php';
require_once 'auth_config.php';

// Enable error reporting for setup
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Only allow setup if no users exist
$setupAllowed = true;
try {
    $adminDb = getAdminDB();
    $result = $adminDb->query("SELECT COUNT(*) as user_count FROM users");
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row['user_count'] > 0) {
            $setupAllowed = false;
        }
    }
} catch (Exception $e) {
    // Database tables don't exist yet, allow setup
    $setupAllowed = true;
}

$message = '';
$error = '';

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $setupAllowed) {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';
    $confirmPassword = $_POST['confirm_password'] ?? '';
    $fullName = trim($_POST['full_name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    
    // Validate input
    if (empty($username) || empty($password) || empty($fullName) || empty($email)) {
        $error = 'All fields are required.';
    } elseif ($password !== $confirmPassword) {
        $error = 'Passwords do not match.';
    } elseif (strlen($password) < 8) {
        $error = 'Password must be at least 8 characters long.';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $error = 'Please enter a valid email address.';
    } else {
        try {
            // Create admin user
            $adminDb = getAdminDB();
            $passwordHash = password_hash($password, PASSWORD_DEFAULT);
            
            $stmt = $adminDb->prepare("INSERT INTO users (username, password_hash, full_name, email, role, is_active) VALUES (?, ?, ?, ?, 'admin', 1)");
            $stmt->bind_param("ssss", $username, $passwordHash, $fullName, $email);
            
            if ($stmt->execute()) {
                $userId = $adminDb->insert_id;
                
                // Log the initial setup
                logAuditEvent($userId, 'system_access', [
                    'action' => 'initial_setup',
                    'admin_created' => true,
                    'setup_completed' => true
                ]);
                
                $message = 'Setup completed successfully! You can now login with your credentials.';
                $setupAllowed = false; // Prevent further setup attempts
            } else {
                $error = 'Failed to create admin user: ' . $adminDb->error;
            }
        } catch (Exception $e) {
            $error = 'Setup error: ' . $e->getMessage();
        }
    }
}

// Function to test database connections
function testDatabaseConnections() {
    $results = [];
    
    // Test main terminal database
    try {
        global $conn;
        $result = $conn->query("SELECT 1");
        $results['terminal_db'] = $result ? 'Connected' : 'Failed';
    } catch (Exception $e) {
        $results['terminal_db'] = 'Error: ' . $e->getMessage();
    }
    
    // Test admin database
    try {
        $adminDb = getAdminDB();
        $result = $adminDb->query("SELECT 1");
        $results['admin_db'] = $result ? 'Connected' : 'Failed';
    } catch (Exception $e) {
        $results['admin_db'] = 'Error: ' . $e->getMessage();
    }
    
    return $results;
}

// Function to check and create required tables
function checkAndCreateTables() {
    $results = [];
    
    try {
        // Check terminal database tables
        global $conn;
        $terminalTables = ['hosts', 'command_history', 'shell_sessions', 'host_instance_mappings'];
        
        foreach ($terminalTables as $table) {
            $result = $conn->query("SHOW TABLES LIKE '$table'");
            $results['terminal'][$table] = $result && $result->num_rows > 0 ? 'Exists' : 'Missing';
        }
        
        // Check admin database tables
        $adminDb = getAdminDB();
        $adminTables = [
            'users', 'user_sessions', 'user_instance_tokens', 'audit_log',
            'chatbot_conversations', 'command_suggestions', 'session_contexts',
            'remote_sessions', 'command_log', 'system_config', 'hosts_info'
        ];
        
        foreach ($adminTables as $table) {
            $result = $adminDb->query("SHOW TABLES LIKE '$table'");
            $results['admin'][$table] = $result && $result->num_rows > 0 ? 'Exists' : 'Missing';
        }
        
    } catch (Exception $e) {
        $results['error'] = $e->getMessage();
    }
    
    return $results;
}

$dbConnections = testDatabaseConnections();
$tableStatus = checkAndCreateTables();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GhostCrew - Initial Setup</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-dark: #0d1117;
            --secondary-dark: #161b22;
            --tertiary-dark: #21262d;
            --accent-blue: #58a6ff;
            --accent-green: #3fb950;
            --accent-red: #f85149;
            --text-primary: #f0f6fc;
            --text-secondary: #8b949e;
            --border-color: #30363d;
        }

        body {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--secondary-dark) 100%);
            color: var(--text-primary);
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            min-height: 100vh;
            padding: 20px 0;
        }

        .setup-container {
            background: linear-gradient(135deg, var(--tertiary-dark) 0%, var(--secondary-dark) 100%);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            max-width: 800px;
            margin: 0 auto;
        }

        .setup-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .setup-header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(45deg, var(--accent-blue), var(--accent-green));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
        }

        .setup-header h1::before {
            content: "👻";
            font-size: 2rem;
            -webkit-text-fill-color: initial;
            margin-right: 10px;
        }

        .status-section {
            background: var(--primary-dark);
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
        }

        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .status-item {
            padding: 12px;
            border-radius: 6px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .status-ok {
            background: rgba(63, 185, 80, 0.2);
            border: 1px solid rgba(63, 185, 80, 0.3);
            color: var(--accent-green);
        }

        .status-error {
            background: rgba(248, 81, 73, 0.2);
            border: 1px solid rgba(248, 81, 73, 0.3);
            color: var(--accent-red);
        }

        .form-control {
            background: var(--primary-dark);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            padding: 12px 16px;
            font-size: 1rem;
        }

        .form-control:focus {
            background: var(--primary-dark);
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 0.2rem rgba(88, 166, 255, 0.25);
            color: var(--text-primary);
        }

        .form-control::placeholder {
            color: var(--text-secondary);
        }

        .form-label {
            color: var(--text-primary);
            font-weight: 500;
            margin-bottom: 8px;
        }

        .btn-setup {
            background: linear-gradient(135deg, var(--accent-blue) 0%, rgba(88, 166, 255, 0.8) 100%);
            border: none;
            border-radius: 8px;
            color: white;
            font-weight: 600;
            padding: 12px 24px;
            font-size: 1rem;
            width: 100%;
            transition: all 0.3s ease;
        }

        .btn-setup:hover {
            background: linear-gradient(135deg, rgba(88, 166, 255, 0.9) 0%, var(--accent-blue) 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(88, 166, 255, 0.4);
        }

        .alert {
            border: none;
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 20px;
        }

        .alert-danger {
            background: rgba(248, 81, 73, 0.1);
            color: var(--accent-red);
            border: 1px solid rgba(248, 81, 73, 0.3);
        }

        .alert-success {
            background: rgba(63, 185, 80, 0.1);
            color: var(--accent-green);
            border: 1px solid rgba(63, 185, 80, 0.3);
        }

        .alert-info {
            background: rgba(88, 166, 255, 0.1);
            color: var(--accent-blue);
            border: 1px solid rgba(88, 166, 255, 0.3);
        }

        .setup-complete {
            text-align: center;
            padding: 40px;
        }

        .setup-complete h2 {
            color: var(--accent-green);
            margin-bottom: 20px;
        }

        .login-link {
            display: inline-block;
            background: linear-gradient(135deg, var(--accent-green) 0%, rgba(63, 185, 80, 0.8) 100%);
            color: white;
            text-decoration: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .login-link:hover {
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(63, 185, 80, 0.4);
        }

        .requirements-list {
            background: var(--primary-dark);
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .requirements-list h4 {
            color: var(--accent-blue);
            margin-bottom: 15px;
        }

        .requirements-list ul {
            color: var(--text-secondary);
            margin-bottom: 0;
        }

        .requirements-list li {
            margin-bottom: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="setup-container">
            <div class="setup-header">
                <h1>GhostCrew Setup</h1>
                <p class="text-secondary">Initial system configuration and admin user creation</p>
            </div>

            <?php if (!$setupAllowed): ?>
                <div class="setup-complete">
                    <h2><i class="fas fa-check-circle"></i> Setup Already Completed</h2>
                    <p>GhostCrew has already been set up. If you need to create additional users or modify settings, please login as an administrator.</p>
                    <a href="login.php" class="login-link">
                        <i class="fas fa-sign-in-alt me-2"></i>
                        Go to Login
                    </a>
                </div>
            <?php else: ?>
                
                <!-- System Status -->
                <div class="status-section">
                    <h3><i class="fas fa-server me-2"></i>System Status</h3>
                    
                    <h5 class="mt-3">Database Connections</h5>
                    <div class="status-grid">
                        <?php foreach ($dbConnections as $db => $status): ?>
                            <div class="status-item <?php echo strpos($status, 'Connected') !== false ? 'status-ok' : 'status-error'; ?>">
                                <span><?php echo ucfirst(str_replace('_', ' ', $db)); ?></span>
                                <span><?php echo $status; ?></span>
                            </div>
                        <?php endforeach; ?>
                    </div>

                    <h5 class="mt-3">Database Tables</h5>
                    <?php if (isset($tableStatus['terminal'])): ?>
                        <h6 class="mt-2 text-secondary">Terminal Database</h6>
                        <div class="status-grid">
                            <?php foreach ($tableStatus['terminal'] as $table => $status): ?>
                                <div class="status-item <?php echo $status === 'Exists' ? 'status-ok' : 'status-error'; ?>">
                                    <span><?php echo $table; ?></span>
                                    <span><?php echo $status; ?></span>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>

                    <?php if (isset($tableStatus['admin'])): ?>
                        <h6 class="mt-3 text-secondary">Admin Database</h6>
                        <div class="status-grid">
                            <?php foreach ($tableStatus['admin'] as $table => $status): ?>
                                <div class="status-item <?php echo $status === 'Exists' ? 'status-ok' : 'status-error'; ?>">
                                    <span><?php echo $table; ?></span>
                                    <span><?php echo $status; ?></span>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>

                <!-- Requirements -->
                <div class="requirements-list">
                    <h4><i class="fas fa-list-check me-2"></i>Requirements</h4>
                    <ul>
                        <li>PHP <?php echo PHP_VERSION; ?> or higher</li>
                        <li>MySQL/MariaDB database server</li>
                        <li>Web server (Apache/Nginx) with PHP support</li>
                        <li>Required PHP extensions: mysqli, json, openssl</li>
                        <li>Write permissions for session and log files</li>
                    </ul>
                </div>

                <?php if ($error): ?>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        <?php echo htmlspecialchars($error); ?>
                    </div>
                <?php endif; ?>

                <?php if ($message): ?>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle me-2"></i>
                        <?php echo htmlspecialchars($message); ?>
                        <div class="mt-3">
                            <a href="login.php" class="login-link">
                                <i class="fas fa-sign-in-alt me-2"></i>
                                Go to Login
                            </a>
                        </div>
                    </div>
                <?php else: ?>
                    <!-- Setup Form -->
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        Create the initial administrator account to complete setup.
                    </div>

                    <form method="POST" id="setupForm">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="username" class="form-label">
                                    <i class="fas fa-user me-2"></i>Username
                                </label>
                                <input type="text" 
                                       class="form-control" 
                                       id="username" 
                                       name="username" 
                                       placeholder="Enter admin username"
                                       value="<?php echo htmlspecialchars($_POST['username'] ?? ''); ?>"
                                       required 
                                       autofocus>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label for="full_name" class="form-label">
                                    <i class="fas fa-id-card me-2"></i>Full Name
                                </label>
                                <input type="text" 
                                       class="form-control" 
                                       id="full_name" 
                                       name="full_name" 
                                       placeholder="Enter full name"
                                       value="<?php echo htmlspecialchars($_POST['full_name'] ?? ''); ?>"
                                       required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="email" class="form-label">
                                <i class="fas fa-envelope me-2"></i>Email Address
                            </label>
                            <input type="email" 
                                   class="form-control" 
                                   id="email" 
                                   name="email" 
                                   placeholder="Enter email address"
                                   value="<?php echo htmlspecialchars($_POST['email'] ?? ''); ?>"
                                   required>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="password" class="form-label">
                                    <i class="fas fa-lock me-2"></i>Password
                                </label>
                                <input type="password" 
                                       class="form-control" 
                                       id="password" 
                                       name="password" 
                                       placeholder="Enter password (min 8 chars)"
                                       required
                                       minlength="8">
                            </div>

                            <div class="col-md-6 mb-4">
                                <label for="confirm_password" class="form-label">
                                    <i class="fas fa-lock me-2"></i>Confirm Password
                                </label>
                                <input type="password" 
                                       class="form-control" 
                                       id="confirm_password" 
                                       name="confirm_password" 
                                       placeholder="Confirm password"
                                       required
                                       minlength="8">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-setup" id="setupButton">
                            <i class="fas fa-cog me-2"></i>
                            Complete Setup
                        </button>
                    </form>
                <?php endif; ?>
            <?php endif; ?>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        document.getElementById('setupForm')?.addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirm_password').value;
            
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
                return;
            }
            
            if (password.length < 8) {
                e.preventDefault();
                alert('Password must be at least 8 characters long!');
                return;
            }
            
            // Show loading state
            const button = document.getElementById('setupButton');
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Setting up...';
        });

        // Password strength indicator
        document.getElementById('password')?.addEventListener('input', function() {
            const password = this.value;
            const strength = getPasswordStrength(password);
            
            // You could add a visual strength indicator here
        });

        function getPasswordStrength(password) {
            let strength = 0;
            if (password.length >= 8) strength++;
            if (/[a-z]/.test(password)) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            
            return strength;
        }

        // Auto-refresh status every 30 seconds
        setTimeout(function() {
            if (!document.querySelector('.alert-success')) {
                location.reload();
            }
        }, 30000);
    </script>
</body>
</html>