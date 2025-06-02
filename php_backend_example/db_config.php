<?php
define('DB_SERVER', 'mihogarideal.com.mx'); // e.g., 'localhost' or Hostinger's DB host
define('DB_USERNAME', 'u216482496_klinyMXN');
define('DB_PASSWORD', '1315.Juan');
define('DB_NAME', 'u216482496_mihogarideal');

// Create connection using mysqli or PDO
// For mysqli:
$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

// Check connection
if ($conn->connect_error) {
    // In a real app, you'd log this error and return a generic error message
    // For API, ensure JSON response even for critical errors if possible, or ensure server handles this.
    header('Content-Type: application/json');
    http_response_code(500); // Internal Server Error
    echo json_encode(['message' => 'Database connection failed: ' . $conn->connect_error]); // More specific for debugging
    exit;
}

// Set charset (optional, but good practice)
if (!$conn->set_charset("utf8mb4")) {
    // Log error if charset setting fails, but might not need to halt execution
    // error_log("Error loading character set utf8mb4: %s
", $conn->error);
}

// PDO example (alternative to mysqli):
/*
try {
    $dsn = "mysql:host=" . DB_SERVER . ";dbname=" . DB_NAME . ";charset=utf8mb4";
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];
    $pdo_conn = new PDO($dsn, DB_USERNAME, DB_PASSWORD, $options);
} catch (PDOException $e) {
    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode(['message' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}
// Use $pdo_conn for PDO operations
*/

// Important: This script will be included by others.
// Avoid echoing anything here unless it's an unrecoverable error exit.
?>