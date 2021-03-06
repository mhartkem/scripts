<#-----------------------------------------------------------------------------
Get-ComputerHealth
Ashley McGlone, Microsoft Premier Field Engineer
http://blogs.technet.com/b/ashleymcglone
April, 2012


This script takes a computername as a parameter and performs a
number of health checks.  Suggested usage is as follows:

PS C:\> .\Get-ComputerHealth.ps1 workstation1 > health.txt
PS C:\> .\health.txt

I intentionally didn't put many finishing touches on this script.  The intent
is that you will customize it for your environment and add the data points
relevant for you.


LEGAL DISCLAIMER
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.
-----------------------------------------------------------------------------#>

# Enforce the error trap by stopping on all errors
$ErrorActionPreference = "stop"

# Generic error logger
Trap {
    "-------------------------------------------------------------------------------"
    "Error."
    $Error
    "-------------------------------------------------------------------------------"
    $Error.Clear()
    Continue
}

# Reset the error array
$Error.Clear()

# Echo the suggested syntax if no parameters are specified
If ($Args[0]) {
    $PC = $Args[0]
} Else {
$msg = @"

This script takes a computername as a parameter and performs a
number of health checks.  Suggested usage is as follows:

PS C:\> .\Get-ComputerHealth.ps1 plum > health.txt
PS C:\> .\health.txt

"@
$msg
break
}

"-------------------------------------------------------------------------------"
"Checking client health for $PC"

"-------------------------------------------------------------------------------"
# Ping
Write-Progress -Activity "Ping" -Status $PC -PercentComplete (1/7*100)
# Tests connection and displays IP addresses
Test-Connection $PC | Format-Table -AutoSize

"-------------------------------------------------------------------------------"
# Local time on PC
Write-Progress -Activity "Time" -Status $PC -PercentComplete (2/7*100)
"Local time on $PC"
Get-WmiObject Win32_LocalTime |
 Format-Table Month, Day, Year, Hour, Minute, Second -AutoSize

"-------------------------------------------------------------------------------"
Write-Progress -Activity "C$ share" -Status $PC -PercentComplete (3/7*100)
"C$ share"
Get-WmiObject Win32_Share -Filter "Name='C$'" -ComputerName $PC |
 Format-Table __Server, Name, Path, Description -AutoSize
"UNC access to C$"
"----------------"
Test-Path "\\$PC\c`$\"

"-------------------------------------------------------------------------------"
Write-Progress -Activity "Perf stats" -Status $PC -PercentComplete (4/7*100)
"Disk, Memory, and CPU"
"---------------------"
# Free C: space in MB
$CFree   = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" -Property FreeSpace -ComputerName $PC |
 Select-Object @{name="CFreeMB";expression={$_.FreeSpace/1MB}} |
 Select-Object -ExpandProperty CFreeMB
If     ($CFree -gt 1000) { "C drive is OK at $($CFree)MB free" }
ElseIf ($CFree -lt 1000) { "C drive is low at $($CFree)MB free" }
ElseIf ($CFree -lt 100)  { "C drive is critically low at $($CFree)MB free" }

# Free memory in MB
$MemFree = Get-WmiObject Win32_PerfFormattedData_PerfOS_Memory -Property AvailableMBytes -ComputerName $PC |
 Select-Object -ExpandProperty AvailableMBytes
If     ($MemFree -gt 1000) { "Memory is OK at $($MemFree)MB" }
ElseIf ($MemFree -lt 1000) { "Memory is low at $($MemFree)MB" }
ElseIf ($MemFree -lt 100)  { "Memory is critically low at $($MemFree)MB" }

# CPU
$CPU = Get-WmiObject Win32_PerfFormattedData_PerfOS_Processor -Property Name, PercentProcessorTime -ComputerName $PC -Filter "Name='_Total'" |
 Select-Object -ExpandProperty PercentProcessorTime
If     ($CPU -gt 95) { "CPU is pegged at $CPU%" }
ElseIf ($CPU -gt 50) { "CPU is high at $CPU%" }
Else                 { "CPU is OK at $CPU%" }

Write-Progress -Activity "Event logs" -Status $PC -PercentComplete (5/7*100)
# Event log alerts
# We are using the cmdlet "Get-EventLog" to support older operating systems
$Logs  = "System", "Application"
$Types = "Error", "Warning"
ForEach ($Log in $Logs) {
    "-------------------------------------------------------------------------------"
    "$Log event log last ten alerts:"
    Get-EventLog -LogName $Log -Newest 10 -ComputerName $PC -EntryType $Types |
     Select-Object TimeGenerated, EntryType, Source, EventID, Message |
     Format-List *
}

"-------------------------------------------------------------------------------"
# Run the SYSTEMINFO utility
Write-Progress -Activity "SystemInfo" -Status $PC -PercentComplete (6/7*100)
SYSTEMINFO /S $PC

"-------------------------------------------------------------------------------"
