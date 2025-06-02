<?php
require_once '../../db_config.php'; // Adjust path to db_config.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // TODO: Restrict in production
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

// TODO: Implement robust admin authentication/authorization check here.
// For example, check for a valid admin session token.
// if (!isAdmin()) { 
//     http_response_code(403); // Forbidden
//     echo json_encode(['message' => 'Access denied. Admin privileges required.']);
//     exit;
// }

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['message' => 'Only POST method is allowed.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));

// Basic Validation
if (
    !isset($data->admin_user_id) || !is_numeric($data->admin_user_id) ||
    !isset($data->action_type) || empty(trim($data->action_type))
) {
    http_response_code(400); // Bad Request
    echo json_encode(['message' => 'Invalid input. admin_user_id (numeric) and action_type (string) are required.']);
    exit;
}

$admin_user_id = intval($data->admin_user_id);
$action_type = trim($data->action_type);
$target_type = isset($data->target_type) ? trim($data->target_type) : null;
$target_id = isset($data->target_id) && is_numeric($data->target_id) ? intval($data->target_id) : null;
$details = isset($data->details) ? trim($data->details) : null;

// Insert Log
$stmt = $conn->prepare("INSERT INTO admin_actions_log (admin_user_id, action_type, target_type, target_id, details) VALUES (?, ?, ?, ?, ?)");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(['message' => 'Database error (prepare insert log): ' . $conn->error]);
    $conn->close();
    exit;
}

$stmt->bind_param("issis", $admin_user_id, $action_type, $target_type, $target_id, $details);

if ($stmt->execute()) {
    http_response_code(201); // Created
    echo json_encode(['message' => 'Action log created successfully.', 'log_id' => $stmt->insert_id]);
} else {
    http_response_code(500); // Internal Server Error
    echo json_encode(['message' => 'Failed to create action log. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>