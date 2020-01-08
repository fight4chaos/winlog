@echo off
setlocal
set hour=%time:~0,2%
set minute=%time:~3,2%
set /A minute+=2
if %minute% GTR 59 (
 set /A minute-=60
 set /A hour+=1
)
if %hour%==24 set hour=00
if "%hour:~0,1%"==" " set hour=0%hour:~1,1%
if "%hour:~1,1%"=="" set hour=0%hour%
if "%minute:~1,1%"=="" set minute=0%minute%
set tasktime=%hour%:%minute%
mkdir C:\Applikationen\sysmon
pushd "C:\Applikationen\sysmon\"
echo [+] Downloading Sysmon...
@powershell (new-object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Sysmon64.exe','C:\Applikationen\sysmon\sysmon64.exe')"
echo [+] Downloading Sysmon config...
@powershell (new-object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/ion-storm/sysmon-config/develop/sysmonconfig-export.xml','C:\Applikationen\sysmon\sysmonconfig-export.xml')"
@powershell (new-object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/ion-storm/sysmon-config/develop/Auto_Update.bat','C:\Applikationen\sysmon\Auto_Update.bat')"
sysmon64.exe -accepteula -i sysmonconfig-export.xml
sc failure Sysmon64 actions= restart/10000/restart/10000// reset= 120
echo [+] Sysmon Successfully Installed!
echo [+] Creating Auto Update Task set to Hourly..
SchTasks /Create /RU SYSTEM /RL HIGHEST /SC HOURLY /TN Update_Sysmon_Rules /TR C:\Applikationen\sysmon\Auto_Update.bat /F /ST %tasktime%
timeout /t 10
echo [+] Finished Installing Sysmon
echo [+] Started Installing WinLogBeat
mkdir C:\Applikationen\WinLogBeat
pushd "C:\Applikationen\WinLogBeat\"
echo [+] Downloading WinLogBeat...
@powershell (new-object System.Net.WebClient).DownloadFile('https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.5.1-windows-x86_64.zip','C:\Applikationen\WinLogBeat\winlogbeat.zip')"
powershell.exe -nologo -noprofile -command "& { $shell = New-Object -COM Shell.Application; $target = $shell.NameSpace('C:\Applikationen\WinLogBeat'); $zip = $shell.NameSpace('C:\Applikationen\WinLogBeat\winlogbeat.zip'); $target.CopyHere($zip.Items(), 16); }"
echo [+] Downloading Winlogbeat config...
@powershell (new-object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/fight4chaos/winlog/master/winlogbeat.yml','C:\Applikationen\WinLogBeat\winlogbeat-7.5.1-windows-x86_64\winlogbeat.yml')"
Powershell.exe -executionpolicy Bypass -File  C:\Applikationen\WinLogBeat\winlogbeat-7.5.1-windows-x86_64\install-service-winlogbeat.ps1
pushd "C:\Applikationen\WinLogBeat\winlogbeat-7.5.1-windows-x86_64\"
echo [+] WinLogBeat Successfully Installed!
net start winlogbeat
echo [+] WinLogBeat Successfully Started!
exit
