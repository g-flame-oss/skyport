<?php
// list-files.php - Lists available files in the downloads directory

// Configuration
$downloadDirectory = '/var/www/html/downloads/';
$allowedExtensions = ['pdf', 'zip', 'doc', 'docx', 'jpg', 'png', 'txt'];

// Security check - prevent directory traversal
if (!is_dir($downloadDirectory)) {
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Download directory not found']);
    exit;
}

// Get files from directory
$files = [];
$dirHandle = opendir($downloadDirectory);

if ($dirHandle) {
    while (($file = readdir($dirHandle)) !== false) {
        // Skip directories and hidden files
        if ($file == '.' || $file == '..' || is_dir($downloadDirectory . $file) || substr($file, 0, 1) === '.') {
            continue;
        }
        
        // Check file extension
        $extension = strtolower(pathinfo($file, PATHINFO_EXTENSION));
        if (!in_array($extension, $allowedExtensions)) {
            continue;
        }
        
        // Add file to the list with additional info
        $filePath = $downloadDirectory . $file;
        $files[] = [
            'name' => $file,
            'size' => filesize($filePath),
            'modified' => filemtime($filePath)
        ];
    }
    closedir($dirHandle);
}

// Return JSON response
header('Content-Type: application/json');
echo json_encode($files);
