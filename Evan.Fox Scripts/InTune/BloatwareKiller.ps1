$packages = @("*3d*","*maps*","*mixedreality*","*phone*","*skype*","*solitaire*","*windowscommunicationsapps*",
"Microsoft.XboxIdentityProvider","Microsoft.BingTravel","Microsoft.BingHealthAndFitness","Microsoft.BingFoodAndDrink",
"Microsoft.XboxApp","Microsoft.BingSports","Microsoft.WindowsPhone","*zune*","*OutlookForWindows*")

foreach ($package in $packages) {
    if ($null -ne (get-appxpackage $package)) {
        write-host "Bloatware Detected"
        exit 1
    } else 
        {write-host "Bloatware $pkg NOT Detected"}
}
exit 0




try {
    $packages = @("*3d*","*maps*","*mixedreality*","*phone*","*skype*","*solitaire*","*windowscommunicationsapps*",
    "Microsoft.XboxIdentityProvider","Microsoft.BingTravel","Microsoft.BingHealthAndFitness","Microsoft.BingFoodAndDrink",
    "Microsoft.XboxApp","Microsoft.BingSports","Microsoft.WindowsPhone","*zune*","*OutlookForWindows*")
    foreach ($package in $packages) {
        Get-AppxPackage $package | Remove-AppxPackage -ErrorAction stop 
        Write-Host "$package apps successfully removed"
    }
}
catch { 
    Write-Error "Error removing Microsoft Solitaire app" 
}

