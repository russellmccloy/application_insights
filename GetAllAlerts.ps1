[CmdletBinding(PositionalBinding=$True)]
    Param
    (    
        #Parameter()]#Mandatory = $true
	    [String]$SubscriptionId = "f49866a0-a03d-4e77-bd84-bff800876364",

        [Parameter()] #Mandatory = $true
        [String]$ResourceGroupName = "rgaseprdcc01"
	)

function Check-Session () {
    $Error.Clear()

    #if context already exist
    Get-AzureRmContext -ErrorAction Continue
    foreach ($eacherror in $Error) {
        if ($eacherror.Exception.ToString() -like "*Run Login-AzureRmAccount to login.*") {
            Login-AzureRmAccount
        }
    }

    $Error.Clear();
}

cls

$environment = New-Object System.Object
    $environment | Add-Member -type NoteProperty -name SubscriptionId -Value ""
    $environment | Add-Member -type NoteProperty -name ResourceGroupName -Value ""
    $environment | Add-Member -type NoteProperty -name ResourceGroupLocation -Value ""

    # Enter your subscriptionid and resource Group
    $environment.SubscriptionId = $SubscriptionId
    $environment.ResourceGroupName = $ResourceGroupName

$environment.SubscriptionId;

Write-Host "Logging in..." -ForegroundColor Yellow;
Check-Session;

Write-Host "Selecting the subscription you want to work with..." -ForegroundColor Yellow;

Select-AzureRmSubscription -SubscriptionID $environment.SubscriptionId;

$currentAlertRules = Get-AzureRmAlertRule -ResourceGroup $ResourceGroupName -DetailedOutput #  | Format-Table

foreach ($rule in $currentAlertRules) {
   Write-Host $rule.Name
   Write-Host $rule.Properties.Condition.DataSource.ResourceUri
   Write-Host $rule.Properties.Condition.DataSource.MetricName
   Write-Host $rule.Properties.Condition.Threshold
   Write-Host $rule.Properties.Condition.WindowsSize
   Write-Host $rule.Properties.Condition.Operator
   Write-Host $rule.Properties.Condition.TimeAggregation
}

 <#
$currentAlertRules | Foreach-Object {

    New-Object -TypeName PSObject -Property @{
                        Name = $_.Name    
                        PropertiesResourceId = $_.ResourceId 
                } | Select-Object Name, PropertiesResourceId
}
#>
#Write-Host "Resource: " $currentAlertRules.Properties.Name + "|"
<#
    DEV -     2cfe2141-6853-4cef-80d9-635af3ad9b42    rgasedevcc01    rgaesdevcc01
    UAT -     6a7dabba-f52c-4bab-a21b-ed5930adf081    rgaseuatcc01    rgaesuatcc01
    PROD -    f49866a0-a03d-4e77-bd84-bff800876364    rgaseprdcc01    rgaesprdcc01
#>

