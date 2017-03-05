#
# ManagersModule.psm1
#
<#
.Synopsis
    Creates an object with user properties
.DESCRIPTION
    Creates an object with two properties Manager and Account Name
	Use this function as a result set standarized
.EXAMPLE
    New-ClientAccountName -Manager JohnDoe -AccountName john.doe
#>
function New-UserInformation
{
	param
	(
	[Parameter(Position=1)]
	[AllowEmptyString()] 
	[string] 
	$Manager,
	[Parameter(Position=2)] 
	[string] 
	$AccountName
	)

	$obj = New-Object -TypeName PSObject
	$obj | Add-Member -MemberType NoteProperty -Name Manager -Value $Manager 
	$obj | Add-Member -MemberType NoteProperty -Name AccountName -Value $AccountName
	return $obj

}



<#
.Synopsis
    Creates an object with user properties
.DESCRIPTION
    Loop through the User Profiles and get information regarding the Manager of each profile
	then return an object with Manager and AccountName as its properties
.EXAMPLE
    $resultVariable = Get-UserInformation
	Get-UserInformation | Foreach-Object { $_ } -process
#>
function Get-UserInformation {
	#Add SharePoint PowerShell SnapIn if not already added 
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) { 
	Add-PSSnapin "Microsoft.SharePoint.PowerShell" } $site = new-object Microsoft.SharePoint.SPSite("http://WebapplicationURL/"); 
	$ServiceContext = [Microsoft.SharePoint.SPServiceContext]::GetContext($site); 
#Get UserProfileManager from the My Site Host Site context 
$ProfileManager = new-object Microsoft.Office.Server.UserProfiles.UserProfileManager($ServiceContext) 
$AllProfiles = $ProfileManager.GetEnumerator() 

#Variable to store the result
$users = @()
	foreach($profile in $AllProfiles) 
	{ 
		$Manager = $profile[[Microsoft.Office.Server.UserProfiles.PropertyConstants]::Manager].Value  
		$AccountName = $profile[[Microsoft.Office.Server.UserProfiles.PropertyConstants]::AccountName].Value 
	
		#Add to the result a new object with the information needed
		$users += (New-UserInformation -Manager $Manager -AccountName $AccountName)
	
	}
return $users	 
write-host "Finished." $site.Dispose()
}

<#
.Synopsis
    Creates a hash table of Managers
.DESCRIPTION
    Creates a hash table of Managers with the Manager as Key and its subordinates as values into an array
.EXAMPLE
    Get-Managers ($arrayWithInformationOfUsers)
#>

function Get-Managers
{
[CmdletBinding()]
param
(
[Parameter(Mandatory=$true, ValueFromPipeline=$false)]
[object[]] $UserInformation
)

$Managers = @{}
	foreach ($user in $UserInformation)
	{
		if ($Managers.ContainsKey($user.Manager) -eq $false)
		{
			$temp = @()
			$temp += $user.AccountName
			$Managers.Add($user.Manager, $temp)
		}
		else
		{

			$temp = $Managers[$user.Manager]
			$temp += $user.AccountName
			$Managers[$user.Manager] = $temp
		}
	}
return $Managers
}