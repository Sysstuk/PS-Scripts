Connect-MgGraph -ClientId "7381ac60-3e83-468f-aab1-c6a84fdf3824" -TenantId "e10751b6-9dfc-4faf-b37d-aa5bdca24fcf" -CertificateThumbprint "01A604903BF689737B484624A4DC6E0F339FDF6C"

#user
$UserID = "denny.mansberger@springeq.com"

#export folder path
$filepath = "C:\Users\evan.fox\desktop\Denny Email Export\Succeeded\"

#failed item export path
$failedpath = "C:\Users\evan.fox\desktop\Denny Email Export\Failed\Failed.txt"

#import path of file with message ids
$path = "C:\Users\evan.fox\desktop\CompromisedEmailIds.txt"
$ids = Get-Content -Path $path

#finds each message by their id and exports it
foreach ($id in $ids){
    $message = Get-MgUserMessage -UserId "$UserID" -filter "InternetMessageID eq '$id'"
    $file = ($File = "$($message.subject) $($message.ReceivedDateTime).eml").Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    $outfile = $filepath + $file
    Write-Host $outfile
    try {
        Get-MgUserMessageContent -UserId $userid -MessageId $message.id -OutFile $outfile
    }
    Catch {
        Write-Host "Unable to export " $id
	$id | Out-File -FilePath $failedpath -append
    }
}
Read-Host "Press any button to close"
