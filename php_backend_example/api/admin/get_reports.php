<?php
require_once '../../db_config.php'; // Adjust path

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// TODO: Implement admin authentication/authorization check here.
// if (!isAdmin()) { http_response_code(403); echo json_encode(['message' => 'Admin access required.']); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['message' => 'Only GET method is allowed.']);
    exit;
}

// Filtering options
$status_filter = isset($_GET['status']) ? trim($_GET['status']) : null;
$item_type_filter = isset($_GET['item_type']) ? trim($_GET['item_type']) : null;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
$offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0;

$sql = "SELECT rc.report_id, rc.reporter_user_id, u_reporter.name as reporter_name, rc.reported_item_type, rc.reported_item_id, rc.reason, rc.status, rc.admin_reviewer_id, u_reviewer.name as reviewer_name, rc.review_notes, rc.report_timestamp, rc.review_timestamp 
        FROM reported_content rc
        LEFT JOIN users u_reporter ON rc.reporter_user_id = u_reporter.id
        LEFT JOIN users u_reviewer ON rc.admin_reviewer_id = u_reviewer.id";

$conditions = [];
$params = [];
$types = '';

if ($status_filter !== null) {
    $conditions[] = "rc.status = ?";
    $params[] = $status_filter;
    $types .= 's';
}
if ($item_type_filter !== null) {
    $conditions[] = "rc.reported_item_type = ?";
    $params[] = $item_type_filter;
    $types .= 's';
}

if (count($conditions) > 0) {
    $sql .= " WHERE " . implode(" AND ", $conditions);
}

$sql .= " ORDER BY rc.report_timestamp DESC LIMIT ? OFFSET ?";
$params[] = $limit;
$params[] = $offset;
$types .= 'ii';

$stmt = $conn->prepare($sql);
if (!$stmt) {
    http_response_code(500); echo json_encode(['message' => 'DB error (get reports): ' . $conn->error]); $conn->close(); exit;
}

if (!empty($types) && count($params) > 0) {
    $stmt->bind_param($types, ...$params);
}

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $reports = [];
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
    http_response_code(200);
    echo json_encode($reports);
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to retrieve reports. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>