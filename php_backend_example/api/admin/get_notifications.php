<?php
require_once '../../db_config.php'; // Adjust path

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// TODO: Implement admin authentication/authorization check here.
// The recipient_admin_id should ideally come from the authenticated admin's ID.
// if (!isAdmin()) { http_response_code(403); echo json_encode(['message' => 'Admin access required.']); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['message' => 'Only GET method is allowed.']);
    exit;
}

// Assume admin_id is passed for targeted notifications, or fetch all unread for any admin if not specified (or based on role)
$admin_id_filter = isset($_GET['admin_id']) ? intval($_GET['admin_id']) : null; // ID of the logged-in admin
$only_unread = isset($_GET['unread']) && $_GET['unread'] == 'true';
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;
$offset = isset($_GET['offset']) ? intval($_GET['offset']) : 0;

$sql = "SELECT notification_id, recipient_admin_id, type, message, is_read, link, creation_timestamp FROM admin_notifications";
$conditions = [];
$params = [];
$types = '';

// Show notifications for this specific admin OR global notifications (recipient_admin_id IS NULL)
if ($admin_id_filter !== null) {
    $conditions[] = "(recipient_admin_id = ? OR recipient_admin_id IS NULL)";
    $params[] = $admin_id_filter;
    $types .= 'i';
} else {
    // If no specific admin_id, maybe show only global ones or based on other logic
    // For now, we will just not filter by admin if not provided. This might need refinement.
}

if ($only_unread) {
    $conditions[] = "is_read = FALSE";
}

if (count($conditions) > 0) {
    $sql .= " WHERE " . implode(" AND ", $conditions);
}

$sql .= " ORDER BY creation_timestamp DESC LIMIT ? OFFSET ?";
$params[] = $limit;
$params[] = $offset;
$types .= 'ii';

$stmt = $conn->prepare($sql);
if (!$stmt) {
    http_response_code(500); echo json_encode(['message' => 'DB error (get notifications): ' . $conn->error]); $conn->close(); exit;
}

if (!empty($types) && count($params) > 0) {
    $stmt->bind_param($types, ...$params);
}

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $notifications = [];
    while ($row = $result->fetch_assoc()) {
        $notifications[] = $row;
    }
    http_response_code(200);
    echo json_encode($notifications);
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to retrieve notifications. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>