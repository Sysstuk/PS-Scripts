Try{
    function Show-Menu
{
    param (
        [string]$Title = 'Select Distro Action'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to add users to a distro"
    Write-Host "2: Press '2' to remove users from a distro"
}

Connect-ExchangeOnline

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
$null = $FileBrowser.ShowDialog()

$path = $filebrowser.filename
$users = Get-Content -path $path
$distro = Read-Host "Enter the email of the distribution group"

if ((get-distributiongroup -identity $distro) -ne $null) {
    Show-Menu -Title "Select Distro Action"
    $selection = read-host "Please select an option"
    Switch ($selection)
    {
        '1' {
            'You chose to add users'
        } '2' {
            'You chose to remove users'
        } 'Q' {
            'Quit'
            return
        }
    }

    if ($selection -eq '1') {
        foreach ($user in $users) {
            Add-DistributionGroupMember -Identity $distro -Member $user -Confirm:$false
            Write-Host "$user added"
        }
    }
    elseif ($selection -eq '2') {
        foreach ($user in $users) {
            Remove-DistributionGroupMember -Identity $distro -Member $user -confirm:$false
            Write-Host "$user removed"
        }
    }
}

Read-host "Continue?" }
Catch {
    Write-Warning $Error
}