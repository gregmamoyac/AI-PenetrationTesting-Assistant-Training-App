CREATE USER 'svc_ghostcrew_admin'@'localhost' IDENTIFIED BY 'SecureP@ssw0rd2024!';
GRANT ALL PRIVILEGES ON ghostcrew_admin.* TO 'svc_ghostcrew_admin'@'localhost';
CREATE USER 'svc_terminal-app'@'localhost' IDENTIFIED BY 'HxjV[pHnF)5riLPh';
GRANT ALL PRIVILEGES ON terminal_app.* TO 'svc_terminal-app'@'localhost';
FLUSH PRIVILEGES;