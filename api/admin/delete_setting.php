<?php
require_once '../../db_config.php'; // Adjust path

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, DELETE'); // Allow POST for form-based delete or DELETE for direct HTTP DELETE
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// TODO: Implement admin authentication/authorization check here.
// if (!isAdmin()) { http_response_code(403); echo json_encode(['message' => 'Admin access required.']); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    http_response_code(405);
    echo json_encode(['message' => 'Only POST or DELETE methods are allowed.']);
    exit;
}

$setting_key = null;
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // For DELETE, key might be in query string or simple text body, typically query string
    $setting_key = isset($_GET['setting_key']) ? trim($_GET['setting_key']) : null;
} else { // POST
    $data = json_decode(file_get_contents("php://input"));
    $setting_key = isset($data->setting_key) ? trim($data->setting_key) : null;
}

if (empty($setting_key)) {
    http_response_code(400);
    echo json_encode(['message' => 'Invalid input. setting_key is required.']);
    exit;
}

$stmt = $conn->prepare("DELETE FROM site_settings WHERE setting_key = ?");
if (!$stmt) {
    http_response_code(500); echo json_encode(['message' => 'DB error (delete setting): ' . $conn->error]); $conn->close(); exit;
}
$stmt->bind_param("s", $setting_key);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200);
        echo json_encode(['message' => 'Site setting deleted successfully.']);
    } else {
        http_response_code(404);
        echo json_encode(['message' => 'Site setting not found or already deleted.']);
    }
} else {
    http_response_code(500);
    echo json_encode(['message' => 'Failed to delete site setting. Error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>