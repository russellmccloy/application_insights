[CmdletBinding(PositionalBinding=$True)]
    Param
    (    
        [Parameter(Mandatory = $true)]
	    [String]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [String]$ResourceGroupName
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

$resource = Get-AzureRmResource -ResourceId "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Insights/components"

$myPath = "c:\temp3\AllAppInsightsInResourceGroup.csv"

$resource | Out-GridView

$resource | foreach {

    New-Object -TypeName PSObject -Property @{
                    Name = $_.Name
                    ResourceGroupName = $_.ResourceGroupName    
                    InstrumentationKey = $_.Properties.InstrumentationKey 
            } | Select-Object Name, ProjectName, ResourceGroupName, InstrumentationKey

} | Export-Csv -Path $myPath -Append 
