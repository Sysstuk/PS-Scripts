Connect-ExchangeOnline
$filepath = "C:\Users\evan.fox\Desktop\audittest.csv"

$records = Search-MailboxAuditLog -StartDate 07/31/2024 -EndDate 08/02/2024 -Identity denny.mansberger@springeq.com -Operations MailItemsAccessed -ResultSize 40000 -ShowDetails | Where {$_.OperationProperties -like "*MailAccessType:Bind*"} | select aggregatedrecordfoldersdata,lastaccessed,clientip,clientinfostring,appid,clientappid

foreach($record in $records){
    $record.aggregatedrecordfoldersdata -match '"<([a-zA-z0-9@\.]+)>"'
    $object = [PSCustomObject]@{
        AppID = $record.appid
        ClientAppID = $record.clientappid
        Client = $record.clientinfostring
        ClientIP = $record.clientip
        LastAccessed = $record.lastaccessed
        EmailID = $matches.1
    }
    $object | Export-CSV -path $filepath -append
}