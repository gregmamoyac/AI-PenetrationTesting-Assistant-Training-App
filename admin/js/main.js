// Global variables
let currentUser = null;
let currentData = {
    users: [],
    sessions: [],
    logs: [],
    commands: [],
    settings: {}
};
let currentEditingUser = null;
let sortDirection = {};
let charts = {}; // Store chart instances

// API Base URL - adjust this to your server path
const API_BASE = 'api.php';

// Session management
function isLoggedIn() {
    return localStorage.getItem('session_token') !== null;
}

function saveSession(user, sessionToken) {
    localStorage.setItem('session_token', sessionToken);
    localStorage.setItem('user_data', JSON.stringify(user));
    localStorage.setItem('session_expires', Date.now() + (8 * 60 * 60 * 1000)); // 8 hours
}

function clearSession() {
    localStorage.removeItem('session_token');
    localStorage.removeItem('user_data');
    localStorage.removeItem('session_expires');
}

function getStoredUser() {
    const userData = localStorage.getItem('user_data');
    const expires = localStorage.getItem('session_expires');
    
    if (userData && expires && Date.now() < parseInt(expires)) {
        return JSON.parse(userData);
    }
    
    clearSession();
    return null;
}

// Authentication
async function login() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    try {
        const response = await fetch(API_BASE, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'login',
                username: username,
                password: password
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            currentUser = data.user;
            saveSession(data.user, data.session_token || 'temp_token');
            
            document.getElementById('loginScreen').style.display = 'none';
            document.getElementById('mainApp').style.display = 'block';
            document.getElementById('currentUser').textContent = `Welcome, ${data.user.full_name}`;

            // Set up role-based access
            setupRoleBasedAccess(data.user.role);

            // Restore active tab or default to dashboard
            const activeTab = localStorage.getItem('activeTab') || 'dashboard';
            if (document.getElementById(activeTab)) {
                showSection(activeTab);
            } else {
                showSection('dashboard');
            }

            showAlert('Login successful!', 'success');
        } else {
            document.getElementById('loginError').textContent = data.message || 'Invalid credentials';
            document.getElementById('loginError').style.display = 'block';
        }
    } catch (error) {
        console.error('Login error:', error);
        document.getElementById('loginError').textContent = 'Connection error. Please try again.';
        document.getElementById('loginError').style.display = 'block';
    }
}

function logout() {
    clearSession();
    currentUser = null;
    document.getElementById('loginScreen').style.display = 'block';
    document.getElementById('mainApp').style.display = 'none';
    document.getElementById('username').value = '';
    document.getElementById('password').value = '';
    document.getElementById('loginError').style.display = 'none';
    
    // Destroy all charts
    Object.values(charts).forEach(chart => {
        if (chart) chart.destroy();
    });
    charts = {};
}

function setupRoleBasedAccess(role) {
    const userManagementTab = document.getElementById('usersTab');
    const logsTab = document.getElementById('logsTab');
    const settingsTab = document.getElementById('settingsTab');
    
    if (role === 'operator') {
        // Operators have limited access
        if (userManagementTab) userManagementTab.style.display = 'none';
        if (logsTab) logsTab.style.display = 'none';
        if (settingsTab) settingsTab.style.display = 'none';
    } else if (role === 'manager') {
        // Managers can see users but not system settings or logs
        if (userManagementTab) userManagementTab.style.display = 'block';
        if (logsTab) logsTab.style.display = 'none'; // Add this line
        if (settingsTab) settingsTab.style.display = 'none';
    } else {
        // Admins see everything
        if (userManagementTab) userManagementTab.style.display = 'block';
        if (logsTab) logsTab.style.display = 'block';
        if (settingsTab) settingsTab.style.display = 'block';
    }
}

// Navigation
function showSection(sectionId, clickedElement = null) {
    // Check if we're leaving the feedback section and reset it
    const currentActiveSection = document.querySelector('.content-section.active');
    if (currentActiveSection && currentActiveSection.id === 'feedback' && sectionId !== 'feedback') {
        resetFeedbackSection();
    }
    
    // Hide all sections
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Remove active class from all tabs
    document.querySelectorAll('.nav-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Show selected section and activate tab
    document.getElementById(sectionId).classList.add('active');
    
    // If clickedElement is provided, use it; otherwise find the tab button
    if (clickedElement) {
        clickedElement.classList.add('active');
    } else {
        const tabButton = document.querySelector(`[onclick="showSection('${sectionId}', this)"]`);
        if (tabButton) {
            tabButton.classList.add('active');
        }
    }
    
    // Save active tab
    localStorage.setItem('activeTab', sectionId);
    
    // Load section data
    switch(sectionId) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'users':
            loadUsers();
            break;
        case 'sessions':
            loadSessions();
            break;
        case 'feedback':
            loadFeedback();
            break;
        case 'reports':
            loadReports();
            break;
        case 'logs':
            loadLogs();
            break;
        case 'settings':
            loadSettings();
            break;
    }
}

// Add this new function to reset the feedback section
function resetFeedbackSection() {
    document.getElementById('gradingUserFilter').value = '';
    document.getElementById('gradingSessionFilter').innerHTML = '<option value="">Select Session</option>';
    document.getElementById('gradingContent').innerHTML = '<p>Select a user and session to begin grading.</p>';
}

// Dashboard functions
async function loadDashboard() {
    try {
        const userRole = currentUser ? currentUser.role : 'admin';
        const userId = currentUser ? currentUser.id : null;
        
        const response = await fetch(`${API_BASE}?action=dashboard&user_role=${userRole}&user_id=${userId}`);
        const data = await response.json();
        
        if (data.success) {
            // Update statistics
            document.getElementById('totalUsers').textContent = data.stats.total_users;
            document.getElementById('activeSessions').textContent = data.stats.active_sessions;
            document.getElementById('totalCommands').textContent = data.stats.total_commands;
            document.getElementById('avgExecutionTime').textContent = data.stats.avg_execution_time;
            
            // Create charts
            createActivityChart(data.charts.activity);
            createStatusChart(data.charts.status);
        }
    } catch (error) {
        console.error('Dashboard load error:', error);
        showAlert('Error loading dashboard data', 'danger');
    }
}

async function refreshDashboard() {
    await loadDashboard();
    showAlert('Dashboard refreshed!', 'success');
}

function createActivityChart(data) {
    // Destroy existing chart if it exists
    if (charts.activity) {
        charts.activity.destroy();
    }
    
    const ctx = document.getElementById('activityChart').getContext('2d');
    charts.activity = new Chart(ctx, {
        type: 'line',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Sessions',
                data: data.sessions,
                borderColor: '#58a6ff',
                backgroundColor: 'rgba(88, 166, 255, 0.1)',
                tension: 0.4,
                fill: true
            }, {
                label: 'Commands',
                data: data.commands,
                borderColor: '#a9a7ff',
                backgroundColor: 'rgba(169, 167, 255, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        color: '#f0f6fc'
                    }
                }
            },
            scales: {
                x: {
                    ticks: {
                        color: '#8b949e'
                    },
                    grid: {
                        color: '#30363d'
                    }
                },
                y: {
                    beginAtZero: true,
                    ticks: {
                        color: '#8b949e'
                    },
                    grid: {
                        color: '#30363d'
                    }
                }
            }
        }
    });
}

// System Logs
async function loadLogs() {
    try {
        const response = await fetch(`${API_BASE}?action=logs`);
        const data = await response.json();
        
        if (data.success) {
            currentData.logs = data.logs;
            renderLogsTable();
        }
    } catch (error) {
        console.error('Logs load error:', error);
        showAlert('Error loading logs', 'danger');
    }
}

function renderLogsTable() {
    const tbody = document.getElementById('logsTableBody');
    tbody.innerHTML = '';
    
    let filteredLogs = filterLogs();
    
    filteredLogs.forEach(log => {
        const user = currentData.users.find(u => u.id === log.user_id);
        const row = tbody.insertRow();
        row.innerHTML = `
            <td>${formatDate(log.timestamp)}</td>
            <td>${user ? user.full_name : 'System'}</td>
            <td><span class="status-badge">${log.action_type}</span></td>
            <td>${log.ip_address || '-'}</td>
            <td>${log.action_details ? JSON.stringify(JSON.parse(log.action_details)).substring(0, 100) + '...' : '-'}</td>
        `;
    });

    if (filteredLogs.length === 0) {
        const row = tbody.insertRow();
        row.innerHTML = `<td colspan="8" style="text-align: center; color: var(--text-secondary); font-style: italic; padding: 40px;">No results found</td>`;
    }
}

function filterLogs() {
    let filtered = currentData.logs;
    
    const typeFilter = document.getElementById('logTypeFilter')?.value || '';
    const dateFilter = document.getElementById('logDateFilter')?.value || '';
    
    if (typeFilter) {
        filtered = filtered.filter(log => log.action_type === typeFilter);
    }
    
    if (dateFilter) {
        filtered = filtered.filter(log => log.timestamp.startsWith(dateFilter));
    }
    
    return filtered.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
}

// Settings
async function loadSettings() {
    try {
        const response = await fetch(`${API_BASE}?action=settings`);
        const data = await response.json();
        
        if (data.success) {
            currentData.settings = data.settings;
            document.getElementById('sessionTimeout').value = data.settings.session_timeout || 3600;
            document.getElementById('maxCommandHistory').value = data.settings.max_command_history || 1000;
            document.getElementById('auditRetention').value = data.settings.audit_retention_days || 90;
            document.getElementById('maxConcurrentSessions').value = data.settings.max_concurrent_sessions || 10;
        }
    } catch (error) {
        console.error('Settings load error:', error);
        showAlert('Error loading settings', 'danger');
    }
}

async function saveSettings() {
    try {
        const response = await fetch(API_BASE, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'save_settings',
                settings: {
                    session_timeout: parseInt(document.getElementById('sessionTimeout').value),
                    max_command_history: parseInt(document.getElementById('maxCommandHistory').value),
                    audit_retention_days: parseInt(document.getElementById('auditRetention').value),
                    max_concurrent_sessions: parseInt(document.getElementById('maxConcurrentSessions').value)
                }
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showAlert('Settings saved successfully!', 'success');
        } else {
            showAlert('Error saving settings: ' + data.message, 'danger');
        }
    } catch (error) {
        console.error('Save settings error:', error);
        showAlert('Error saving settings', 'danger');
    }
}

// Export Functions
function exportSessions(format) {
    const sessions = filterSessions();
    const data = sessions.map(session => {
        const user = currentData.users.find(u => u.id === session.user_id);
        return {
            'Session ID': session.session_id,
            'User': user ? user.full_name : 'Unknown',
            'Hostname': session.hostname,
            'IP Address': session.ip_address,
            'Start Time': session.start_time,
            'End Time': session.end_time || 'Active',
            'Duration': calculateDuration(session.start_time, session.end_time),
            'Commands': session.total_commands,
            'Status': session.status,
            'OS Info': session.os_info || ''
        };
    });

    if (format === 'pdf') {
        exportToPDF('Sessions Report', data);
    } else if (format === 'excel') {
        exportToExcel('sessions_report.xlsx', data);
    }
}

async function exportSessionDetail(sessionId, format) {
    try {
        const response = await fetch(`${API_BASE}?action=session_detail&session_id=${sessionId}`);
        const data = await response.json();
        
        if (data.success) {
            const session = data.session;
            const user = currentData.users.find(u => u.id === session.user_id);
            const commands = data.commands;
            const conversations = data.conversations || [];
            
            const exportData = {
                session: {
                    'Session ID': session.session_id,
                    'User': user ? user.full_name : 'Unknown',
                    'Hostname': session.hostname,
                    'IP Address': session.ip_address,
                    'Start Time': formatDate(session.start_time),
                    'End Time': session.end_time ? formatDate(session.end_time) : 'Still active',
                    'Status': session.status,
                    'OS Info': session.os_info || 'Not available'
                },
                commands: commands.map(cmd => ({
                    'Time': formatDate(cmd.timestamp),
                    'Command': cmd.command,
                    'Status': cmd.status,
                    'Execution Time': cmd.execution_time ? cmd.execution_time + 's' : 'N/A',
                    'Output': cmd.output || 'No output'
                })),
                conversations: conversations.map(conv => ({
                    'Time': formatDate(conv.timestamp),
                    'Type': conv.message_type === 'user' ? 'Student' : 'Bot',
                    'Message': conv.message
                }))
            };
            
            if (format === 'pdf') {
                exportSessionToPDF(sessionId, exportData);
            } else if (format === 'excel') {
                exportSessionToExcel(sessionId, exportData);
            }
        }
    } catch (error) {
        console.error('Export session detail error:', error);
        showAlert('Error exporting session details', 'danger');
    }
}

function exportLogs() {
    const logs = filterLogs();
    const data = logs.map(log => {
        const user = currentData.users.find(u => u.id === log.user_id);
        return {
            'Timestamp': log.timestamp,
            'User': user ? user.full_name : 'System',
            'Action': log.action_type,
            'IP Address': log.ip_address || '',
            'Details': log.action_details || ''
        };
    });

    exportToExcel('system_logs.xlsx', data);
}

function exportToPDF(title, data) {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    
    doc.setFontSize(16);
    doc.text(title, 20, 20);
    doc.setFontSize(10);
    doc.text(`Generated on: ${new Date().toLocaleString()}`, 20, 30);
    
    let y = 50;
    const pageHeight = doc.internal.pageSize.height;
    
    if (data.length > 0) {
        const headers = Object.keys(data[0]);
        const colWidth = 180 / headers.length;
        
        // Headers
        headers.forEach((header, index) => {
            doc.text(header, 20 + (index * colWidth), y);
        });
        y += 10;
        
        // Data rows
        data.forEach(row => {
            if (y > pageHeight - 20) {
                doc.addPage();
                y = 20;
            }
            
            headers.forEach((header, index) => {
                const value = String(row[header] || '').substring(0, 20);
                doc.text(value, 20 + (index * colWidth), y);
            });
            y += 10;
        });
    }
    
    doc.save(`${title.toLowerCase().replace(/\s+/g, '_')}.pdf`);
    showAlert('PDF exported successfully!', 'success');
}

function exportSessionToPDF(sessionId, data) {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    
    doc.setFontSize(16);
    doc.text(`Session Report: ${sessionId}`, 20, 20);
    doc.setFontSize(10);
    doc.text(`Generated on: ${new Date().toLocaleString()}`, 20, 30);
    
    let y = 50;
    
    // Session Info
    doc.setFontSize(14);
    doc.text('Session Information', 20, y);
    y += 10;
    doc.setFontSize(10);
    
    Object.entries(data.session).forEach(([key, value]) => {
        doc.text(`${key}: ${value}`, 20, y);
        y += 8;
    });
    
    y += 10;
    
    // Commands
    doc.setFontSize(14);
    doc.text('Commands Executed', 20, y);
    y += 10;
    doc.setFontSize(8);
    
    data.commands.forEach(cmd => {
        if (y > 270) {
            doc.addPage();
            y = 20;
        }
        
        doc.text(`${cmd.Time}: ${cmd.Command}`, 20, y);
        y += 6;
        doc.text(`Status: ${cmd.Status}, Time: ${cmd['Execution Time']}`, 25, y);
        y += 6;
        if (cmd.Output && cmd.Output !== 'No output') {
            const output = cmd.Output.substring(0, 100) + (cmd.Output.length > 100 ? '...' : '');
            doc.text(`Output: ${output}`, 25, y);
            y += 6;
        }
        y += 4;
    });
    
    doc.save(`session_${sessionId}_report.pdf`);
    showAlert('Session PDF exported successfully!', 'success');
}

function exportToExcel(filename, data) {
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Data');
    XLSX.writeFile(wb, filename);
    showAlert('Excel file exported successfully!', 'success');
}

function exportSessionToExcel(sessionId, data) {
    const wb = XLSX.utils.book_new();
    
    // Session info sheet
    const sessionWs = XLSX.utils.json_to_sheet([data.session]);
    XLSX.utils.book_append_sheet(wb, sessionWs, 'Session Info');
    
    // Commands sheet
    if (data.commands.length > 0) {
        const commandsWs = XLSX.utils.json_to_sheet(data.commands);
        XLSX.utils.book_append_sheet(wb, commandsWs, 'Commands');
    }
    
    // Conversations sheet
    if (data.conversations.length > 0) {
        const conversationsWs = XLSX.utils.json_to_sheet(data.conversations);
        XLSX.utils.book_append_sheet(wb, conversationsWs, 'Conversations');
    }
    
    XLSX.writeFile(wb, `session_${sessionId}_report.xlsx`);
    showAlert('Session Excel file exported successfully!', 'success');
}

// Utility Functions
function formatDate(dateString) {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleString();
}

function calculateDuration(startTime, endTime) {
    if (!endTime) return 'Active';
    const duration = new Date(endTime) - new Date(startTime);
    const minutes = Math.floor(duration / 60000);
    const hours = Math.floor(minutes / 60);
    
    if (hours > 0) {
        return `${hours}h ${minutes % 60}m`;
    }
    return `${minutes}m`;
}

function sortTable(tableType, columnIndex) {
    const tableId = tableType + 'Table';
    const table = document.getElementById(tableId);
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    
    const sortKey = `${tableType}_${columnIndex}`;
    const ascending = !sortDirection[sortKey];
    sortDirection[sortKey] = ascending;
    
    rows.sort((a, b) => {
        const aVal = a.cells[columnIndex].textContent.trim();
        const bVal = b.cells[columnIndex].textContent.trim();
        
        // Try to parse as numbers first
        const aNum = parseFloat(aVal);
        const bNum = parseFloat(bVal);
        
        if (!isNaN(aNum) && !isNaN(bNum)) {
            return ascending ? aNum - bNum : bNum - aNum;
        }
        
        // Sort as strings
        return ascending ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
    });
    
    tbody.innerHTML = '';
    rows.forEach(row => tbody.appendChild(row));
    
    // Update sort indicators
    table.querySelectorAll('th').forEach((th, index) => {
        th.classList.remove('sort-asc', 'sort-desc');
        if (index === columnIndex) {
            th.classList.add(ascending ? 'sort-asc' : 'sort-desc');
        }
    });
}

function showAlert(message, type = 'info') {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type}`;
    alertDiv.innerHTML = `
        <span>${message}</span>
        <button onclick="this.parentElement.remove()" style="background: none; border: none; color: inherit; cursor: pointer; font-size: 18px; padding: 0; margin-left: 10px;">&times;</button>
    `;
    alertDiv.style.position = 'fixed';
    alertDiv.style.top = '20px';
    alertDiv.style.right = '20px';
    alertDiv.style.zIndex = '9999';
    alertDiv.style.minWidth = '300px';
    alertDiv.style.maxWidth = '500px';
    
    document.body.appendChild(alertDiv);
    
    setTimeout(() => {
        if (alertDiv.parentElement) {
            alertDiv.remove();
        }
    }, 5000);
}

function showConfirmModal(message, onConfirm) {
    document.getElementById('confirmMessage').textContent = message;
    document.getElementById('confirmButton').onclick = () => {
        onConfirm();
        closeConfirmModal();
    };
    document.getElementById('confirmModal').style.display = 'block';
}

function closeConfirmModal() {
    document.getElementById('confirmModal').style.display = 'none';
}

// Event Listeners
document.getElementById('loginForm').addEventListener('submit', function(e) {
    e.preventDefault();
    login();
});

// Add event listeners for star hover effect
document.addEventListener('mouseover', function(e) {
    if (e.target.classList.contains('star')) {
        const stars = e.target.parentElement.querySelectorAll('.star');
        const hoverIndex = Array.from(stars).indexOf(e.target);
        stars.forEach((star, index) => {
            star.style.color = index <= hoverIndex ? 'var(--accent-yellow)' : 'var(--text-secondary)';
        });
    }
});

document.addEventListener('mouseout', function(e) {
    if (e.target.classList.contains('star')) {
        const stars = e.target.parentElement.querySelectorAll('.star');
        stars.forEach((star, index) => {
            star.style.color = star.classList.contains('active') ? 'var(--accent-yellow)' : 'var(--text-secondary)';
        });
    }
});

document.getElementById('userForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const userData = {
        action: currentEditingUser ? 'update_user' : 'create_user',
        user_id: currentEditingUser,
        username: document.getElementById('userUsername').value,
        full_name: document.getElementById('userFullName').value,
        email: document.getElementById('userEmail').value,
        role: document.getElementById('userRole').value,
        is_active: parseInt(document.getElementById('userStatus').value),
        password: document.getElementById('userPassword').value
    };
    
    try {
        const response = await fetch(API_BASE, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(userData)
        });
        
        const data = await response.json();
        
        if (data.success) {
            closeUserModal();
            await loadUsers();
            showAlert(currentEditingUser ? 'User updated successfully!' : 'User created successfully!', 'success');
        } else {
            showAlert('Error saving user: ' + data.message, 'danger');
        }
    } catch (error) {
        console.error('Save user error:', error);
        showAlert('Error saving user', 'danger');
    }
});

// Search and filter event listeners
document.addEventListener('input', function(e) {
    if (e.target.id === 'userSearch') {
        renderUsersTable();
    } else if (e.target.id === 'sessionSearch') {
        renderSessionsTable();
    }
});

document.addEventListener('change', function(e) {
    if (e.target.id === 'roleFilter' || e.target.id === 'statusFilter') {
        renderUsersTable();
    } else if (e.target.id.includes('sessionUserFilter') || e.target.id.includes('sessionStatusFilter') || e.target.id.includes('sessionDateFilter')) {
        renderSessionsTable();
    } else if (e.target.id === 'gradingUserFilter') {
        loadUserSessions();
        document.getElementById('gradingContent').innerHTML = '<p>Select a session to begin grading.</p>';
    } else if (e.target.id === 'gradingSessionFilter') {
        loadGradingContent(e.target.value);
    } else if (e.target.id === 'logTypeFilter' || e.target.id === 'logDateFilter') {
        renderLogsTable();
    }
});

// Close modals when clicking outside
window.addEventListener('click', function(e) {
    const modals = ['userModal', 'sessionModal', 'confirmModal'];
    modals.forEach(modalId => {
        const modal = document.getElementById(modalId);
        if (e.target === modal) {
            modal.style.display = 'none';
        }
    });
});

// Initialize application
document.addEventListener('DOMContentLoaded', function() {
    // Check if user is already logged in
    const storedUser = getStoredUser();
    if (storedUser) {
        currentUser = storedUser;
        document.getElementById('loginScreen').style.display = 'none';
        document.getElementById('mainApp').style.display = 'block';
        document.getElementById('currentUser').textContent = `Welcome, ${storedUser.full_name}`;
        setupRoleBasedAccess(storedUser.role);
        
        // Restore active tab after the app is shown
        const activeTab = localStorage.getItem('activeTab') || 'dashboard';
        if (document.getElementById(activeTab)) {
            showSection(activeTab);
        } else {
            // Fallback to dashboard if stored tab doesn't exist
            showSection('dashboard');
        }
    } else {
        // Show login screen initially
        document.getElementById('loginScreen').style.display = 'block';
        document.getElementById('mainApp').style.display = 'none';
    }
});

// Session expiry check
setInterval(() => {
    const expires = localStorage.getItem('session_expires');
    if (expires && Date.now() >= parseInt(expires)) {
        showAlert('Your session has expired. Please log in again.', 'warning');
        logout();
    }
}, 60000); // Check every minute

function createStatusChart(data) {
    // Destroy existing chart if it exists
    if (charts.status) {
        charts.status.destroy();
    }
    
    const ctx = document.getElementById('statusChart').getContext('2d');
    charts.status = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: data.labels,
            datasets: [{
                data: data.values,
                backgroundColor: ['#3fb950', '#d29922', '#f85149', '#8b949e'],
                borderColor: '#21262d',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        color: '#f0f6fc',
                        padding: 20
                    }
                }
            }
        }
    });
}

// User Management
async function loadUsers() {
    try {
        const response = await fetch(`${API_BASE}?action=users`);
        const data = await response.json();
        
        if (data.success) {
            currentData.users = data.users;
            renderUsersTable();
        }
    } catch (error) {
        console.error('Users load error:', error);
        showAlert('Error loading users', 'danger');
    }
}

function renderUsersTable() {
    const tbody = document.getElementById('usersTableBody');
    tbody.innerHTML = '';
    
    let filteredUsers = filterUsers();
    
    filteredUsers.forEach(user => {
        // Convert is_active to boolean for consistent checking
        const isActive = user.is_active == 1 || user.is_active === true || user.is_active === 'true';
        
        const row = tbody.insertRow();
        row.innerHTML = `
            <td>${user.id}</td>
            <td>${user.username}</td>
            <td>${user.full_name}</td>
            <td>${user.email}</td>
            <td><span class="status-badge">${user.role}</span></td>
            <td><span class="status-badge ${isActive ? 'status-active' : 'status-inactive'}">${isActive ? 'Active' : 'Inactive'}</span></td>
            <td>${formatDate(user.last_login)}</td>
            <td>
                <button class="btn btn-secondary btn-small" onclick="editUser('${user.id}')">Edit</button>
                ${isActive ? 
                    `<button class="btn btn-danger btn-small" onclick="toggleUserStatus(${user.id}, 0)">Disable</button>` :
                    `<button class="btn btn-success btn-small" onclick="toggleUserStatus(${user.id}, 1)">Enable</button>`
                }
                <button class="btn btn-danger btn-small" onclick="deleteUser(${user.id})">Delete</button>
                <button class="btn btn-primary btn-small" onclick="resetPassword(${user.id})">Reset Password</button>
            </td>
        `;
    });
    
    // Add no results message if needed
    if (filteredUsers.length === 0) {
        const row = tbody.insertRow();
        row.innerHTML = `<td colspan="8" style="text-align: center; color: var(--text-secondary); font-style: italic; padding: 40px;">No results found</td>`;
    }
}

async function toggleUserStatus(userId, newStatus) {
    try {
        const response = await fetch(API_BASE, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'toggle_user_status',
                user_id: userId,
                is_active: newStatus
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Update the user status in the local data with proper type conversion
            const userIndex = currentData.users.findIndex(u => u.id == userId);
            if (userIndex !== -1) {
                currentData.users[userIndex].is_active = parseInt(newStatus); // Ensure it's stored as integer
            }
            
            // Re-render the table to show updated status
            renderUsersTable();
            
            showAlert(`User ${newStatus ? 'enabled' : 'disabled'} successfully!`, 'success');
        } else {
            showAlert('Error updating user status: ' + data.message, 'danger');
        }
    } catch (error) {
        console.error('Toggle user status error:', error);
        showAlert('Error updating user status', 'danger');
    }
}

function filterUsers() {
    let filtered = currentData.users;
    
    const search = document.getElementById('userSearch')?.value.toLowerCase() || '';
    const roleFilter = document.getElementById('roleFilter')?.value || '';
    const statusFilter = document.getElementById('statusFilter')?.value || '';
    
    if (search) {
        filtered = filtered.filter(user => 
            user.username.toLowerCase().includes(search) ||
            user.full_name.toLowerCase().includes(search) ||
            user.email.toLowerCase().includes(search)
        );
    }
    
    if (roleFilter) {
        filtered = filtered.filter(user => user.role === roleFilter);
    }
    
    if (statusFilter !== '') {
        filtered = filtered.filter(user => user.is_active == statusFilter);
    }
    
    return filtered;
}

function showUserModal(userId = null) {
    currentEditingUser = userId;
    const modal = document.getElementById('userModal');
    const title = document.getElementById('userModalTitle');
    
    if (userId) {
        const user = currentData.users.find(u => u.id === userId);
        if (!user) {
            showAlert('User not found', 'danger');
            return;
        }
        
        title.textContent = 'Edit User';
        document.getElementById('userUsername').value = user.username;
        document.getElementById('userFullName').value = user.full_name;
        document.getElementById('userEmail').value = user.email;
        document.getElementById('userRole').value = user.role;
        document.getElementById('userStatus').value = user.is_active;
        document.getElementById('userPassword').value = '';
        document.getElementById('userPassword').placeholder = 'Leave blank to keep current password';
    } else {
        title.textContent = 'Add New User';
        document.getElementById('userForm').reset();
        document.getElementById('userPassword').placeholder = 'Enter password';
    }
    
    modal.style.display = 'block';
}

function closeUserModal() {
    document.getElementById('userModal').style.display = 'none';
    currentEditingUser = null;
}

function editUser(userId) {
    showUserModal(userId);
}

async function deleteUser(userId) {
    const user = currentData.users.find(u => u.id === userId);
    showConfirmModal(
        `Are you sure you want to delete user "${user.full_name}"? This action cannot be undone.`,
        async () => {
            try {
                const response = await fetch(API_BASE, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        action: 'delete_user',
                        user_id: userId
                    })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    await loadUsers();
                    showAlert('User deleted successfully!', 'success');
                } else {
                    showAlert('Error deleting user: ' + data.message, 'danger');
                }
            } catch (error) {
                console.error('Delete user error:', error);
                showAlert('Error deleting user', 'danger');
            }
        }
    );
}

async function resetPassword(userId) {
    const user = currentData.users.find(u => u.id === userId);
    showConfirmModal(
        `Reset password for user "${user.full_name}"? A new temporary password will be generated.`,
        async () => {
            try {
                const response = await fetch(API_BASE, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        action: 'reset_password',
                        user_id: userId
                    })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    showAlert(`Password reset! New password: ${data.new_password}`, 'info');
                } else {
                    showAlert('Error resetting password: ' + data.message, 'danger');
                }
            } catch (error) {
                console.error('Reset password error:', error);
                showAlert('Error resetting password', 'danger');
            }
        }
    );
}

// Session Management
async function loadSessions() {
    try {
        const response = await fetch(`${API_BASE}?action=sessions`);
        const data = await response.json();
        
        if (data.success) {
            currentData.sessions = data.sessions;
            populateSessionFilters();
            renderSessionsTable();
        }
    } catch (error) {
        console.error('Sessions load error:', error);
        showAlert('Error loading sessions', 'danger');
    }
}

function populateSessionFilters() {
    const userFilter = document.getElementById('sessionUserFilter');
    userFilter.innerHTML = '<option value="">All Users</option>';
    
    currentData.users.forEach(user => {
        const option = document.createElement('option');
        option.value = user.id;
        option.textContent = user.full_name;
        userFilter.appendChild(option);
    });
}

function renderSessionsTable() {
    const tbody = document.getElementById('sessionsTableBody');
    tbody.innerHTML = '';
    
    let filteredSessions = filterSessions();
    
    filteredSessions.forEach(session => {
        const user = currentData.users.find(u => u.id === session.user_id);
        const duration = calculateDuration(session.start_time, session.end_time);
        // Convert to boolean more explicitly
        const hasGrade = session.has_feedback === 1 || session.has_feedback === true;
        
        const row = tbody.insertRow();
        row.innerHTML = `
            <td>${session.session_id}</td>
            <td>${user ? user.full_name : 'Unknown'}</td>
            <td>${session.hostname}</td>
            <td>${formatDate(session.start_time)}</td>
            <td>${duration}</td>
            <td>${session.total_commands}</td>
            <td><span class="status-badge status-${session.status}">${session.status}</span></td>
            <td>${hasGrade ? '<span class="status-badge status-graded">Graded</span>' : '<span class="status-badge status-ungraded">Ungraded</span>'}</td>
            <td>
                <button class="btn btn-secondary btn-small" onclick="viewSessionDetailPage('${session.session_id}')">View</button>
                ${hasGrade ? 
                    `<button class="btn btn-primary btn-small" onclick="viewGradePage('${session.session_id}')">View Grade</button>` :
                    `<button class="btn btn-primary btn-small" onclick="gradeSession('${session.session_id}')">Grade</button>`
                }
                <button class="btn btn-danger btn-small" onclick="deleteSession('${session.session_id}')">Delete</button>
            </td>
        `;
    });

    if (filteredSessions.length === 0) {
        const row = tbody.insertRow();
        row.innerHTML = `<td colspan="9" style="text-align: center; color: var(--text-secondary); font-style: italic; padding: 40px;">No results found</td>`;
    }
}

function filterSessions() {
    let filtered = currentData.sessions;
    
    const search = document.getElementById('sessionSearch')?.value.toLowerCase() || '';
    const userFilter = document.getElementById('sessionUserFilter')?.value || '';
    const statusFilter = document.getElementById('sessionStatusFilter')?.value || '';
    const dateFilter = document.getElementById('sessionDateFilter')?.value || '';
    
    if (search) {
        filtered = filtered.filter(session => 
            session.session_id.toLowerCase().includes(search) ||
            session.hostname.toLowerCase().includes(search)
        );
    }
    
    if (userFilter) {
        filtered = filtered.filter(session => session.user_id == userFilter);
    }
    
    if (statusFilter) {
        filtered = filtered.filter(session => session.status === statusFilter);
    }
    
    if (dateFilter) {
        filtered = filtered.filter(session => session.start_time.startsWith(dateFilter));
    }
    
    return filtered;
}

async function viewSessionDetail(sessionId) {
    try {
        const response = await fetch(`${API_BASE}?action=session_detail&session_id=${sessionId}`);
        const data = await response.json();
        
        if (data.success) {
            const session = data.session;
            const user = currentData.users.find(u => u.id === session.user_id);
            const commands = data.commands;
            const feedback = data.feedback;
            const conversations = data.conversations || [];
            
            const content = `
                <div class="session-info">
                    <h4>Session Information</h4>
                    <p><strong>Session ID:</strong> ${session.session_id}</p>
                    <p><strong>User:</strong> ${user ? user.full_name : 'Unknown'}</p>
                    <p><strong>Hostname:</strong> ${session.hostname}</p>
                    <p><strong>IP Address:</strong> ${session.ip_address}</p>
                    <p><strong>Start Time:</strong> ${formatDate(session.start_time)}</p>
                    <p><strong>End Time:</strong> ${session.end_time ? formatDate(session.end_time) : 'Still active'}</p>
                    <p><strong>Status:</strong> ${session.status}</p>
                    <p><strong>OS Info:</strong> ${session.os_info || 'Not available'}</p>
                </div>
                
                <div class="commands-section">
                    <h4>Commands Executed (${commands.length})</h4>
                    <div class="export-options">
                        <button class="btn btn-secondary btn-small" onclick="exportSessionDetail('${sessionId}', 'pdf')">Export PDF</button>
                        <button class="btn btn-secondary btn-small" onclick="exportSessionDetail('${sessionId}', 'excel')">Export Excel</button>
                    </div>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Time</th>
                                    <th>Command</th>
                                    <th>Status</th>
                                    <th>Execution Time</th>
                                    <th>Output</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${commands.map((cmd, index) => `
                                    <tr>
                                        <td>${formatDate(cmd.timestamp)}</td>
                                        <td><code>${cmd.command}</code></td>
                                        <td><span class="status-badge status-${cmd.status}">${cmd.status}</span></td>
                                        <td>${cmd.execution_time ? cmd.execution_time + 's' : 'N/A'}</td>
                                        <td>
                                            ${cmd.output ? 
                                                `<div class="command-output collapsed" id="output-${index}" onclick="toggleOutput(${index})">
                                                    ${cmd.output}
                                                </div>` : 
                                                'No output'
                                            }
                                        </td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
                
                ${conversations.length > 0 ? `
                <div class="commands-section">
                    <h4>Chatbot Conversations</h4>
                    <div class="timeline">
                        ${conversations.map(conv => `
                            <div class="chat-message ${conv.message_type}">
                                <strong>${conv.message_type === 'user' ? 'User' : 'Bot'}:</strong>
                                <p>${conv.message}</p>
                                <small>${formatDate(conv.timestamp)}</small>
                            </div>
                        `).join('')}
                    </div>
                </div>
                ` : ''}
                
                ${feedback ? `
                <div class="feedback-display">
                    <h4>Grading & Feedback</h4>
                    <p><strong>Overall Score:</strong> ${feedback.overall_score}/100</p>
                    <p><strong>Rating:</strong> ${'★'.repeat(feedback.rating)}${'☆'.repeat(5-feedback.rating)}</p>
                    <p><strong>Instructor Feedback:</strong> ${feedback.instructor_feedback}</p>
                    <p><strong>Graded by:</strong> ${currentData.users.find(u => u.id === feedback.graded_by)?.full_name || 'Unknown'}</p>
                    <p><strong>Graded on:</strong> ${formatDate(feedback.graded_at)}</p>
                </div>
                ` : '<p><em>No grading available for this session.</em></p>'}
            `;
            
            document.getElementById('sessionDetailContent').innerHTML = content;
            document.getElementById('sessionModal').style.display = 'block';
        }
    } catch (error) {
        console.error('Session detail error:', error);
        showAlert('Error loading session details', 'danger');
    }
}

function toggleOutput(index) {
    const outputDiv = document.getElementById(`output-${index}`);
    if (outputDiv) {
        outputDiv.classList.toggle('collapsed');
    }
}

function closeSessionModal() {
    document.getElementById('sessionModal').style.display = 'none';
}

async function deleteSession(sessionId) {
    showConfirmModal(
        `Are you sure you want to delete session "${sessionId}"? This will also delete all associated commands and feedback. This action cannot be undone.`,
        async () => {
            try {
                const response = await fetch(API_BASE, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        action: 'delete_session',
                        session_id: sessionId
                    })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    await loadSessions();
                    showAlert('Session deleted successfully!', 'success');
                } else {
                    showAlert('Error deleting session: ' + data.message, 'danger');
                }
            } catch (error) {
                console.error('Delete session error:', error);
                showAlert('Error deleting session', 'danger');
            }
        }
    );
}

// Feedback and Grading
async function loadFeedback() {
    await loadUsers(); // Ensure users are loaded for the dropdowns
    populateGradingFilters();
}

function populateGradingFilters() {
    const userFilter = document.getElementById('gradingUserFilter');
    userFilter.innerHTML = '<option value="">Select User</option>';
    
    currentData.users.filter(u => u.role === 'operator' || u.role === 'admin').forEach(user => {
        const option = document.createElement('option');
        option.value = user.id;
        option.textContent = user.full_name;
        userFilter.appendChild(option);
    });
}

function gradeSession(sessionId) {
    // Store the session ID for potential use after saving
    window.currentGradingSessionId = sessionId;
    
    showSection('feedback');
    
    const session = currentData.sessions.find(s => s.session_id === sessionId);
    if (!session) return;
    
    document.getElementById('gradingUserFilter').value = session.user_id;
    loadUserSessions();
    document.getElementById('gradingSessionFilter').value = sessionId;
    loadGradingContent(sessionId);
}

async function loadUserSessions() {
    const userId = document.getElementById('gradingUserFilter').value;
    const sessionFilter = document.getElementById('gradingSessionFilter');
    
    sessionFilter.innerHTML = '<option value="">Select Session</option>';
    
    if (userId) {
        try {
            const response = await fetch(`${API_BASE}?action=user_sessions&user_id=${userId}`);
            const data = await response.json();
            
            if (data.success) {
                data.sessions.forEach(session => {
                    const option = document.createElement('option');
                    option.value = session.session_id;
                    option.textContent = `${session.session_id} - ${formatDate(session.start_time)}`;
                    sessionFilter.appendChild(option);
                });
            }
        } catch (error) {
            console.error('Load user sessions error:', error);
        }
    }
}

async function loadGradingContent(sessionId) {
    if (!sessionId) {
        document.getElementById('gradingContent').innerHTML = '<p>Select a user and session to begin grading.</p>';
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE}?action=grading_data&session_id=${sessionId}`);
        const data = await response.json();
        
        if (data.success) {
            const session = data.session;
            const user = currentData.users.find(u => u.id === session.user_id);
            const commands = data.commands;
            const conversations = data.conversations || [];
            const existingFeedback = data.feedback;
            
            // Create chronological timeline
            const timeline = [];
            
            // Add commands to timeline
            commands.forEach(cmd => {
                timeline.push({
                    type: 'command',
                    timestamp: cmd.timestamp,
                    data: cmd
                });
            });
            
            // Add conversations to timeline
            conversations.forEach(conv => {
                timeline.push({
                    type: 'conversation',
                    timestamp: conv.timestamp,
                    data: conv
                });
            });
            
            // Sort by timestamp
            timeline.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
            
            const content = `
                <div class="grading-form">
                    <h3>Grading Session: ${sessionId}</h3>
                    <p><strong>Student:</strong> ${user ? user.full_name : 'Unknown'}</p>
                    <p><strong>Session Date:</strong> ${formatDate(session.start_time)}</p>
                    <p><strong>Commands Executed:</strong> ${commands.length}</p>
                    <p><strong>Chat Interactions:</strong> ${conversations.length}</p>
                    
                    <div class="grading-timeline">
                        <h4>Session Timeline (Commands & Conversations)</h4>
                        ${timeline.map(item => {
                            if (item.type === 'command') {
                                return `
                                    <div class="grading-timeline-item command-item">
                                        <div class="timeline-time">${formatDate(item.timestamp)}</div>
                                        <div class="timeline-content">
                                            <h5>Command: <code>${item.data.command}</code></h5>
                                            <p><strong>Status:</strong> <span class="status-badge status-${item.data.status}">${item.data.status}</span></p>
                                            <p><strong>Execution Time:</strong> ${item.data.execution_time ? item.data.execution_time + 's' : 'N/A'}</p>
                                            ${item.data.output ? `
                                                <div class="command-output-full">
                                                    <strong>Output:</strong>
                                                    <pre>${item.data.output}</pre>
                                                </div>
                                            ` : ''}
                                            <div class="form-group">
                                                <label class="form-label">Feedback for this command:</label>
                                                <input type="text" class="form-input" id="cmd_${item.data.id}" 
                                                       value="${existingFeedback?.command_feedback?.[item.data.command] || ''}" 
                                                       placeholder="Enter feedback for this command">
                                            </div>
                                        </div>
                                    </div>
                                `;
                            } else {
                                return `
                                    <div class="grading-timeline-item conversation-item">
                                        <div class="timeline-time">${formatDate(item.timestamp)}</div>
                                        <div class="timeline-content">
                                            <h5>${item.data.message_type === 'user' ? 'Student Question' : 'Bot Response'}</h5>
                                            <div class="chat-message ${item.data.message_type}">
                                                ${item.data.message}
                                            </div>
                                        </div>
                                    </div>
                                `;
                            }
                        }).join('')}
                    </div>
                    
                    <div class="feedback-section">
                        <h4>Overall Session Grading</h4>
                        <div class="grade-input">
                            <label class="form-label">Overall Score (0-100):</label>
                            <input type="number" id="overallScore" class="form-input" min="0" max="100" 
                                value="${existingFeedback?.overall_score || ''}" style="width: 100px;"
                                oninput="this.value = Math.max(0, Math.min(100, this.value))">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Overall Rating:</label>
                            <div class="rating-stars" id="ratingStars">
                                ${[1,2,3,4,5].map(i => 
                                    `<span class="star ${(existingFeedback?.rating >= i) ? 'active' : ''}" 
                                           onclick="setRating(${i})">★</span>`
                                ).join('')}
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Instructor Feedback:</label>
                            <textarea class="form-input" id="instructorFeedback" rows="4" 
                                      placeholder="Provide overall feedback for the student">${existingFeedback?.instructor_feedback || ''}</textarea>
                        </div>
                        
                        <button class="btn btn-primary" onclick="saveFeedback('${sessionId}')">
                            ${existingFeedback ? 'Update' : 'Save'} Feedback
                        </button>
                    </div>
                </div>
            `;
            
            document.getElementById('gradingContent').innerHTML = content;
        }
    } catch (error) {
        console.error('Load grading content error:', error);
        showAlert('Error loading grading data', 'danger');
    }
}

function setRating(rating) {
    const stars = document.querySelectorAll('.star');
    stars.forEach((star, index) => {
        star.classList.toggle('active', index < rating);
    });
}

async function saveFeedback(sessionId) {
    try {
        const response = await fetch(`${API_BASE}?action=grading_data&session_id=${sessionId}`);
        const data = await response.json();
        
        if (!data.success) {
            showAlert('Error loading session data', 'danger');
            return;
        }
        
        const commands = data.commands;
        const overallScore = parseInt(document.getElementById('overallScore').value);
        const instructorFeedback = document.getElementById('instructorFeedback').value;
        const rating = document.querySelectorAll('.star.active').length;
        
        const commandFeedback = {};
        commands.forEach(cmd => {
            const feedbackInput = document.getElementById(`cmd_${cmd.id}`);
            if (feedbackInput && feedbackInput.value) {
                commandFeedback[cmd.command] = feedbackInput.value;
            }
        });
        
        const saveResponse = await fetch(API_BASE, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'save_feedback',
                session_id: sessionId,
                user_id: data.session.user_id,
                overall_score: overallScore,
                instructor_feedback: instructorFeedback,
                command_feedback: commandFeedback,
                rating: rating,
                graded_by: currentUser.id
            })
        });
        
        const saveData = await saveResponse.json();
        
        if (saveData.success) {
            showAlert('Feedback saved successfully!', 'success');
            
            // Update the sessions data to reflect the new grading status
            const sessionIndex = currentData.sessions.findIndex(s => s.session_id === sessionId);
            if (sessionIndex !== -1) {
                currentData.sessions[sessionIndex].has_feedback = 1;
            }
            
            // Immediately switch to the Grade View page
            viewGradePage(sessionId);
        } else {
            showAlert('Error saving feedback: ' + saveData.message, 'danger');
        }
    } catch (error) {
        console.error('Save feedback error:', error);
        showAlert('Error saving feedback', 'danger');
    }
}

// Reports and Analytics
async function loadReports() {
    try {
        const response = await fetch(`${API_BASE}?action=reports`);
        const data = await response.json();
        
        if (data.success) {
            updateReportStats(data.stats);
            createCommandUsageChart(data.charts.command_usage);
            createDurationChart(data.charts.duration);
        }
    } catch (error) {
        console.error('Reports load error:', error);
        showAlert('Error loading reports', 'danger');
    }
}

function updateReportStats(stats) {
    document.getElementById('reportTotalSessions').textContent = stats.total_sessions;
    document.getElementById('reportAvgDuration').textContent = stats.avg_duration;
    document.getElementById('reportTopCommand').textContent = stats.top_command;
    document.getElementById('reportCompletionRate').textContent = stats.completion_rate + '%';
}

function createCommandUsageChart(data) {
    // Destroy existing chart if it exists
    if (charts.commandUsage) {
        charts.commandUsage.destroy();
    }
    
    const ctx = document.getElementById('commandUsageChart').getContext('2d');
    charts.commandUsage = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Usage Count',
                data: data.values,
                backgroundColor: [
                    '#58a6ff', '#a9a7ff', '#3fb950', '#d29922', 
                    '#f85149', '#17a2b8', '#8b949e'
                ],
                borderColor: '#21262d',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                x: {
                    ticks: {
                        color: '#8b949e'
                    },
                    grid: {
                        color: '#30363d'
                    }
                },
                y: {
                    beginAtZero: true,
                    ticks: {
                        color: '#8b949e'
                    },
                    grid: {
                        color: '#30363d'
                    }
                }
            }
        }
    });
}

function createDurationChart(data) {
    // Destroy existing chart if it exists
    if (charts.duration) {
        charts.duration.destroy();
    }
    
    const ctx = document.getElementById('durationChart').getContext('2d');
    charts.duration = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Session Count',
                data: data.values,
                backgroundColor: '#58a6ff',
                borderColor: '#a9a7ff',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                x: {
                    ticks: {
                        color: '#8b949e'
                    },
                    grid: {
                        color: '#30363d'
                    }
                },
                y: {
                    beginAtZero: true,
                    ticks: {
                        color: '#8b949e'
                    },
                    grid: {
                        color: '#30363d'
                    }
                }
            }
        }
    });
}

// Session Detail Page View
async function viewSessionDetailPage(sessionId) {
    try {
        const response = await fetch(`${API_BASE}?action=session_detail&session_id=${sessionId}`);
        const data = await response.json();
        
        if (data.success) {
            const session = data.session;
            const user = currentData.users.find(u => u.id === session.user_id);
            const commands = data.commands;
            const conversations = data.conversations || [];
            
            // Create chronological timeline
            const timeline = [];
            
            // Add commands to timeline
            commands.forEach(cmd => {
                timeline.push({
                    type: 'command',
                    timestamp: cmd.timestamp,
                    data: cmd
                });
            });
            
            // Add conversations to timeline
            conversations.forEach(conv => {
                timeline.push({
                    type: 'conversation',
                    timestamp: conv.timestamp,
                    data: conv
                });
            });
            
            // Sort by timestamp
            timeline.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
            
            const content = `
                <div class="session-info">
                    <h4>Session Information</h4>
                    <p><strong>Session ID:</strong> ${session.session_id}</p>
                    <p><strong>User:</strong> ${user ? user.full_name : 'Unknown'}</p>
                    <p><strong>Hostname:</strong> ${session.hostname}</p>
                    <p><strong>IP Address:</strong> ${session.ip_address}</p>
                    <p><strong>Start Time:</strong> ${formatDate(session.start_time)}</p>
                    <p><strong>End Time:</strong> ${session.end_time ? formatDate(session.end_time) : 'Still active'}</p>
                    <p><strong>Status:</strong> ${session.status}</p>
                    <p><strong>OS Info:</strong> ${session.os_info || 'Not available'}</p>
                </div>
                
                <div class="grading-timeline">
                    <h4>Session Timeline (${timeline.length} Events)</h4>
                    ${timeline.map(item => {
                        if (item.type === 'command') {
                            return `
                                <div class="grading-timeline-item command-item">
                                    <div class="timeline-time">${formatDate(item.timestamp)}</div>
                                    <div class="timeline-content">
                                        <h5>Command: <code>${item.data.command}</code></h5>
                                        <p><strong>Status:</strong> <span class="status-badge status-${item.data.status}">${item.data.status}</span></p>
                                        <p><strong>Execution Time:</strong> ${item.data.execution_time ? item.data.execution_time + 's' : 'N/A'}</p>
                                        ${item.data.output ? `
                                            <div class="command-output-full">
                                                <strong>Output:</strong>
                                                <pre>${item.data.output}</pre>
                                            </div>
                                        ` : ''}
                                    </div>
                                </div>
                            `;
                        } else {
                            return `
                                <div class="grading-timeline-item conversation-item">
                                    <div class="timeline-time">${formatDate(item.timestamp)}</div>
                                    <div class="timeline-content">
                                        <h5>${item.data.message_type === 'user' ? 'Student Question' : 'Bot Response'}</h5>
                                        <div class="chat-message ${item.data.message_type}">
                                            ${item.data.message}
                                        </div>
                                    </div>
                                </div>
                            `;
                        }
                    }).join('')}
                </div>
            `;
            
            document.getElementById('sessionViewTitle').textContent = `Session: ${sessionId}`;
            document.getElementById('sessionViewContent').innerHTML = content;
            
            // Set up export buttons
            document.getElementById('sessionExportPDF').onclick = () => exportSessionDetail(sessionId, 'pdf');
            document.getElementById('sessionExportExcel').onclick = () => exportSessionDetail(sessionId, 'excel');
            
            // Show session view
            showSection('sessionView');
        }
    } catch (error) {
        console.error('Session detail error:', error);
        showAlert('Error loading session details', 'danger');
    }
}

// Grade View Page
async function viewGradePage(sessionId) {
    try {
        const response = await fetch(`${API_BASE}?action=grading_data&session_id=${sessionId}`);
        const data = await response.json();
        
        if (data.success) {
            const session = data.session;
            const user = currentData.users.find(u => u.id === session.user_id);
            const commands = data.commands;
            const conversations = data.conversations || [];
            const feedback = data.feedback;
            
            // Create chronological timeline
            const timeline = [];
            
            // Add commands to timeline
            commands.forEach(cmd => {
                timeline.push({
                    type: 'command',
                    timestamp: cmd.timestamp,
                    data: cmd
                });
            });
            
            // Add conversations to timeline
            conversations.forEach(conv => {
                timeline.push({
                    type: 'conversation',
                    timestamp: conv.timestamp,
                    data: conv
                });
            });
            
            // Sort by timestamp
            timeline.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
            
            const content = `
                <div class="session-info">
                    <h4>Session Information</h4>
                    <p><strong>Session ID:</strong> ${session.session_id}</p>
                    <p><strong>Student:</strong> ${user ? user.full_name : 'Unknown'}</p>
                    <p><strong>Session Date:</strong> ${formatDate(session.start_time)}</p>
                    <p><strong>Commands Executed:</strong> ${commands.length}</p>
                    <p><strong>Chat Interactions:</strong> ${conversations.length}</p>
                </div>
                
                <div class="feedback-display">
                    <h4>Grade Information</h4>
                    <p><strong>Overall Score:</strong> ${feedback?.overall_score || 'Not scored'}/100</p>
                    <p><strong>Rating:</strong> ${feedback?.rating ? '★'.repeat(feedback.rating) + '☆'.repeat(5-feedback.rating) : 'Not rated'}</p>
                    <p><strong>Instructor Feedback:</strong> ${feedback?.instructor_feedback || 'No feedback provided'}</p>
                    <p><strong>Graded by:</strong> ${currentData.users.find(u => u.id === feedback?.graded_by)?.full_name || 'Unknown'}</p>
                    <p><strong>Graded on:</strong> ${feedback?.graded_at ? formatDate(feedback.graded_at) : 'Not graded'}</p>
                </div>
                
                <div class="grading-timeline">
                    <h4>Session Timeline with Grades</h4>
                    ${timeline.map(item => {
                        if (item.type === 'command') {
                            const commandFeedback = feedback?.command_feedback?.[item.data.command] || '';
                            return `
                                <div class="grading-timeline-item command-item">
                                    <div class="timeline-time">${formatDate(item.timestamp)}</div>
                                    <div class="timeline-content">
                                        <h5>Command: <code>${item.data.command}</code></h5>
                                        <p><strong>Status:</strong> <span class="status-badge status-${item.data.status}">${item.data.status}</span></p>
                                        <p><strong>Execution Time:</strong> ${item.data.execution_time ? item.data.execution_time + 's' : 'N/A'}</p>
                                        ${item.data.output ? `
                                            <div class="command-output-full">
                                                <strong>Output:</strong>
                                                <pre>${item.data.output}</pre>
                                            </div>
                                        ` : ''}
                                        ${commandFeedback ? `
                                            <div class="feedback-display" style="margin-top: 10px; background: rgba(63, 185, 80, 0.05);">
                                                <strong>Instructor Feedback:</strong> ${commandFeedback}
                                            </div>
                                        ` : ''}
                                        <div class="form-group" style="display: none;" id="edit-cmd-${item.data.id}">
                                            <label class="form-label">Edit feedback for this command:</label>
                                            <input type="text" class="form-input" id="edit-input-${item.data.id}" 
                                                   value="${commandFeedback}" 
                                                   placeholder="Enter feedback for this command">
                                        </div>
                                    </div>
                                </div>
                            `;
                        } else {
                            return `
                                <div class="grading-timeline-item conversation-item">
                                    <div class="timeline-time">${formatDate(item.timestamp)}</div>
                                    <div class="timeline-content">
                                        <h5>${item.data.message_type === 'user' ? 'Student Question' : 'Bot Response'}</h5>
                                        <div class="chat-message ${item.data.message_type}">
                                            ${item.data.message}
                                        </div>
                                    </div>
                                </div>
                            `;
                        }
                    }).join('')}
                </div>
                
                <div class="feedback-section" style="display: none;" id="editGradeSection">
                    <h4>Edit Overall Grade</h4>
                    <div class="grade-input">
                        <label class="form-label">Overall Score (0-100):</label>
                        <input type="number" id="editOverallScore" class="form-input" min="0" max="100" 
                               value="${feedback?.overall_score || ''}" style="width: 100px;"
                               oninput="this.value = Math.max(0, Math.min(100, this.value))">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Overall Rating:</label>
                        <div class="rating-stars" id="editRatingStars">
                            ${[1,2,3,4,5].map(i => 
                                `<span class="star ${(feedback?.rating >= i) ? 'active' : ''}" 
                                       onclick="setEditRating(${i})">★</span>`
                            ).join('')}
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Instructor Feedback:</label>
                        <textarea class="form-input" id="editInstructorFeedback" rows="4" 
                                  placeholder="Provide overall feedback for the student">${feedback?.instructor_feedback || ''}</textarea>
                    </div>
                </div>
            `;
            
            document.getElementById('gradeViewTitle').textContent = `Grade: ${sessionId}`;
            document.getElementById('gradeViewContent').innerHTML = content;
            document.getElementById('gradeEditControls').style.display = 'block';
            
            // Store session ID for editing
            window.currentEditingSessionId = sessionId;
            
            // Show grade view
            showSection('gradeView');
        }
    } catch (error) {
        console.error('Grade view error:', error);
        showAlert('Error loading grade details', 'danger');
    }
}

// Grade editing functions
function enableGradeEditing() {
    // Show edit controls
    document.getElementById('saveGradeBtn').style.display = 'inline-block';
    document.getElementById('cancelGradeBtn').style.display = 'inline-block';
    document.querySelector('[onclick="enableGradeEditing()"]').style.display = 'none';
    
    // Show edit section
    document.getElementById('editGradeSection').style.display = 'block';
    
    // Show command feedback edit inputs
    document.querySelectorAll('[id^="edit-cmd-"]').forEach(el => {
        el.style.display = 'block';
    });
}

function cancelGradeEditing() {
    // Hide edit controls
    document.getElementById('saveGradeBtn').style.display = 'none';
    document.getElementById('cancelGradeBtn').style.display = 'none';
    document.querySelector('[onclick="enableGradeEditing()"]').style.display = 'inline-block';
    
    // Hide edit section
    document.getElementById('editGradeSection').style.display = 'none';
    
    // Hide command feedback edit inputs
    document.querySelectorAll('[id^="edit-cmd-"]').forEach(el => {
        el.style.display = 'none';
    });
}

function setEditRating(rating) {
    const stars = document.querySelectorAll('#editRatingStars .star');
    stars.forEach((star, index) => {
        star.classList.toggle('active', index < rating);
    });
}

async function saveGradeEdits() {
    try {
        const sessionId = window.currentEditingSessionId;
        const response = await fetch(`${API_BASE}?action=grading_data&session_id=${sessionId}`);
        const data = await response.json();
        
        if (!data.success) {
            showAlert('Error loading session data', 'danger');
            return;
        }
        
        const commands = data.commands;
        const overallScore = parseInt(document.getElementById('editOverallScore').value);
        const instructorFeedback = document.getElementById('editInstructorFeedback').value;
        const rating = document.querySelectorAll('#editRatingStars .star.active').length;
        
        const commandFeedback = {};
        commands.forEach(cmd => {
            const feedbackInput = document.getElementById(`edit-input-${cmd.id}`);
            if (feedbackInput && feedbackInput.value) {
                commandFeedback[cmd.command] = feedbackInput.value;
            }
        });
        
        const saveResponse = await fetch(API_BASE, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'save_feedback',
                session_id: sessionId,
                user_id: data.session.user_id,
                overall_score: overallScore,
                instructor_feedback: instructorFeedback,
                command_feedback: commandFeedback,
                rating: rating,
                graded_by: currentUser.id
            })
        });
        
        const saveData = await saveResponse.json();
        
        if (saveData.success) {
            showAlert('Grade updated successfully!', 'success');
            cancelGradeEditing();
            // Reload the grade view to show updated data
            viewGradePage(sessionId);
        } else {
            showAlert('Error saving grade: ' + saveData.message, 'danger');
        }
    } catch (error) {
        console.error('Save grade error:', error);
        showAlert('Error saving grade', 'danger');
    }
}

function backToSessions() {
    showSection('sessions');
}