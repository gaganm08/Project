Cls
$Text = Read-host "Please Enter the String in this format 'FirstName LastName (FNLastName@arv.org.au);..." `n
$Array = [Regex]::Matches($Text, '(?<=\()(.*?)(?=@)') | Select -ExpandProperty Value 
$Output = $Array | ForEach-Object {Get-ADUser -Identity $_ | select SamAccountName,Name,Enabled}
$Output
$Flag = 1
while ($Flag)
{
write-host -ForegroundColor Green "+++++++++++++++++++++++++++++++++++++"
write-host -ForegroundColor Green "Press 1 to generate Office 365 script" 
write-host -foregroundcolor Green "Press 2 to generate Sharepoint script"
write-host -foregroundcolor Green "Press 3 to listing Membership groups" 
write-host -foregroundcolor Green "Press 4 to move users to Migrated OU" 
write-host -foregroundcolor Green "Press 5 to Exit" 
write-host -ForegroundColor Green "+++++++++++++++++++++++++++++++++++++"
"`r`n"

$Case = Read-Host 
Switch ($Case)
    {
        1 {$Output = $Array | ForEach-Object {"Enable-RemoteMailbox $_ -RemoteRoutingAddress $_@anglicaresydney.mail.onmicrosoft.com"};$Output;"`n`n"}
        2 {$Output = $Array | ForEach-Object {"$_,$_"};$Output;"`n`n"}
        3 {$Output = $Array | ForEach-Object {"`n------------------------------`n$_`n------------------------------";
                                              (Get-ADPrincipalGroupMembership -Identity $_).Name
                                              };$Output;"`n`n"}
        
        4 {#Change the Target OU accordingly
           $TargetOU = "OU=Users,OU=Migrated,DC=alpineskihouse,DC=com"
           Write-Host -ForegroundColor Red "Moving below user to $TargetOU" 
           
           "`n"           
           $Output = $Array | ForEach-Object {
                                             if((Get-ADUser -Identity $_).Enabled -eq "TRUE"){
                                             Write-Host -ForegroundColor Red "Skipping this user $_ As its not disabled `n"
                                             }
                                             else{
                                                 # Retrieve DN of User. 
                                                 $UserDN  = (Get-ADUser -Identity $_).distinguishedName
                                                 filter timestamp {"$(Get-Date -Format G): $_"} 
                                                 Write-Warning "Moving $userDN Do you wish to continue?" -WarningAction Inquire
                                                 Write-Output "Moving Object $UserDN -----> $TargetOU" | timestamp >> D:\log.txt 
                                                 # Move user to target OU. 
                                                 Move-ADObject -Identity $UserDN -TargetPath $TargetOU
                                                 }
                                             }
          }
        
        5 {"Exitting";$Flag = 0}
        
        Default {write-host -ForegroundColor Red "Invalid Option Please select between 1-5";continue}
            

    }

}