# ACR - Advanced Setup Extractor (Multi-Setup Splitter) - English Version
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CORE FUNCTIONS ---

function Show-VideoInputDialog($carName, $trackName) {
    $vForm = New-Object System.Windows.Forms.Form
    $vForm.Text = "Add Video"
    $vForm.Size = New-Object System.Drawing.Size(500, 250)
    $vForm.StartPosition = "CenterScreen"
    $vForm.TopMost = $true
    
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Paste YouTube EMBED code (<iframe>) for:`nCar: $carName`nTrack: $trackName`n(Leave empty if no video)"
    $lbl.Location = "10,10"; $lbl.Size = "460,60"
    $vForm.Controls.Add($lbl)
    
    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Location = "10,80"; $txt.Size = "460, 30"
    $vForm.Controls.Add($txt)
    
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "Confirm"; $btnOk.Location = "150,130"; $btnOk.Size = "100,30"
    $btnOk.Add_Click({ $vForm.DialogResult = [System.Windows.Forms.DialogResult]::OK; $vForm.Close() })
    $vForm.Controls.Add($btnOk)
    
    $vForm.ShowDialog() | Out-Null
    
    if ($txt.Text.Trim().Length -gt 0) {
        return $txt.Text
    }
    return $null
}

function Show-SetupSelectionDialog($setups) {
    $selForm = New-Object System.Windows.Forms.Form
    $selForm.Text = "Select Setups to Export"
    $selForm.Size = New-Object System.Drawing.Size(500, 400)
    $selForm.StartPosition = "CenterScreen"
    $selForm.TopMost = $true
    
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Check the setups you want to export (select at least one):"
    $lbl.Location = "10,10"; $lbl.Size = "460,20"
    $selForm.Controls.Add($lbl)
    
    $checkList = New-Object System.Windows.Forms.CheckedListBox
    $checkList.Location = "10,40"; $checkList.Size = "460, 270"
    $checkList.CheckOnClick = $true
    
    foreach ($s in $setups) {
        $display = "Car: $($s.Car) | Track: $($s.Track) | User: $($s.User)"
        $checkList.Items.Add($display) | Out-Null
    }
    $selForm.Controls.Add($checkList)
    
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "Confirm Selection"; $btnOk.Location = "280,320"; $btnOk.Size = "190,30"
    $btnOk.Add_Click({ $selForm.DialogResult = [System.Windows.Forms.DialogResult]::OK; $selForm.Close() })
    $selForm.Controls.Add($btnOk)
    
    $result = $selForm.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedSetups = @()
        foreach ($idx in $checkList.CheckedIndices) {
            $selectedSetups += $setups[$idx]
        }
        return ,$selectedSetups
    }
    return $null
}

function Export-SetupsToHtml($setups, $filePath) {
    $sb = [System.Text.StringBuilder]::New()
    
    # CSS / HTML Header (English)
    $sb.AppendLine("<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'>") | Out-Null
    $sb.AppendLine("<style>") | Out-Null
    $sb.AppendLine("body { font-family: 'Segoe UI', Tahoma, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; display: flex; flex-direction: column; align-items: center; }") | Out-Null
    $sb.AppendLine(".container { max-width: 950px; width: 100%; background: #fff; padding: 40px; box-sizing: border-box; box-shadow: 0 4px 15px rgba(0,0,0,0.1); margin-bottom: 40px; border-radius: 8px; }") | Out-Null
    $sb.AppendLine(".info-top { text-align: center; font-size: 14px; margin-bottom: 20px; color: #333; border-bottom: 1px solid #eee; padding-bottom: 10px; }") | Out-Null
    $sb.AppendLine(".info-top b { color: #d32f2f; }") | Out-Null
    # CSS Responsive Video
    $sb.AppendLine(".video-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; background: #000; margin-bottom: 30px; border-radius: 4px; }") | Out-Null
    $sb.AppendLine(".video-container iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }") | Out-Null
    $sb.AppendLine(".video-placeholder { width: 100%; padding: 40px 0; background: #222; margin-bottom: 30px; display: flex; align-items: center; justify-content: center; color: #777; font-weight: bold; border-radius: 4px; text-transform: uppercase; letter-spacing: 1px; }") | Out-Null
    
    $sb.AppendLine("h2 { color: #1976d2; text-align: center; font-size: 16px; border-bottom: 2px solid #1976d2; padding-bottom: 8px; margin: 40px 0 20px 0; text-transform: uppercase; }") | Out-Null
    $sb.AppendLine("table { width: 100%; border-collapse: collapse; margin-bottom: 20px; table-layout: fixed; }") | Out-Null
    $sb.AppendLine("th, td { border: 1px solid #ccc; padding: 10px; text-align: center; font-size: 12px; word-wrap: break-word; }") | Out-Null
    $sb.AppendLine("th { background-color: #fcfcfc; color: #666; font-weight: bold; text-transform: uppercase; }") | Out-Null
    $sb.AppendLine("td:first-child { text-align: left; background-color: #fcfcfc; font-weight: 500; width: 30%; }") | Out-Null
    $sb.AppendLine(".highlight { color: #d32f2f; font-weight: bold; }") | Out-Null
    $sb.AppendLine(".footer-text { text-align: center; font-size: 10px; color: #999; margin-top: 50px; font-style: italic; }") | Out-Null
    $sb.AppendLine("</style></head><body>") | Out-Null

    foreach ($setup in $setups) {
        # Value extraction helper
        $getVal = { 
            param($pattern) 
            $line = $setup.Properties | Where-Object { $_ -match $pattern } | Select-Object -First 1
            if ($line -match ":") { return $line.Split(':', 2)[1].Trim() }
            $idx = [array]::IndexOf($setup.Properties, $line)
            if ($idx -ge 0 -and $idx -lt ($setup.Properties.Count - 1)) { return $setup.Properties[$idx+1].Trim() }
            return "N/A"
        }

        # --- ASK FOR VIDEO CODE ---
        $videoCode = Show-VideoInputDialog $setup.Car $setup.Track
        
        $sb.AppendLine("<div class='container'>") | Out-Null
        $sb.AppendLine("<div class='info-top'><b>Driver:</b> $($setup.User) | <b>Car:</b> $($setup.Car) | <b>Track:</b> $($setup.Track)</div>") | Out-Null
        
        if ($videoCode) {
            $sb.AppendLine("<div class='video-container'>$videoCode</div>") | Out-Null
        } else {
            $sb.AppendLine("<div class='video-placeholder'>[ NO VIDEO AVAILABLE ]</div>") | Out-Null
        }

        # --- SECTION 1: CHASSIS ---
        $sb.AppendLine("<h2>1. CHASSIS & SUSPENSIONS</h2>") | Out-Null
        $sb.AppendLine("<table><thead><tr><th>Parameter</th><th>Front (FL/FR)</th><th>Rear (RL/RR)</th></tr></thead><tbody>") | Out-Null
        $sb.AppendLine("<tr><td>Tyre Pressure</td><td>$(& $getVal 'FrontLeft.TyrePressure') PSI</td><td>$(& $getVal 'RearLeft.TyrePressure') PSI</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Camber Angle</td><td>$(& $getVal 'FrontLeft.Camber')°</td><td>$(& $getVal 'RearLeft.Camber')°</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Toe Angle</td><td>$(& $getVal 'FrontLeft.Toe')</td><td>$(& $getVal 'RearLeft.Toe')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Spring Stiffness</td><td>$(& $getVal 'FrontLeft.SpringStiffness') N/m</td><td>$(& $getVal 'RearLeft.SpringStiffness') N/m</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Ride Height (Adjuster Ring)</td><td>$(& $getVal 'FrontLeft.AdjusterRing') m</td><td>$(& $getVal 'RearLeft.AdjusterRing') m</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Anti-Roll Bar (ARB)</td><td>$(& $getVal 'Axles.Front.ARB')</td><td>$(& $getVal 'Axles.Rear.ARB')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Slow Bump</td><td>$(& $getVal 'FrontLeft.SlowBump')</td><td>$(& $getVal 'RearLeft.SlowBump')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Slow Rebound</td><td>$(& $getVal 'FrontLeft.SlowRebound')</td><td>$(& $getVal 'RearLeft.SlowRebound')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Fast Bump</td><td>$(& $getVal 'FrontLeft.FastBump')</td><td>$(& $getVal 'RearLeft.FastBump')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Fast Rebound</td><td>$(& $getVal 'FrontLeft.FastRebound')</td><td>$(& $getVal 'RearLeft.FastRebound')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Bump/Rebound Transition</td><td>$(& $getVal 'FrontLeft.BumpTransition') / $(& $getVal 'FrontLeft.ReboundTransition')</td><td>$(& $getVal 'RearLeft.BumpTransition') / $(& $getVal 'RearLeft.ReboundTransition')</td></tr>") | Out-Null
        $sb.AppendLine("</tbody></table>") | Out-Null

        # --- SECTION 2: DRIVETRAIN ---
        $sb.AppendLine("<h2>2. DRIVETRAIN & ELECTRONICS</h2>") | Out-Null
        $sb.AppendLine("<table><thead><tr><th>System</th><th>Component / Parameter</th><th>Value / Spec</th></tr></thead><tbody>") | Out-Null
        $sb.AppendLine("<tr><td>Gearbox</td><td>Gear Set</td><td>$(& $getVal 'GearsSet')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Center Differential</td><td>Ratio</td><td>$(& $getVal 'CentreDifferentialRatio') - $(& $getVal 'CentreRatioToRear')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Front Differential</td><td>Ramps / Preload</td><td>$(& $getVal 'Front.LSDRamps') - Preload: $(& $getVal 'Front.LSDPreload')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Rear Differential</td><td>Ramps / Preload</td><td>$(& $getVal 'Rear.LSDRamps') - Preload: $(& $getVal 'Rear.LSDPreload')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Rear Differential</td><td>Final Ratio</td><td>$(& $getVal 'Rear.DifferentialRatio')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Electronics</td><td class='highlight'>ABS (Anti-lock Braking)</td><td class='highlight'>$(& $getVal 'False' | ForEach-Object { if ($_ -eq 'False' -or $_ -eq 'N/A') { 'OFF' } else { $_ } })</td></tr>") | Out-Null
$sb.AppendLine("<tr><td>Electronics</td><td class='highlight'>TCS (Traction Control)</td><td class='highlight'>$(& $getVal 'False' | ForEach-Object { if ($_ -eq 'False' -or $_ -eq 'N/A') { 'OFF' } else { $_ } })</td></tr>") | Out-Null
        $sb.AppendLine("</tbody></table>") | Out-Null

        # --- SECTION 3: BRAKES ---
        $sb.AppendLine("<h2>3. BRAKING SYSTEM</h2>") | Out-Null
        $sb.AppendLine("<table><thead><tr><th>Component</th><th>Front</th><th>Rear</th></tr></thead><tbody>") | Out-Null
        $sb.AppendLine("<tr><td>Disc</td><td>$(& $getVal 'FrontLeft.Disc')</td><td>$(& $getVal 'RearLeft.Disc')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Caliper</td><td>$(& $getVal 'FrontLeft.Caliper')</td><td>$(& $getVal 'RearLeft.Caliper')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Pads</td><td>$(& $getVal 'FrontLeft.PadCompound')</td><td>$(& $getVal 'RearLeft.PadCompound')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Master Cylinder</td><td>$(& $getVal 'MasterCylinderFront')</td><td>$(& $getVal 'MasterCylinderRear')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Brake Bias</td><td colspan='2'>$(& $getVal 'FrontBias')</td></tr>") | Out-Null
        $sb.AppendLine("<tr><td>Handbrake</td><td colspan='2'>Force: $(& $getVal 'HandbrakeForce')</td></tr>") | Out-Null
        $sb.AppendLine("</tbody></table>") | Out-Null

        $sb.AppendLine("<div class='footer-text'>Report generated based on official technical data from driver $($setup.User) - Assetto Corsa Rally</div>") | Out-Null
        $sb.AppendLine("</div>") | Out-Null
    }

    $sb.AppendLine("</body></html>") | Out-Null
    [System.IO.File]::WriteAllText($filePath, $sb.ToString())
}

function Get-AllStringsFromFile($filePath, $textBoxOutput, $labelProgress) {
    $stringsFound = @()
    
    try {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $len = $bytes.Length
        $minStrLen = 2 
        $maxStrLen = 200
        
        Update-Output "Scanning $len bytes for text data..." $textBoxOutput $labelProgress
        
        for ($i = 0; $i -lt $len - 4; $i++) {
            $strLen = [System.BitConverter]::ToInt32($bytes, $i)
            
            if ($strLen -gt $minStrLen -and $strLen -lt $maxStrLen) {
                if ($i + 4 + $strLen -gt $len) { continue }
                $candidateBytes = $bytes[($i + 4)..($i + 4 + $strLen - 2)]
                $isValid = $true
                foreach ($b in $candidateBytes) {
                    if ($b -lt 32 -or $b -gt 126) { $isValid = $false; break }
                }
                if ($isValid) {
                    $strVal = [System.Text.Encoding]::UTF8.GetString($candidateBytes)
                    if ($strVal.Trim().Length -gt 0) {
                        $stringsFound += [PSCustomObject]@{ Offset = $i; Value = $strVal }
                        $i += 4 + $strLen - 1
                        continue
                    }
                }
            }
            if ($strLen -lt (-$minStrLen) -and $strLen -gt (-$maxStrLen)) {
                $uLen = [Math]::Abs($strLen)
                if ($i + 4 + ($uLen * 2) -gt $len) { continue }
                $candidateBytes = $bytes[($i + 4)..($i + 4 + ($uLen * 2) - 1)]
                try {
                    $strVal = [System.Text.Encoding]::Unicode.GetString($candidateBytes).TrimEnd([char]0)
                    if ($strVal.Trim().Length -gt 0) {
                        $stringsFound += [PSCustomObject]@{ Offset = $i; Value = $strVal }
                        $i += 4 + ($uLen * 2) - 1
                    }
                } catch {}
            }
        }
    } catch {
        Update-Output "ERROR: $($_.Exception.Message)" $textBoxOutput $labelProgress
    }
    return $stringsFound
}

function Update-Output {
    param([string]$Message, [System.Windows.Forms.TextBox]$textBox, [System.Windows.Forms.Label]$labelProgress)
    $action = {
        $textBox.AppendText("$Message`r`n")
        $textBox.SelectionStart = $textBox.Text.Length
        $textBox.ScrollToCaret()
        $textBox.Refresh()
    }
    if ($textBox.InvokeRequired) { $textBox.Invoke($action) } else { & $action }
}

function Analyze-Data($filePath, $textBoxOutput, $labelProgress) {
    $textBoxOutput.Text = ""
    Update-Output "Starting DEEP SCAN on: $(Split-Path $filePath -Leaf)" $textBoxOutput $labelProgress
    
    $allStrings = Get-AllStringsFromFile $filePath $textBoxOutput $labelProgress
    
    if ($allStrings.Count -eq 0) {
        Update-Output "❌ No text strings found." $textBoxOutput $labelProgress
        return $null
    }
    
    Update-Output "✅ Found $($allStrings.Count) strings. Analyzing structure..." $textBoxOutput $labelProgress
    
    $versionIndices = @()
    $verRegex = "^\d+\.\d+\.\d+\.\d+$"
    
    for ($i = 0; $i -lt $allStrings.Count; $i++) {
        if ($allStrings[$i].Value -match $verRegex) {
            $versionIndices += $i
        }
    }
    
    if ($versionIndices.Count -eq 0) {
        Update-Output "⚠️ No version markers found. Dumping everything as one block." $textBoxOutput $labelProgress
        return @(@{ Car="Unknown"; User="Unknown"; Track="Unknown"; Properties=$allStrings.Value })
    }
    
    Update-Output "🔍 Detected $($versionIndices.Count) distinct setups inside the file." $textBoxOutput $labelProgress
    
    $extractedSetups = @()
    
    for ($k = 0; $k -lt $versionIndices.Count; $k++) {
        $vIdx = $versionIndices[$k]
        $car = "Unknown"; $user = "Unknown"; $track = "Unknown"
        
        if ($vIdx -ge 2) { $car = $allStrings[$vIdx - 2].Value }
        if ($vIdx -ge 1) { $user = $allStrings[$vIdx - 1].Value }
        if ($vIdx + 2 -lt $allStrings.Count) { $track = $allStrings[$vIdx + 2].Value }
        
        Update-Output "  -> Setup #$($k+1): $car | User: $user | Track: $track" $textBoxOutput $labelProgress
        
        $startPropIdx = $vIdx + 3
        if ($k -lt $versionIndices.Count - 1) {
            $nextVIdx = $versionIndices[$k+1]
            $endPropIdx = $nextVIdx - 3
        } else {
            $endPropIdx = $allStrings.Count - 1
        }
        
        $props = @()
        if ($startPropIdx -le $endPropIdx) {
            for ($j = $startPropIdx; $j -le $endPropIdx; $j++) {
                $props += $allStrings[$j].Value
            }
        }
        
        $extractedSetups += [PSCustomObject]@{
            Car = $car
            User = $user
            Track = $track
            Properties = $props
        }
    }
    return $extractedSetups
}

# --- GUI ---

$form = New-Object System.Windows.Forms.Form
$form.Text = "ACR - Advanced Setup Extractor (Splitter)"
$form.Size = New-Object System.Drawing.Size(750, 650)
$form.StartPosition = "CenterScreen"

try {
    $iconBase64 = "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" 

    if (-not [string]::IsNullOrEmpty($iconBase64)) {
        $iconBytes = [System.Convert]::FromBase64String($iconBase64)
        $iconStream = New-Object System.IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
        $form.Icon = New-Object System.Drawing.Icon($iconStream)
    }
}
catch {
    Write-Host "Icon load warning: $($_.Exception.Message)" -ForegroundColor Yellow
}

$lblTitle = New-Object System.Windows.Forms.Label; $lblTitle.Text = "ACR Setup Extractor - Multi-Setup Support"; $lblTitle.Font = "Arial,14,style=Bold"; $lblTitle.Size = "700,30"; $lblTitle.Location = "20,20"; $form.Controls.Add($lblTitle)
$lblSub = New-Object System.Windows.Forms.Label; $lblSub.Text = "Automatically splits multiple setups found in a single save file"; $lblSub.ForeColor = "DarkBlue"; $lblSub.Size = "700,20"; $lblSub.Location = "20,50"; $form.Controls.Add($lblSub)

$btnSel = New-Object System.Windows.Forms.Button; $btnSel.Text = "Select .sav File"; $btnSel.Location = "20,80"; $btnSel.Size = "690,40"; $form.Controls.Add($btnSel)
$btnRun = New-Object System.Windows.Forms.Button; $btnRun.Text = "EXTRACT & SPLIT SETUPS"; $btnRun.Location = "20,130"; $btnRun.Size = "690,40"; $btnRun.Enabled = $false; $form.Controls.Add($btnRun)

$txtOut = New-Object System.Windows.Forms.TextBox; $txtOut.Multiline = $true; $txtOut.ScrollBars = "Vertical"; $txtOut.Location = "20,190"; $txtOut.Size = "690,400"; $txtOut.Font = "Consolas,9"; $form.Controls.Add($txtOut)

$script:selFile = $null
$script:results = $null

$btnSel.Add_Click({ 
    $d = New-Object System.Windows.Forms.OpenFileDialog; $d.Filter = "ACR Save|*.sav|All|*.*"
    if ($d.ShowDialog() -eq "OK") { 
        $script:selFile = $d.FileName
        $btnRun.Enabled = $true
        $txtOut.Text = "File selected: $(Split-Path $script:selFile -Leaf)`r`nReady to extract."
    } 
})

$btnRun.Add_Click({
    $script:results = Analyze-Data $script:selFile $txtOut $null
    
    if ($script:results) {
        [array]$selectedSetups = Show-SetupSelectionDialog $script:results
        
        if ($selectedSetups -and $selectedSetups.Count -gt 0) {
            $d = New-Object System.Windows.Forms.SaveFileDialog
            $d.Filter = "Text File|*.txt"
            $d.FileName = "ACR_Export.txt"
            
            if ($d.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $basePath = $d.FileName
                $htmlPath = $basePath -replace "\.txt$", ".html"
                
                $sb = [System.Text.StringBuilder]::New()
                $sb.AppendLine("ACR EXTRACTED SETUPS REPORT") | Out-Null
                $sb.AppendLine("Total Selected: $($selectedSetups.Count)") | Out-Null
                
                $counter = 1
                foreach ($setup in $selectedSetups) {
                    $sb.AppendLine("--------------------------------------------------") | Out-Null
                    $sb.AppendLine("SETUP #$counter - $($setup.Car)") | Out-Null
                    foreach ($prop in $setup.Properties) { $sb.AppendLine("  $prop") | Out-Null }
                    $counter++
                }
                [System.IO.File]::WriteAllText($basePath, $sb.ToString())
                
                Export-SetupsToHtml $selectedSetups $htmlPath
                
                [System.Windows.Forms.MessageBox]::Show("Export Complete!`nSaved: $basePath and $htmlPath")
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("No setup selected.")
        }
    }
})

$form.ShowDialog() | Out-Null
