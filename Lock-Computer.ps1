$computerName = "localhost"
$command = "rundll32.exe user32.dll, LockWorkStation"

Invoke-Command -ComputerName $computerName -ScriptBlock {$command}