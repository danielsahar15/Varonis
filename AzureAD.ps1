Param($tenant_ID= 'd3de388b-8f9e-46e9-80ad-8446f082b755',
[string]$AD_Group_Name = 'Varonis Assignment Group',
[string]$User_Prefix = 'Test User ',
[Int]$Count = 20

)
function Get-TimeStamp {return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)}
###########
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "<Password>"
$DomainName = "danielsahar15gmail.onmicrosoft.com"
###########


Write-Output "$(Get-TimeStamp)Connecting Tenant Id : "$tenant_ID
$Connection = Connect-AzureAD -TenantId $tenant_ID -ErrorAction Stop

$Result = $null
for($i = 0 ; $i -lt $Count ; $i++)
    {
    $User = $User_Prefix+$i
    $SPN = $User.Replace(' ','') + "@" + $DomainName
    Write-Output "$(Get-TimeStamp)Adding User  : $User"
    try{
        [array]$Result += New-AzureADUser -DisplayName $User -PasswordProfile $PasswordProfile -UserPrincipalName $SPN -AccountEnabled $true -MailNickName "Newuser"
        Write-Output "$(Get-TimeStamp)User Added Successfully :)"

        }catch{ Write-Output "$(Get-TimeStamp)Failed To Add user ~ $User ~ :(`n"$Error[0].Exception.Message }
    }
    
Write-Output "$(Get-TimeStamp)Creating New AzureADGroup : "$AD_Group_Name
$group = New-AzureADGroup -DisplayName $AD_Group_Name -Description $AD_Group_Name -SecurityEnabled $true -MailNickName $AD_Group_Name.Replace(' ','') -MailEnabled $false -ErrorAction stop 

$Result | %{try{ Write-Output "$(Get-TimeStamp)Adding User : $($_.DisplayName) To Group : $($group.DisplayName)";Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $_.ObjectId -ErrorAction Stop}catch{Write-Output "$(Get-TimeStamp)Failed To Add user ~ $User ~ :(`n"$Error[0].Exception.Message }}

Write-Output "$(Get-TimeStamp)Done!"