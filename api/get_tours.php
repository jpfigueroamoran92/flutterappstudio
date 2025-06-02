<?php
require_once '../db_config.php'; // Assumes db_config.php is one level up

// Enable error reporting for development (disable in production)
// error_reporting(E_ALL);
// ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // TODO: Restrict in production
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Access-Control-Allow-Headers, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['message' => 'Only GET method is allowed.']);
    exit;
}

// Token Authentication
$headers = getallheaders();
$auth_header_key_exists_authorization = isset($headers['Authorization']);
$auth_header_key_exists_authorization_lc = isset($headers['authorization']); // Some servers might lowercase it

$auth_header = null;
if ($auth_header_key_exists_authorization) {
    $auth_header = $headers['Authorization'];
} elseif ($auth_header_key_exists_authorization_lc) {
    $auth_header = $headers['authorization'];
}

if (!$auth_header) {
    http_response_code(401);
    echo json_encode(['message' => 'Authorization header missing.']);
    $conn->close();
    exit;
}

$token_parts = explode(' ', $auth_header);
if (count($token_parts) !== 2 || strcasecmp($token_parts[0], 'Bearer') !== 0 || empty($token_parts[1])) {
    http_response_code(401);
    echo json_encode(['message' => 'Invalid token format. Expected "Bearer <token>".']);
    $conn->close();
    exit;
}

$received_token = $token_parts[1];

// --- Token Validation --- 
// This is a placeholder. You need to implement a robust way to validate the token
// against what was issued and stored (e.g., in a tokens table associated with user_id, or by verifying a JWT signature).
// For this simplistic example, let's assume the token directly contains the user_id after a prefix for demo purposes.
// DO NOT USE THIS SIMPLISTIC TOKEN VALIDATION IN PRODUCTION.
// Example: if token format from login was "someprefix_USERID"
// $user_id = (int) str_replace('someprefix_','', $received_token); 

// A more realistic (but still basic) approach if login.php generated "randomstring_uidUSERID":
$user_id = null;
if (strpos($received_token, "_uid") !== false) {
    // This part is just to simulate extracting user ID from the placeholder token format
    // In a real app, you would query a `tokens` table or validate a JWT.
    $token_check_parts = explode("_uid", $received_token);
    if (isset($token_check_parts[1]) && is_numeric($token_check_parts[1])) {
        // Here you would typically look up $received_token in a database table 
        // to see if it's a valid, non-expired token for $token_check_parts[1].
        // For now, we'll just assume if it contains _uid<number>, it implies the user id for demo.
        $user_id_from_token = (int)$token_check_parts[1]; 
        // Placeholder: In a real app, verify $received_token against a database.
        // For now, we accept $user_id_from_token if valid.
        $user_id = $user_id_from_token;
    }
}

if ($user_id === null) { // If token validation fails
    http_response_code(401);
    echo json_encode(['message' => 'Invalid or expired token.']);
    $conn->close();
    exit;
}

// Fetch Tours for the Authenticated User (Using Prepared Statement with mysqli)
$stmt_select_tours = $conn->prepare(
    "SELECT id, user_id, name, address, views_count, kuula_share_link, image_url, created_at " . 
    "FROM tours WHERE user_id = ? ORDER BY created_at DESC"
);
if (!$stmt_select_tours) {
    http_response_code(500);
    echo json_encode(['message' => 'Database error (prepare select tours): ' . $conn->error]);
    $conn->close();
    exit;
}

$stmt_select_tours->bind_param("i", $user_id); // i = integer
$stmt_select_tours->execute();
$result = $stmt_select_tours->get_result();

$tours = [];
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Ensure correct data types for JSON, matching Flutter models
        $row['id'] = (int)$row['id'];
        $row['user_id'] = (int)$row['user_id'];
        $row['views_count'] = (int)$row['views_count'];
        // image_url and address can be null, so no casting needed if they are already string/null
        $tours[] = $row;
    }
}

http_response_code(200);
echo json_encode($tours); // Return array of tours, even if empty

$stmt_select_tours->close();
$conn->close();
?>