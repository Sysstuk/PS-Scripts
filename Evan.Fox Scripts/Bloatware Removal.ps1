try {
    $packages = @("*3d*","*maps*","*mixedreality*","*phone*","*skype*","*solitaire*","*windowscommunicationsapps*","Microsoft.XboxIdentityProvider","Microsoft.BingTravel","Microsoft.BingHealthAndFitness","Microsoft.BingFoodAndDrink","Microsoft.XboxApp","Microsoft.BingSports","Microsoft.WindowsPhone","*zune*","*OutlookForWindows*","Microsoft.XboxGamingOverlay","Microsoft.XboxGameOverlay","Microsoft.XboxSpeechToTextOverlay","Microsoft.XboxTCUI")
    foreach ($package in $packages) {
        Get-AppxPackage $package | Remove-AppxPackage -ErrorAction stop 
        Write-Host "$package apps successfully removed"
    }
    Remove-WindowsCapability -online -name App.Support.QuickAssist~~~~0.0.1.0
}
catch { 
    Write-Error "Error removing Bloatware" 
}