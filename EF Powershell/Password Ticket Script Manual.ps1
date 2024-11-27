$cred = Get-Credential -Message "Enter your full LA creds for AD pull"
$cred2 = Get-Credential -Message "Enter email creds for sending email"

$today = Get-Date
$fileDate = Get-Date -format "MM-dd-yy"

$table = @{}

$exportPath = "Q:\IT\Script Logs\Password Ticket Logs\TicketList $fileDate.csv"
$users = get-aduser -filter * -properties Name, PasswordLastSet, UserPrincipalName, PasswordNeverExpires, PasswordExpired -Credential $cred | where-object { $_.Enabled -eq "True" } | where-object { $_.PasswordNeverExpires -eq $false } | where-object { $_.passwordexpired -eq $false }
$execUsers = (Get-ADGroupMember -Identity "Senior Leadership" -Credential $cred).DistinguishedName

$table = foreach ($obj in $users) {
    $expdate = ($obj.passwordlastset).AddDays(90)
    if (($execUsers -contains ($obj.DistinguishedName)) -and ((($expDate - $today).Days) -eq 14)) {
        [pscustomobject]@{
            Username        = $($obj.name)
            Email           = $($obj.UserPrincipalName)
            'Expiration Date' = ($obj.passwordlastset).AddDays(90)
            'Expires In'    = ($expDate - $today).Days
            'Last Set'      = $obj.passwordlastset
            'Date Checked'  = (get-date)
            'Ticket' = "F"
        }
    } elseif (($execUsers -notcontains ($obj.DistinguishedName)) -and ((($expDate - $today).Days) -eq 7)) {
        [pscustomobject]@{
            Username        = $($obj.name)
            Email           = $($obj.UserPrincipalName)
            'Expiration Date' = ($obj.passwordlastset).AddDays(90)
            'Expires In'    = ($expDate - $today).Days
            'Last Set'      = $obj.passwordlastset
            'Date Checked'  = (get-date)
            'Ticket' = "F"
        }
    } 
}    
$table

Write-Host "####### Output #######" 

foreach ($obj in $table) {
    try { 
        $subject = "Password Reset Needed - $($obj.Username)"

        $htmlbody = get-content -path 'Q:\IT\Evan Scripts\Password Ticket\PassTicket Email.txt' | out-string
        $htmlbody = $htmlbody.replace("##UPN##", $($obj.Email))
        $htmlbody = $htmlbody.replace("##ExpiryDate##", (($obj).'Expiration Date').GetDateTimeFormats()[94])
        $htmlbody = $htmlbody.replace("##FL##", $($obj.Username)) 
            
        Send-MailMessage -credential $cred2 -From 'Help Desk <helpdesk@springeq.com>' -To 'helpdesk@springeq.com' -Subject $subject -body $htmlbody -SmtpServer 'springeq-com.mail.protection.outlook.com' -UseSsl
        $obj.Ticket = 'T'
        Write-Host "Ticket created for $($obj.Username)"
    }
    catch {
        Write-Host "Email Failed For - $($obj.Username)"
    }  
}

$table | Export-Csv -Path $exportPath 
Read-Host "Continue?"