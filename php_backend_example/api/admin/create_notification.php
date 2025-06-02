<?php
require_once '../../db_config.php'; // Adjust path

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// TODO: Implement admin authentication/authorization OR system-level trigger logic.
// if (!isAdminOrSystem()) { http_response_code(403); echo json_encode(['message' => 'Access denied.']); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['message' => 'Only POST method is allowed.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));

if (
    !isset($data->type) || empty(trim($data->type)) ||
    !isset($data->message) || empty(trim($data->message))
) {
    http_response_code(400);
    echo json_encode(['message' => 'Invalid input. type and message are required.']);
    exit;
}

$recipient_admin_id = isset($data->recipient_admin_id) && is_numeric($data->recipient_admin_id) ? intval($data->recipient_admin_id) : null;
$type = trim($data->type);
$message = trim($data->message);
$link = isset($data->link) ? trim($data->link) : null;

$stmt = $conn->prepare("INSERT INTO admin_notifications (recipient_admin_id, type, message, link) VALUES (?, ?, ?, ?)");
if (!$stmt) {
    http_response_code(500); echo json_encode(['message' => 'DB error (create notification): ' . $conn->error]); $conn->close(); exit;
}
$stmt->bind_param("isss", $recipient_admin_id, $type, $message, $link);

if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode(['message' => 'Notification created successfully.', 'notification_id' => $stmt->insert_id]);
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to create notification. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>