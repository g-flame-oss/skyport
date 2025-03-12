<?php
// download.php - Handles secure file downloads

// Configuration
$downloadDirectory = '/var/www/html/downloads/';
$allowedExtensions = ['pdf', 'zip', 'doc', 'docx', 'jpg', 'png', 'txt'];

// Get requested file
$requestedFile = isset($_GET['file']) ? basename($_GET['file']) : '';

// Security checks
if (empty($requestedFile)) {
    die('No file specified');
}

// Check for directory traversal attempts
if (strpos($requestedFile, '..') !== false || strpos($requestedFile, '/') !== false) {
    die('Invalid file request');
}

// Build full file path
$filePath = $downloadDirectory . $requestedFile;

// Check if file exists
if (!file_exists($filePath) || !is_file($filePath)) {
    die('File not found');
}

// Check file extension
$extension = strtolower(pathinfo($requestedFile, PATHINFO_EXTENSION));
if (!in_array($extension, $allowedExtensions)) {
    die('File type not allowed');
}

// Serve the file
header('Content-Description: File Transfer');
header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="' . $requestedFile . '"');
header('Expires: 0');
header('Cache-Control: must-revalidate');
header('Pragma: public');
header('Content-Length: ' . filesize($filePath));
readfile($filePath);
exit;
