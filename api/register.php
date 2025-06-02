<?php
require_once '../db_config.php'; // Assumes db_config.php is one level up

// Enable error reporting for development (disable in production)
// error_reporting(E_ALL);
// ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // TODO: Restrict in production
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['message' => 'Only POST method is allowed.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));

// Basic Validation (expand this significantly in a real application)
if (
    !isset($data->name) || empty(trim($data->name)) ||
    !isset($data->email) || !filter_var(trim($data->email), FILTER_VALIDATE_EMAIL) ||
    !isset($data->password) || strlen($data->password) < 8
) {
    http_response_code(400); // Bad Request
    echo json_encode(['message' => 'Invalid input. Name, valid email, and password (min 8 chars) are required.']);
    exit;
}

$name = trim($data->name);
$company = isset($data->company) && !empty(trim($data->company)) ? trim($data->company) : null;
$email = trim($data->email);
$phone = isset($data->phone) && !empty(trim($data->phone)) ? trim($data->phone) : null;
$password = $data->password; // Raw password
$role = isset($data->role) && !empty(trim($data->role)) ? trim($data->role) : 'user'; // Added role, defaults to 'user'

// Password Hashing
$password_hash = password_hash($password, PASSWORD_BCRYPT);
if ($password_hash === false) {
    http_response_code(500); 
    echo json_encode(['message' => 'Failed to hash password.']);
    exit;
}

// Check if email already exists using mysqli
$stmt_check_email = $conn->prepare("SELECT id FROM users WHERE email = ?");
if (!$stmt_check_email) {
    http_response_code(500);
    echo json_encode(['message' => 'Database error (prepare check email): ' . $conn->error]);
    $conn->close();
    exit;
}
$stmt_check_email->bind_param("s", $email);
$stmt_check_email->execute();
$stmt_check_email->store_result();

if ($stmt_check_email->num_rows > 0) {
    http_response_code(409); // Conflict
    echo json_encode(['message' => 'Email already registered.']);
    $stmt_check_email->close();
    $conn->close();
    exit;
}
$stmt_check_email->close();

// Insert User (Using Prepared Statement with mysqli)
// Added 'role' to the SQL query
$stmt_insert = $conn->prepare("INSERT INTO users (name, company, email, phone, password_hash, role) VALUES (?, ?, ?, ?, ?, ?)");
if (!$stmt_insert) {
    http_response_code(500);
    echo json_encode(['message' => 'Database error (prepare insert): ' . $conn->error]);
    $conn->close();
    exit;
}

// Added 's' for role in bind_param
$stmt_insert->bind_param("ssssss", $name, $company, $email, $phone, $password_hash, $role);

if ($stmt_insert->execute()) {
    http_response_code(201); // Created
    echo json_encode(['message' => '¡Registro exitoso! Ahora puedes iniciar sesión.']);
} else {
    http_response_code(500); // Internal Server Error
    echo json_encode(['message' => 'Registration failed. Error: ' . $stmt_insert->error]);
}

$stmt_insert->close();
$conn->close();
?>