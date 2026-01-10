#!/usr/bin/env powershell
# Verify that all components are properly installed and configured

Write-Host "Verifying Setup..." -ForegroundColor Cyan
Write-Host ""

# Check Git
Write-Host "1. Checking Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "OK Git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "FAIL Git not found" -ForegroundColor Red
}

# Check Python
Write-Host ""
Write-Host "2. Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version
    Write-Host "OK Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "FAIL Python not found" -ForegroundColor Red
}

# Check Node.js
Write-Host ""
Write-Host "3. Checking Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "OK Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "FAIL Node.js not found" -ForegroundColor Red
}

# Check Plant Disease Model
Write-Host ""
Write-Host "4. Checking Plant Disease Model..." -ForegroundColor Yellow
$modelPath = "./plant-disease-model/plant_disease_model_1_latest.pt"
if (Test-Path $modelPath) {
    $modelSize = (Get-Item $modelPath).Length / 1MB
    Write-Host "OK Model found: $([math]::Round($modelSize, 2)) MB" -ForegroundColor Green
} else {
    Write-Host "FAIL Model not found" -ForegroundColor Red
}

# Check Python packages
Write-Host ""
Write-Host "5. Checking Python Packages..." -ForegroundColor Yellow
$packages = @("torch", "torchvision", "pillow", "numpy")
foreach ($package in $packages) {
    try {
        python -c "import $package" 2>$null
        Write-Host "OK $package installed" -ForegroundColor Green
    } catch {
        Write-Host "FAIL $package not installed" -ForegroundColor Red
    }
}

# Check Node.js packages
Write-Host ""
Write-Host "6. Checking Node.js Packages..." -ForegroundColor Yellow
if (Test-Path "./server/node_modules") {
    Write-Host "OK Node modules installed" -ForegroundColor Green
} else {
    Write-Host "WARN Node modules not installed" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "Setup Verification Complete" -ForegroundColor Green
Write-Host ""
