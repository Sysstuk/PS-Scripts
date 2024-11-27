Import-Module Microsoft.Graph.Users.Actions
Import-Module Microsoft.Graph.Mail
Connect-MgGraph
$userId = "helpdesk@springeq.com"

$today = Get-Date
$fileDate = Get-Date -format "MM-dd-yy"
[System.Collections.ArrayList]$table = @{}
$exportPath = "C:\Users\evan.fox\OneDrive - Spring EQ\PasswordReset\ResetList $fileDate.csv" 
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet | where-object { $_.Enabled -eq "True" } | where-object { $_.PasswordNeverExpires -eq $false } | where-object { $_.passwordexpired -eq $false }

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
        $htmlbody = get-content -path 'C:\Users\evan.fox\OneDrive - Spring EQ\PasswordReset\NewPassReset.htm' | out-string
        $subject = "[SEQ-IT]Password Expiring - Please Reset"
        $htmlbody = $htmlbody.replace("##FN##", $($obj.FName))
        $htmlbody = $htmlbody.replace("##days##", $($obj.'Expires In'))
            
        $params = @{
            Message = @{
                Body = @{
                    ContentType = "HTML"
                    Content = $htmlbody
                }
                Sender = "helpdesk@springeq.com"
                ToRecipients = @(
                    @{
                        EmailAddress = @{
                            Address = $to
                        }
                    }
                )
                Subject = $subject
            }
            SavetoSentItems = "False"
        }
        
        Send-MgUserMail -UserID $userID -BodyParameter $params
        $obj.Sent = 'T'
        Write-Host "Email Sent To - $($obj.Username) - Expiration - $($obj.'Expires In') day(s)."
    }
    catch {
        Write-Host "Email Failed To - $($obj.Username)"
    }  
}

$table | Export-Csv -Path $exportPath
