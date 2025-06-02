<?php
require_once '../../db_config.php'; // Adjust path

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// TODO: Implement admin authentication/authorization check here.
// if (!isAdmin()) { http_response_code(403); echo json_encode(['message' => 'Admin access required.']); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['message' => 'Only POST method is allowed.']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->setting_key) || empty(trim($data->setting_key)) || !isset($data->admin_user_id) || !is_numeric($data->admin_user_id)) {
    http_response_code(400);
    echo json_encode(['message' => 'Invalid input. setting_key (string) and admin_user_id (numeric) are required.']);
    exit;
}

$setting_key = trim($data->setting_key);
$setting_value = isset($data->setting_value) ? $data->setting_value : null; // Value can be various types, often stored as string/text
$description = isset($data->description) ? trim($data->description) : null;
$admin_user_id = intval($data->admin_user_id);

// Check if setting exists
$stmt_check = $conn->prepare("SELECT setting_id FROM site_settings WHERE setting_key = ?");
if (!$stmt_check) {
    http_response_code(500); echo json_encode(['message' => 'DB error (check setting): ' . $conn->error]); $conn->close(); exit;
}
$stmt_check->bind_param("s", $setting_key);
$stmt_check->execute();
$stmt_check->store_result();
$exists = $stmt_check->num_rows > 0;
$stmt_check->close();

if ($exists) {
    // Update existing setting
    $stmt_update = $conn->prepare("UPDATE site_settings SET setting_value = ?, description = ?, last_updated_by_admin_id = ? WHERE setting_key = ?");
    if (!$stmt_update) {
        http_response_code(500); echo json_encode(['message' => 'DB error (update setting): ' . $conn->error]); $conn->close(); exit;
    }
    $stmt_update->bind_param("ssis", $setting_value, $description, $admin_user_id, $setting_key);
    if ($stmt_update->execute()) {
        http_response_code(200);
        echo json_encode(['message' => 'Site setting updated successfully.']);
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to update site setting. Error: ' . $stmt_update->error]);
    }
    $stmt_update->close();
} else {
    // Create new setting
    $stmt_insert = $conn->prepare("INSERT INTO site_settings (setting_key, setting_value, description, last_updated_by_admin_id) VALUES (?, ?, ?, ?)");
    if (!$stmt_insert) {
        http_response_code(500); echo json_encode(['message' => 'DB error (insert setting): ' . $conn->error]); $conn->close(); exit;
    }
    $stmt_insert->bind_param("sssi", $setting_key, $setting_value, $description, $admin_user_id);
    if ($stmt_insert->execute()) {
        http_response_code(201);
        echo json_encode(['message' => 'Site setting created successfully.', 'setting_id' => $stmt_insert->insert_id]);
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to create site setting. Error: ' . $stmt_insert->error]);
    }
    $stmt_insert->close();
}

$conn->close();
?>