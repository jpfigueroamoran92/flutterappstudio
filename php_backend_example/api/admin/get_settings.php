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

$setting_key_filter = isset($_GET['setting_key']) ? trim($_GET['setting_key']) : null;

if ($setting_key_filter !== null) {
    // Get specific setting by key
    $stmt = $conn->prepare("SELECT setting_id, setting_key, setting_value, description, last_updated_by_admin_id, last_updated_timestamp FROM site_settings WHERE setting_key = ?");
    if (!$stmt) {
        http_response_code(500); echo json_encode(['message' => 'DB error (get setting by key): ' . $conn->error]); $conn->close(); exit;
    }
    $stmt->bind_param("s", $setting_key_filter);
    if ($stmt->execute()) {
        $result = $stmt->get_result();
        if ($setting = $result->fetch_assoc()) {
            http_response_code(200);
            echo json_encode($setting);
        } else {
            http_response_code(404);
            echo json_encode(['message' => 'Setting not found.']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to retrieve setting. Error: ' . $stmt->error]);
    }
    $stmt->close();
} else {
    // Get all settings
    $result = $conn->query("SELECT setting_id, setting_key, setting_value, description, last_updated_by_admin_id, last_updated_timestamp FROM site_settings ORDER BY setting_key ASC");
    if ($result) {
        $settings = [];
        while ($row = $result->fetch_assoc()) {
            $settings[] = $row;
        }
        http_response_code(200);
        echo json_encode($settings);
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to retrieve settings. Error: ' . $conn->error]);
    }
}

$conn->close();
?>