@echo off
reg delete HKLM\SOFTWARE\Policies\Bradford Networks\Persistent Agent /v allowedServers
reg delete HKLM\SOFTWARE\Policies\Bradford Networks\Persistent Agent /v ClientStateEnabled
reg delete HKLM\SOFTWARE\Policies\Bradford Networks\Persistent Agent /v homeServer
reg delete HKLM\SOFTWARE\Policies\Bradford Networks\Persistent Agent /v LoginDialogDisabled
reg delete HKLM\SOFTWARE\Policies\Bradford Networks\Persistent Agent /v restrictRoaming
reg delete HKLM\SOFTWARE\Policies\Bradford Networks\Persistent Agent /v ShowIcon