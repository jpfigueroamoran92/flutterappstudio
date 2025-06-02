<?php
require_once '../../db_config.php'; // Adjust path to db_config.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); // TODO: Restrict in production
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

// TODO: Implement robust admin authentication/authorization check here.
// if (!isAdmin()) { 
//     http_response_code(403); // Forbidden
//     echo json_encode(['message' => 'Access denied. Admin privileges required.']);
//     exit;
// }

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['message' => 'Only GET method is allowed.']);
    exit;
}

// Basic filtering (example - can be expanded)
$admin_user_id_filter = isset($_GET['admin_user_id']) ? intval($_GET['admin_user_id']) : null;
$action_type_filter = isset($_GET['action_type']) ? trim($_GET['action_type']) : null;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20; // Default limit
$offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0; // Default offset for pagination

$sql = "SELECT log_id, admin_user_id, action_type, target_type, target_id, details, action_timestamp FROM admin_actions_log";
$conditions = [];
$params = [];
$types = '';

if ($admin_user_id_filter !== null) {
    $conditions[] = "admin_user_id = ?";
    $params[] = $admin_user_id_filter;
    $types .= 'i';
}
if ($action_type_filter !== null) {
    $conditions[] = "action_type LIKE ?";
    $params[] = "%{$action_type_filter}%";
    $types .= 's';
}

if (count($conditions) > 0) {
    $sql .= " WHERE " . implode(" AND ", $conditions);
}

$sql .= " ORDER BY action_timestamp DESC LIMIT ? OFFSET ?";
$params[] = $limit;
$params[] = $offset;
$types .= 'ii';

$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);
    echo json_encode(['message' => 'Database error (prepare select logs): ' . $conn->error]);
    $conn->close();
    exit;
}

if (!empty($types) && count($params) > 0) {
    $stmt->bind_param($types, ...$params);
}

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $logs = [];
    while ($row = $result->fetch_assoc()) {
        $logs[] = $row;
    }
    http_response_code(200);
    echo json_encode($logs);
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to retrieve action logs. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>