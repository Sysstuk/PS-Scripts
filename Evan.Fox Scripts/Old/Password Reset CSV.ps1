$cred = Get-Credential
$cred2 = Get-Credential

$today = Get-Date
$fileDate = Get-Date -format "MM-dd-yy"

[System.Collections.ArrayList]$table = @{}
$exportPath = "Q:\IT\Script Logs\Password Reset Logs\ResetList $fileDate.csv" 
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet -Credential $cred | where-object { $_.Enabled -eq "True" } | where-object { $_.PasswordNeverExpires -eq $false } | where-object { $_.passwordexpired -eq $false }

$table = foreach ($obj in $users) { 
    $expdate = ($obj.passwordlastset).AddDays(90)
    if ((($expDate - $today).Days) -le 14 -and (($expDate - $today).Days) -gt 0) {
        [pscustomobject]@{
            Username        = $($obj.name)
            FName           = $($obj.GivenName)
            Email           = $($obj.UserPrincipalName)
            'Expires In'    = ($expDate - $today).Days
            'Last Set'      = $obj.passwordlastset
            'Date Checked'  = (get-date -format MM/dd/yy)
            'Sent' = "F"
        }
    }
}

$table

Write-Host "####### Output #######" 

foreach ($obj in $table) {
    try { 
        $to = "$($obj.email)"
        $htmlbody = get-content -path 'Q:\IT\Evan Scripts\Password Reset\PassReset.htm' | out-string
        $subject = "[SEQ-IT]Password Expiring - Please Reset"
        $htmlbody = $htmlbody.replace("##FN##", $($obj.FName))
        $htmlbody = $htmlbody.replace("##days##", $($obj.'Expires In'))
            
        Send-MailMessage -credential $cred2 -From 'Help Desk <helpdesk@springeq.com>' -To $to -Subject $subject -BodyAsHtml -body $htmlbody -SmtpServer 'springeq-com.mail.protection.outlook.com' -UseSsl
        $obj.Sent = 'T'
        Write-Host "Email Sent To - $($obj.Username) - Expiration - $($obj.'Expires In') day(s)."
    }
    catch {
        Write-Host "Email Failed To - $($obj.Username)"
    }  
}

$table | Export-Csv -Path $exportPath 