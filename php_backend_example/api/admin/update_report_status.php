<?php
require_once '../../db_config.php'; // Adjust path

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, PUT'); // Allow POST or PUT
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// TODO: Implement admin authentication/authorization check here.
// if (!isAdmin()) { http_response_code(403); echo json_encode(['message' => 'Admin access required.']); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'PUT') {
    http_response_code(405);
    echo json_encode(['message' => 'Only POST or PUT methods are allowed.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));

if (
    !isset($data->report_id) || !is_numeric($data->report_id) ||
    !isset($data->status) || empty(trim($data->status)) ||
    !isset($data->admin_reviewer_id) || !is_numeric($data->admin_reviewer_id) // Admin taking action
) {
    http_response_code(400);
    echo json_encode(['message' => 'Invalid input. report_id, status, and admin_reviewer_id are required.']);
    exit;
}

$report_id = intval($data->report_id);
$status = trim($data->status);
$admin_reviewer_id = intval($data->admin_reviewer_id);
$review_notes = isset($data->review_notes) ? trim($data->review_notes) : null;
$review_timestamp = date('Y-m-d H:i:s'); // Current time for review

$stmt = $conn->prepare("UPDATE reported_content SET status = ?, admin_reviewer_id = ?, review_notes = ?, review_timestamp = ? WHERE report_id = ?");
if (!$stmt) {
    http_response_code(500); echo json_encode(['message' => 'DB error (update report): ' . $conn->error]); $conn->close(); exit;
}
$stmt->bind_param("sissi", $status, $admin_reviewer_id, $review_notes, $review_timestamp, $report_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200);
        echo json_encode(['message' => 'Report status updated successfully.']);
    } else {
        http_response_code(404);
        echo json_encode(['message' => 'Report not found or status unchanged.']);
    }
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to update report status. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>