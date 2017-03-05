


<#
Name: WKAzureNSGModule.psm1
Description: Script to manage created of NSGs for Wolther Kluwer's Azure Cloud
Author: Justin Ruffin
Last Modified: 7/27/2015

Modification History:

    07-26-2015 - Justin Ruffin
        Added: Format-AzureLocation
        Added: Test-AzureLocationIsValid
        Added: Create-AzureNSGSubnet 

    07-27-2015
        Remove: Format-AzureLocation
        Remove: Test-AzureLocationIsValid
        Remove: Create-AzreuNSGSubnet
        Added:  New-WKAzureNSGSubnet
        Added: IsNullOrEmpty
        Added: Write-Success
        Added: Write-Failure
#>


<#
.SYNOPIS
Creates an Subnet NSG

.DESCRIPTION
Creates an Subnet NSG for Wolters Kluwer, validates the location, and creates
the NSG name in a standardized format.

NSG name format: NSG-[TIER]-[REGION]

Usage:
New-AzureNSGSubnet -Tier "FE" -Location "West US"

.PARAMETER Tier
FE, BE or CORE

.PARAMETER Location
West US, East US, East US 2

#>
function New-WKAzureNSGSubnet
{
[CmdletBinding()]
param
(
[Parameter(Mandatory=$true, ValueFromPipeline=$false)]
[ValidateSet("FE", "BE", "CORE")]
[String] $Tier,

[Parameter(Mandatory=$true, ValueFromPipeline=$false)]
[ValidateSet("East US", "East US 2", "West US")]
[String] $Location
)

        #Create NSG Standard Name
        $nsgName = Format-WKAzureNSGSubnetName -Tier $Tier -Location $Location

        #Try getting the NSG
        $nsg = Get-AzureNetworkSecurityGroup -Name $nsgName -ErrorAction SilentlyContinue
        
        
        #Determine if the NSG exists
        if ($nsg -eq $null)
        {
         $nsg = New-AzureNetworkSecurityGroup -Name $nsgName -Location "West US"
         $nsg | Add-Member -MemberType NoteProperty -Name "Current Status" -Value "Created successfully" 
         return $nsg
        }
        else
        {
        #Unable to create the NSG, because it already exists.
        $nsg | Add-Member -MemberType NoteProperty -Name "Current Status" -Value "Already exists"
        return $nsg
        }

}

function New-WKAzureActionResult
{
param
(
[Parameter(Position=1)] 
[string] 
$Name,

[Parameter(Position=2)] 
[ValidateSet("Subnet NSG")]
[string] 
$Type,

[Parameter(Position=3)] 
[string] 
$Action,

[Parameter(Position=4)] 
[string] 
$Message
)

$obj = New-Object -TypeName PSObject
$obj | Add-Member -MemberType Property -Name Name -Value $Name 
$obj | Add-Member -MemberType NoteProperty -Name Type $Type
$obj | Add-Member -MemberType NoteProperty -Name Action -Value $Action
$obj | Add-Member -MemberType NoteProperty -Name Message -Value $Message

return $obj

}

function Remove-WKAzureNSGSubnet
{
[CmdletBinding()]
param
(
[Parameter(Mandatory=$true, ValueFromPipeline=$false)]
[ValidateSet("FE", "BE", "CORE")]
[String] $Tier,

[Parameter(Mandatory=$true, ValueFromPipeline=$false)]
[ValidateSet("East US", "East US 2", "West US")]
[String] $Location
)

    #Create NSG Standard Name
    $nsgName = Format-WKAzureNSGSubnetName -Tier $Tier -Location $Location

    #Try getting the NSG
    $nsg = Get-AzureNetworkSecurityGroup -Name $nsgName -ErrorAction SilentlyContinue

    if ($nsg -ne $null)
    {
    Remove-AzureNetworkSecurityGroup -Name $nsgName -Force
    return (New-WKAzureActionResult $nsgName "Subnet NSG" "Remove" "Successfully Removed NSG")
    }
    return (New-WKAzureActionResult $nsgName "Subnet NSG" "Remove" "Failed to remove NSG, because it does not exist.")
}


function Format-WKAzureNSGSubnetName
{
    [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true, ValueFromPipeline=$false)]
    [ValidateSet("FE", "BE", "CORE")]
    [String] $Tier,

    [Parameter(Mandatory=$true, ValueFromPipeline=$false)]
    [ValidateSet("East US", "East US 2", "West US")]
    [String] $Location
    )

        #Remove all spaces and format to upper case.
        $Loc = $Location.ToUpper().Replace(" ", "");

        if (IsNullOrEmpty($Tier))
        {
        throw "Invalid Tier"
        }

        if (IsNullOrEmpty($Loc))
        {
        throw "Invalid Location"
        }

        #Create NSG Standard Name
        $nsgName = "NSG-$Tier-$Loc"

        return $nsgName
}


function New-WKAzureActionResult
{
param
(
[Parameter(Position=1)] 
[string] 
$Name,

[Parameter(Position=2)] 
[ValidateSet("Subnet NSG")]
[string] 
$Type,

[Parameter(Position=3)] 
[string] 
$Action,

[Parameter(Position=4)] 
[string] 
$Message
)

$obj = New-Object -TypeName PSObject
$obj | Add-Member -MemberType Property -Name Name -Value $Name 
$obj | Add-Member -MemberType NoteProperty -Name Type $Type
$obj | Add-Member -MemberType NoteProperty -Name Action -Value $Action
$obj | Add-Member -MemberType NoteProperty -Name Message -Value $Message

return $obj

}
 

function IsNullOrEmpty([string] $value)
{
    return [System.String]::IsNullOrEmpty($value)
}

function Write-Success([string] $value)
{
Write-Host $value -ForegroundColor Green
}

function Write-Failure([string] $value)
{
Write-Host $value -ForegroundColor Red
}






