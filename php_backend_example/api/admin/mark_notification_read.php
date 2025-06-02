<?php
require_once '../../db_config.php'; // Adjust path

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, PUT');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// TODO: Implement admin authentication/authorization check here.
// Make sure the admin can only mark THEIR notifications as read, or an admin can mark any.
// if (!isAdmin()) { http_response_code(403); echo json_encode(['message' => 'Admin access required.']); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'PUT') {
    http_response_code(405);
    echo json_encode(['message' => 'Only POST or PUT methods are allowed.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->notification_id) || !is_numeric($data->notification_id)) {
    http_response_code(400);
    echo json_encode(['message' => 'Invalid input. notification_id is required.']);
    exit;
}

$notification_id = intval($data->notification_id);
// Optional: $admin_id = getAuthenticatedAdminId(); // To ensure only the recipient or a superadmin marks as read.

$stmt = $conn->prepare("UPDATE admin_notifications SET is_read = TRUE WHERE notification_id = ?"); 
// Add AND recipient_admin_id = ? if an admin can only mark their own notifications.
if (!$stmt) {
    http_response_code(500); echo json_encode(['message' => 'DB error (mark read): ' . $conn->error]); $conn->close(); exit;
}
$stmt->bind_param("i", $notification_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200);
        echo json_encode(['message' => 'Notification marked as read.']);
    } else {
        http_response_code(404);
        echo json_encode(['message' => 'Notification not found or already marked as read.']);
    }
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to mark notification as read. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>