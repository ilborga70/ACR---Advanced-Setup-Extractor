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
    $vForm.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $vForm.ForeColor = [System.Drawing.Color]::FromArgb(241, 241, 241)
    
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Paste YouTube EMBED code (<iframe>) for:`nCar: $carName`nTrack: $trackName`n(Leave empty if no video)"
    $lbl.Location = "10,10"; $lbl.Size = "460,60"
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(241, 241, 241)
    $lbl.BackColor = [System.Drawing.Color]::Transparent
    $vForm.Controls.Add($lbl)
    
    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Location = "10,80"; $txt.Size = "460, 30"
    $txt.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
    $txt.ForeColor = [System.Drawing.Color]::FromArgb(241, 241, 241)
    $txt.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $vForm.Controls.Add($txt)
    
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "Confirm"
    $btnOk.Location = "150,130"
    $btnOk.Size = "100,30"
    $btnOk.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
    $btnOk.ForeColor = [System.Drawing.Color]::White
    $btnOk.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnOk.FlatAppearance.BorderSize = 0
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
    $selForm.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $selForm.ForeColor = [System.Drawing.Color]::FromArgb(241, 241, 241)
    
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Check the setups you want to export (select at least one):"
    $lbl.Location = "10,10"; $lbl.Size = "460,20"
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(241, 241, 241)
    $lbl.BackColor = [System.Drawing.Color]::Transparent
    $selForm.Controls.Add($lbl)
    
    $checkList = New-Object System.Windows.Forms.CheckedListBox
    $checkList.Location = "10,40"; $checkList.Size = "460, 270"
    $checkList.CheckOnClick = $true
    $checkList.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
    $checkList.ForeColor = [System.Drawing.Color]::FromArgb(241, 241, 241)
    $checkList.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    
    foreach ($s in $setups) {
        $display = "Car: $($s.Car) | Track: $($s.Track) | User: $($s.User)"
        $checkList.Items.Add($display) | Out-Null
    }
    $selForm.Controls.Add($checkList)
    
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "Confirm Selection"
    $btnOk.Location = "280,320"
    $btnOk.Size = "190,30"
    $btnOk.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
    $btnOk.ForeColor = [System.Drawing.Color]::White
    $btnOk.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnOk.FlatAppearance.BorderSize = 0
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
    
    # CSS / HTML Header (Dark Theme) - lascio intatto come prima
    $sb.AppendLine("<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'>") | Out-Null
    $sb.AppendLine("<meta name='viewport' content='width=device-width, initial-scale=1.0'>") | Out-Null
    $sb.AppendLine("<style>") | Out-Null
    $sb.AppendLine("* { margin: 0; padding: 0; box-sizing: border-box; }") | Out-Null
    $sb.AppendLine("body { font-family: 'Segoe UI', Tahoma, sans-serif; background: linear-gradient(135deg, #0f2027, #203a43, #2c5364); color: #e0e0e0; margin: 0; padding: 20px; min-height: 100vh; }") | Out-Null
    $sb.AppendLine(".container { max-width: 1200px; width: 100%; background: rgba(30, 30, 35, 0.95); padding: 30px; margin: 20px auto; border-radius: 12px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5); border: 1px solid #3a3a40; position: relative; overflow: hidden; }") | Out-Null
    $sb.AppendLine(".container::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #007acc, #00bcd4); }") | Out-Null
    $sb.AppendLine(".info-top { text-align: center; font-size: 15px; margin-bottom: 25px; color: #b0b0b0; border-bottom: 1px solid #3a3a40; padding-bottom: 15px; font-weight: 500; }") | Out-Null
    $sb.AppendLine(".info-top b { color: #00bcd4; font-weight: 600; }") | Out-Null
    $sb.AppendLine(".video-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; background: #000; margin-bottom: 30px; border-radius: 8px; border: 2px solid #3a3a40; }") | Out-Null
    $sb.AppendLine(".video-container iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }") | Out-Null
    $sb.AppendLine(".video-placeholder { width: 100%; padding: 50px 0; background: linear-gradient(135deg, #1a1a1f, #25252a); margin-bottom: 30px; display: flex; align-items: center; justify-content: center; color: #666; font-weight: 600; border-radius: 8px; text-transform: uppercase; letter-spacing: 2px; border: 2px dashed #3a3a40; font-size: 14px; }") | Out-Null
    $sb.AppendLine(".ai-buttons { text-align: center; margin: 30px 0; padding: 20px; border: 2px solid #3a3a40; border-radius: 12px; background: rgba(0, 188, 212, 0.05); }") | Out-Null
    $sb.AppendLine(".ai-button { background: #10a37f; color: white; padding: 12px 20px; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; margin: 5px; transition: 0.3s; }") | Out-Null
    $sb.AppendLine(".ai-button:hover { opacity: 0.9; }") | Out-Null
    $sb.AppendLine(".ai-button.gemini { background: #4285f4; }") | Out-Null
    $sb.AppendLine("h2 { color: #00bcd4; text-align: center; font-size: 18px; border-bottom: 2px solid #007acc; padding-bottom: 12px; margin: 40px 0 25px 0; text-transform: uppercase; letter-spacing: 1px; font-weight: 600; position: relative; }") | Out-Null
    $sb.AppendLine("h2::before { content: '■'; position: absolute; left: 0; color: #007acc; }") | Out-Null
    $sb.AppendLine("h2::after { content: '■'; position: absolute; right: 0; color: #007acc; }") | Out-Null
    $sb.AppendLine("table { width: 100%; border-collapse: separate; border-spacing: 0; margin-bottom: 30px; table-layout: fixed; border-radius: 8px; overflow: hidden; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3); }") | Out-Null
    $sb.AppendLine("th, td { border: 1px solid #3a3a40; padding: 14px 12px; text-align: center; font-size: 13px; word-wrap: break-word; transition: background 0.3s; }") | Out-Null
    $sb.AppendLine("th { background: linear-gradient(135deg, #2a2a30, #3a3a40); color: #00bcd4; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 2px solid #007acc; }") | Out-Null
    $sb.AppendLine("td { background: rgba(40, 40, 45, 0.8); color: #d0d0d0; }") | Out-Null
    $sb.AppendLine("tr:hover td { background: rgba(50, 50, 55, 0.9); }") | Out-Null
    $sb.AppendLine("td:first-child { text-align: left; background: rgba(35, 35, 40, 0.9); font-weight: 500; width: 30%; color: #b0b0b0; border-right: 2px solid #3a3a40; }") | Out-Null
    $sb.AppendLine(".highlight { color: #ff6b6b; font-weight: 600; background: rgba(255, 107, 107, 0.1); }") | Out-Null
    $sb.AppendLine(".footer-text { text-align: center; font-size: 11px; color: #777; margin-top: 40px; padding-top: 20px; border-top: 1px solid #3a3a40; font-style: italic; letter-spacing: 0.5px; }") | Out-Null
    $sb.AppendLine("@media (max-width: 768px) { .container { padding: 20px; margin: 10px; } th, td { padding: 10px 8px; font-size: 12px; } }") | Out-Null
    $sb.AppendLine("</style></head><body>") | Out-Null

    # Contatore per identificare ogni setup
    $setupIndex = 0
    
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
        
        $sb.AppendLine("<div class='container' id='setup-$setupIndex'>") | Out-Null
        $sb.AppendLine("<div class='info-top'><b>Driver:</b> $($setup.User) | <b>Car:</b> $($setup.Car) | <b>Track:</b> $($setup.Track)</div>") | Out-Null
        
        if ($videoCode) {
            $sb.AppendLine("<div class='video-container'>$videoCode</div>") | Out-Null
        } else {
            $sb.AppendLine("<div class='video-placeholder'>[ NO VIDEO AVAILABLE ]</div>") | Out-Null
        }

        # --- AI ANALYSIS BUTTONS FOR THIS SPECIFIC SETUP ---
        $sb.AppendLine("<div class='ai-buttons'>") | Out-Null
        $sb.AppendLine("<button class='ai-button' data-platform='chatgpt' data-setup-index='$setupIndex'>🚀 Analyze with ChatGPT</button>") | Out-Null
        $sb.AppendLine("<button class='ai-button gemini' data-platform='gemini' data-setup-index='$setupIndex'>✨ Analyze with Gemini</button>") | Out-Null
        $sb.AppendLine("</div>") | Out-Null

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
        
        $setupIndex++
    }

    # --- AGGIUNGIAMO LO JAVASCRIPT ALLA FINE ---
    $sb.AppendLine(@"
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Aggiungi event listener a tutti i pulsanti
    document.querySelectorAll('.ai-button').forEach(function(button) {
        button.addEventListener('click', function() {
            var platform = this.getAttribute('data-platform');
            var setupIndex = this.getAttribute('data-setup-index');
            
            // Salva il testo originale del pulsante
            var originalText = this.innerHTML;
            this.innerHTML = 'Preparazione...';
            this.disabled = true;
            
            // Trova il container del setup
            var container = document.getElementById('setup-' + setupIndex);
            if (!container) {
                alert('Errore: Setup non trovato!');
                this.innerHTML = originalText;
                this.disabled = false;
                return;
            }
            
            // Estrai i dati dalle tabelle del setup specifico
            var tables = container.querySelectorAll('table');
            var setupData = '';
            
            tables.forEach(function(table, index) {
                setupData += '\n--- TABELLA ' + (index + 1) + ' ---\n' + table.innerText + '\n';
            });
            
            // Estrai valori specifici
            var camberValue = 'Non trovato';
            var brakeBiasValue = 'Non trovato';
            
            // Cerca il valore del camber (case-insensitive)
            var camberRow = null;
            container.querySelectorAll('tr').forEach(function(row) {
                if (row.textContent.toLowerCase().includes('camber')) {
                    camberRow = row;
                }
            });
            
            if (camberRow) {
                var camberCell = camberRow.querySelector('td:nth-child(2)') || camberRow.querySelector('td');
                if (camberCell) camberValue = camberCell.textContent.trim();
            }
            
            // Cerca il valore del brake bias (case-insensitive)
            var brakeBiasRow = null;
            container.querySelectorAll('tr').forEach(function(row) {
                if (row.textContent.toLowerCase().includes('brake bias') || 
                    row.textContent.toLowerCase().includes('brake')) {
                    brakeBiasRow = row;
                }
            });
            
            if (brakeBiasRow) {
                var brakeBiasCell = brakeBiasRow.querySelector('td:nth-child(2)') || brakeBiasRow.querySelector('td');
                if (brakeBiasCell) brakeBiasValue = brakeBiasCell.textContent.trim();
            }
            
            var masterPrompt = 'Act as a Chief Engineer specialized in Rally WRC. \n' +
                             'Analyze this specific setup and propose modifications: \n\n' +
                             'EXTRACTED DATA:\n' + setupData + '\n\n' +
                             'SPECIFIC REQUEST:\n' +
                             '- Evaluate the balance between front and rear springs.\n' +
                             '- Comment on the Camber (' + camberValue + ') and Brake Bias (' + brakeBiasValue + ') relative to the track.\n' +
                             '- Suggest 3 concrete modifications to improve traction and corner rotation.\n' +
                             'Respond in a technical, brief and direct manner.';
            
            // Tenta di copiare negli appunti
            function copyToClipboard(text) {
                // Metodo 1: Usa l'API moderna se disponibile
                if (navigator.clipboard && window.isSecureContext) {
                    return navigator.clipboard.writeText(text)
                        .then(function() {
                            return true;
                        })
                        .catch(function() {
                            return false;
                        });
                }
                
                // Metodo 2: Fallback con textarea
                return new Promise(function(resolve) {
                    var textarea = document.createElement('textarea');
                    textarea.value = text;
                    textarea.style.position = 'fixed';
                    textarea.style.left = '-999999px';
                    textarea.style.top = '-999999px';
                    document.body.appendChild(textarea);
                    
                    try {
                        textarea.select();
                        textarea.setSelectionRange(0, 99999); // Per dispositivi mobili
                        
                        var success = document.execCommand('copy');
                        document.body.removeChild(textarea);
                        resolve(success);
                    } catch (err) {
                        document.body.removeChild(textarea);
                        resolve(false);
                    }
                });
            }
            
            // Gestisci la copia
            copyToClipboard(masterPrompt).then(function(success) {
                if (success) {
                    // URL delle piattaforme AI
                    var urls = {
                        'chatgpt': 'https://chat.openai.com/',
                        'gemini': 'https://gemini.google.com/app'
                    };
                    
                    // Chiedi all'utente cosa fare
                    var userChoice = confirm(
                        '✅ Prompt copiato negli appunti!\n\n' +
                        'Ora puoi:\n' +
                        '1. Cliccare OK per aprire ' + (platform === 'chatgpt' ? 'ChatGPT' : 'Gemini') + '\n' +
                        '2. Cliccare Annulla per copiare manualmente\n\n' +
                        'Dopo aver aperto la piattaforma, incolla (Ctrl+V / Cmd+V) il prompt.'
                    );
                    
                    if (userChoice && urls[platform]) {
                        // Apri in nuova finestra
                        window.open(urls[platform], '_blank', 'noopener,noreferrer');
                    } else if (!userChoice) {
                        // Mostra il prompt per copia manuale
                        var manualCopyDiv = document.createElement('div');
                        manualCopyDiv.innerHTML = 
                            '<div style="position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.8);z-index:9999;display:flex;align-items:center;justify-content:center;">' +
                            '<div style="background:white;padding:20px;border-radius:8px;max-width:90%;max-height:90%;overflow:auto;">' +
                            '<h3 style="margin-top:0;">📋 Copia manualmente il prompt</h3>' +
                            '<textarea id="manualPrompt" style="width:100%;height:300px;margin:10px 0;padding:10px;font-family:monospace;border:1px solid #ccc;border-radius:4px;">' + 
                            masterPrompt + 
                            '</textarea>' +
                            '<div style="display:flex;gap:10px;">' +
                            '<button onclick="document.getElementById(\'manualPrompt\').select();document.execCommand(\'copy\');alert(\'✅ Copiato!\');" style="padding:10px 20px;background:#007bff;color:white;border:none;border-radius:4px;cursor:pointer;">Seleziona & Copia</button>' +
                            '<button onclick="this.parentElement.parentElement.parentElement.remove();" style="padding:10px 20px;background:#6c757d;color:white;border:none;border-radius:4px;cursor:pointer;">Chiudi</button>' +
                            '</div>' +
                            '<p style="margin-top:15px;color:#666;font-size:14px;">Dopo aver copiato, apri manualmente: <strong>' + 
                            (platform === 'chatgpt' ? 'https://chat.openai.com/' : 'https://gemini.google.com/app') + 
                            '</strong></p>' +
                            '</div>' +
                            '</div>';
                        
                        document.body.appendChild(manualCopyDiv.firstElementChild);
                        
                        // Seleziona automaticamente il testo
                        setTimeout(function() {
                            var textarea = document.getElementById('manualPrompt');
                            if (textarea) {
                                textarea.select();
                            }
                        }, 100);
                    }
                    
                    // Ripristina il pulsante
                    button.innerHTML = '✅ Copiato!';
                    setTimeout(function() {
                        button.innerHTML = originalText;
                        button.disabled = false;
                    }, 2000);
                    
                    // Log in console per debug
                    console.log('Prompt copiato per ' + platform);
                    
                } else {
                    // Fallback se la copia non funziona
                    button.innerHTML = originalText;
                    button.disabled = false;
                    
                    // Mostra direttamente il prompt in un modal
                    var modalDiv = document.createElement('div');
                    modalDiv.innerHTML = 
                        '<div style="position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.8);z-index:9999;display:flex;align-items:center;justify-content:center;">' +
                        '<div style="background:white;padding:20px;border-radius:8px;max-width:90%;max-height:90%;overflow:auto;">' +
                        '<h3 style="margin-top:0;">📋 Prompt per ' + (platform === 'chatgpt' ? 'ChatGPT' : 'Gemini') + '</h3>' +
                        '<p style="color:#666;">Copia manualmente il testo qui sotto:</p>' +
                        '<textarea style="width:100%;height:300px;margin:10px 0;padding:10px;font-family:monospace;border:1px solid #ccc;border-radius:4px;">' + 
                        masterPrompt + 
                        '</textarea>' +
                        '<p style="color:#666;font-size:14px;">Dopo aver copiato, apri manualmente: <strong>' + 
                        (platform === 'chatgpt' ? 'https://chat.openai.com/' : 'https://gemini.google.com/app') + 
                        '</strong></p>' +
                        '<button onclick="this.parentElement.parentElement.remove();" style="padding:10px 20px;background:#007bff;color:white;border:none;border-radius:4px;cursor:pointer;">Chiudi</button>' +
                        '</div>' +
                        '</div>';
                    
                    document.body.appendChild(modalDiv.firstElementChild);
                }
            });
        });
    });
});
</script>
"@) | Out-Null

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
$form.Text = "ACR - Advanced Setup Extractor v1.6"
$form.Size = New-Object System.Drawing.Size(750, 650)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 35)
$form.ForeColor = [System.Drawing.Color]::FromArgb(241, 241, 241)

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

# Title with gradient effect simulation
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "ACR Setup Extractor - Multi-Setup - AI-Support"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.Size = New-Object System.Drawing.Size(700, 35)
$lblTitle.Location = New-Object System.Drawing.Point(20, 20)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 188, 212)
$lblTitle.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($lblTitle)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Automatically splits multiple setups found in a single save file"
$lblSub.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblSub.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$lblSub.Size = New-Object System.Drawing.Size(700, 20)
$lblSub.Location = New-Object System.Drawing.Point(20, 60)
$lblSub.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($lblSub)

# Buttons with modern flat design
$btnSel = New-Object System.Windows.Forms.Button
$btnSel.Text = "Select .sav File"
$btnSel.Location = New-Object System.Drawing.Point(20, 90)
$btnSel.Size = New-Object System.Drawing.Size(690, 40)
$btnSel.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
$btnSel.ForeColor = [System.Drawing.Color]::FromArgb(241, 241, 241)
$btnSel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnSel.FlatAppearance.BorderSize = 0
$btnSel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Controls.Add($btnSel)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "EXTRACT & SPLIT SETUPS"
$btnRun.Location = New-Object System.Drawing.Point(20, 140)
$btnRun.Size = New-Object System.Drawing.Size(690, 40)
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(28, 151, 234)
$btnRun.Enabled = $false
$btnRun.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnRun)

# Output textbox with dark theme
$txtOut = New-Object System.Windows.Forms.TextBox
$txtOut.Multiline = $true
$txtOut.ScrollBars = "Vertical"
$txtOut.Location = New-Object System.Drawing.Point(20, 195)
$txtOut.Size = New-Object System.Drawing.Size(690, 400)
$txtOut.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtOut.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 45)
$txtOut.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
$txtOut.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($txtOut)

# Status bar
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$statusBar.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$statusBar.Items.Add($statusLabel) | Out-Null
$form.Controls.Add($statusBar)

$script:selFile = $null
$script:results = $null

$btnSel.Add_Click({ 
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = "ACR Save|*.sav|All|*.*"
    $d.InitialDirectory = [Environment]::GetFolderPath("MyDocuments")
    if ($d.ShowDialog() -eq "OK") { 
        $script:selFile = $d.FileName
        $btnRun.Enabled = $true
        $txtOut.Text = "File selected: $(Split-Path $script:selFile -Leaf)`r`nReady to extract."
        $statusLabel.Text = "File loaded: $(Split-Path $script:selFile -Leaf)"
        $btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
    } 
})

$btnRun.Add_Click({
    $statusLabel.Text = "Extracting data..."
    $form.Refresh()
    
    $script:results = Analyze-Data $script:selFile $txtOut $null
    
    if ($script:results) {
        [array]$selectedSetups = Show-SetupSelectionDialog $script:results
        
        if ($selectedSetups -and $selectedSetups.Count -gt 0) {
            $d = New-Object System.Windows.Forms.SaveFileDialog
            $d.Filter = "Text File|*.txt"
            $d.FileName = "ACR_Export.txt"
            $d.InitialDirectory = [Environment]::GetFolderPath("MyDocuments")
            
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
                
                $statusLabel.Text = "Export completed successfully"
                [System.Windows.Forms.MessageBox]::Show("Export Complete!`nSaved: $basePath and $htmlPath", "Success", 
                    [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
        } else {
            $statusLabel.Text = "No setups selected"
            [System.Windows.Forms.MessageBox]::Show("No setup selected.", "Information", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    } else {
        $statusLabel.Text = "Extraction failed"
    }
})

$form.ShowDialog() | Out-Null
