<?php
require_once '../../db_config.php'; // Adjust path

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// TODO: Implement user authentication here. The reporter_user_id should come from the authenticated user.
// For admin use, ensure admin is authenticated.
// if (!isAuthenticated()) { http_response_code(401); echo json_encode(['message' => 'Authentication required.']); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['message' => 'Only POST method is allowed.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));

if (
    !isset($data->reporter_user_id) || !is_numeric($data->reporter_user_id) ||
    !isset($data->reported_item_type) || empty(trim($data->reported_item_type)) ||
    !isset($data->reported_item_id) || !is_numeric($data->reported_item_id) ||
    !isset($data->reason) || empty(trim($data->reason))
) {
    http_response_code(400);
    echo json_encode(['message' => 'Invalid input. reporter_user_id, reported_item_type, reported_item_id, and reason are required.']);
    exit;
}

$reporter_user_id = intval($data->reporter_user_id);
$reported_item_type = trim($data->reported_item_type);
$reported_item_id = intval($data->reported_item_id);
$reason = trim($data->reason);
$status = 'pending_review'; // Default status

$stmt = $conn->prepare("INSERT INTO reported_content (reporter_user_id, reported_item_type, reported_item_id, reason, status) VALUES (?, ?, ?, ?, ?)");
if (!$stmt) {
    http_response_code(500); echo json_encode(['message' => 'DB error (submit report): ' . $conn->error]); $conn->close(); exit;
}
$stmt->bind_param("isiss", $reporter_user_id, $reported_item_type, $reported_item_id, $reason, $status);

if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode(['message' => 'Report submitted successfully.', 'report_id' => $stmt->insert_id]);
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to submit report. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>