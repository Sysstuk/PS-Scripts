$packages = @("*3d*","*maps*","*mixedreality*","*phone*","*skype*","*solitaire*","*windowscommunicationsapps*",
"Microsoft.XboxIdentityProvider","Microsoft.BingTravel","Microsoft.BingHealthAndFitness","Microsoft.BingFoodAndDrink",
"Microsoft.XboxApp","Microsoft.BingSports","Microsoft.WindowsPhone","*zune*","*OutlookForWindows*","Microsoft.XboxGamingOverlay","Microsoft.XboxGameOverlay","Microsoft.XboxSpeechToTextOverlay","Microsoft.XboxTCUI","MicrosoftCorporationII.QuickAssist","Microsoft.GamingApp")

foreach ($package in $packages) {
    if ($null -ne (get-appxpackage $package)) {
        write-host "$package Detected"
        exit 1
    } else 
        {write-host "Bloatware $package NOT Detected"}
}
exit 0