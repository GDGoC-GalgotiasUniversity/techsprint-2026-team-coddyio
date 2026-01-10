# Run this as Administrator to add firewall rule for port 3000
# Right-click PowerShell and select "Run as Administrator"

Write-Host "Adding Windows Firewall rule for NodeMCU Server (port 3000)..." -ForegroundColor Yellow

# Add inbound rule for port 3000
New-NetFirewallRule -DisplayName "NodeMCU IoT Server" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 3000 `
    -Action Allow `
    -Profile Any `
    -Description "Allow NodeMCU to send sensor data to Node.js server"

Write-Host "✓ Firewall rule added successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Now check your NodeMCU Serial Monitor." -ForegroundColor Cyan
Write-Host "You should see: HTTP POST -> code: 201" -ForegroundColor Cyan
