$identity = (Read-Host -Prompt "Enter an Identity (username) to unlock")

#Unlock-ADAccount -Identity $identity

Write-Host $identity "unlocked."

Write-Host "Press any key to continue..."
[void][System.Console]::ReadKey($true)


$identity = (Read-Host -Prompt "Enter an Identity (username) to reset")
$newPassword = "Trihealth1"

#Set-ADAccountPassword -Identity $identity -NewPassword $newPassword -Reset

Write-Host $identity "password set to:" $newPassword

Write-Host "Press any key to continue..."
[void][System.Console]::ReadKey($true)