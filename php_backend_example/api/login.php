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
    http_response_code(405);
    echo json_encode(['message' => 'Only POST method is allowed.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->email) || empty(trim($data->email)) || !isset($data->password) || empty($data->password)) {
    http_response_code(400);
    echo json_encode(['message' => 'Email and password are required.']);
    exit;
}

$email = trim($data->email);
$password = $data->password; // Raw password

// Fetch User (Using Prepared Statement with mysqli)
$stmt_select_user = $conn->prepare("SELECT id, name, company, email, phone, password_hash FROM users WHERE email = ?");
if (!$stmt_select_user) {
    http_response_code(500);
    echo json_encode(['message' => 'Database error (prepare select user): ' . $conn->error]);
    $conn->close();
    exit;
}

$stmt_select_user->bind_param("s", $email);
$stmt_select_user->execute();
$result = $stmt_select_user->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();

    // Verify Password
    if (password_verify($password, $user['password_hash'])) {
        // Login Successful
        // Generate a secure token. For production, JWT is recommended.
        // This is a placeholder token for demonstration.
        // You would typically store and manage tokens more robustly.
        $token = bin2hex(random_bytes(32)); // Example: A 64-character hex token

        $user_data_for_client = [
            'id' => (int)$user['id'], // Ensure ID is int
            'name' => $user['name'],
            'company' => $user['company'],
            'email' => $user['email'],
            'phone' => $user['phone'],
            'token' => $token 
        ];

        http_response_code(200);
        echo json_encode($user_data_for_client);
    } else {
        http_response_code(401); // Unauthorized
        echo json_encode(['message' => 'Invalid email or password.']);
    }
} else {
    http_response_code(401); // Unauthorized
    echo json_encode(['message' => 'Invalid email or password.']); // Keep message generic for security
}

$stmt_select_user->close();
$conn->close();
?>