try {
    $regValue = (get-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\DefaultSecurity").SrvsvcSessionInfo
    $testValue = 1,0,4,128,20,0,0,0,32,0,0,0,0,0,0,0,44,0,0,0,1,1,0,0,0,0,0,5,18,0,0,0,1,1,0,0,0,0,0,5,18,0,0,0,2,0,140,0,6,0,0,0,0,0,20,0,255,1,31,0,1,1,0,0,0,0,0,5,3,0,0,0,0,0,20,0,255,1,31,0,1,1,0,0,0,0,0,5,4,0,0,0,0,0,20,0,255,1,31,0,1,1,0,0,0,0,0,5,6,0,0,0,0,0,24,0,19,0,15,0,1,2,0,0,0,0,0,5,32,0,0,0,32,2,0,0,0,0,24,0,19,0,15,0,1,2,0,0,0,0,0,5,32,0,0,0,35,2,0,0,0,0,24,0,19,0,15,0,1,2,0,0,0,0,0,5,32,0,0,0,37,2,0,0
    [byte[]]$testValue = $testValue

    if (Compare-Object $testValue $regValue) {
        exit 1
    }
    else {
        exit 0
    }
}
catch {
    $errMsg = $_.Exception.Message
    return $errMsg
    exit 1
}