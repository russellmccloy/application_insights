#[CmdletBinding(PositionalBinding=$True)]
function AddAlerts() 
{
    Param
    (    
        [Parameter(Mandatory = $true)]
	    [String]$SubscriptionId,

        [Parameter(Mandatory = $true)] 
        [String]$ResourceGroupName,

        [Parameter(Mandatory = $true)] 
        [String]$EnvironmentName,   # like: dev, test, int, prod

        [Parameter(Mandatory = $true)] 
        [int]$UpdateAction#,   # 0 lists all existing alerts | 1 adds alerts | 2 removes alerts

        #[Parameter(Mandatory = $true)] 
        #[Switch]$DisableAllAlertRule
	)

    cls

    $environment = New-Object System.Object
        $environment | Add-Member -type NoteProperty -name SubscriptionId -Value ""
        $environment | Add-Member -type NoteProperty -name ResourceGroupName -Value ""
        $environment | Add-Member -type NoteProperty -name ResourceGroupLocation -Value ""

        # Enter your subscriptionid and resource Group
        $environment.SubscriptionId = $SubscriptionId
        $environment.ResourceGroupName = $ResourceGroupName

    Write-Host "Logging in..." -ForegroundColor Yellow;
    #Check-Session;
    Check-Session2;

    Write-Host "Selecting the subscription you want to work with..." -ForegroundColor Yellow;

    # Not sure what is going on here but lets run both of the following
    Select-AzureRmSubscription -SubscriptionID $environment.SubscriptionId;
    Select-AzureSubscription -SubscriptionID $environment.SubscriptionId;

    $EnvironmentName = $EnvironmentName.ToLower();

    # the following list is all the web apps that we dont want to add alerts to
    [string[]] $webAppExclusions;

    $currentResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName

    # Get all Web apps in resource group
    Write-Host "Getting all web apps in resource group $ResourceGroupName ..." -ForegroundColor Yellow;
    $webApps = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName;

    #[System.Collections.Generic.List[System.Object]] $webAppsFilterList = RemoveExcludedWebApps -webApps $webApps -webAppExclusions $webAppExclusions;

    $allAlertRules = New-Object "System.Collections.Generic.List[System.Object]";

    if($UpdateAction -eq 0) {
        Write-Host "Getting all existing alert rules: $webAppName" -ForegroundColor Cyan;
        #$currentAlertRules = Get-AzureRmAlertRule -ResourceGroup $ResourceGroupName -DetailedOutput #  | Format-Table

        $currentAlertRules = Get-AzureRmAlertRule -ResourceGroup $ResourceGroupName #-DetailedOutput
        if($currentAlertRules.Count -eq 0)
        {
            Write-Host "There were NO alert rules on Micro-service: $webAppName" -ForegroundColor Red;
        }

        $allAlertRules.AddRange($currentAlertRules);
        $currentAlertRules.Clear();
        
        $allAlertRules | Select-Object -ExpandProperty Properties | Format-Table    
    }

    $webAppsFilterList = New-Object "System.Collections.Generic.List[System.Object]";

    if($UpdateAction -eq 1) {

        foreach ($webApp in $webApps| where {$_.Name -contains "PatronDocumentv1-$EnvironmentName"}) {   # | where {$_.Name -contains "PatronDocumentv1-$EnvironmentName"}  -Or $_.Name -contains "PatronProfilev1-$EnvironmentName"

            Write-Host "Micro-Service: " $webApp.Name -ForegroundColor Green;
            $webAppsFilterList.Add($webApp.Name);
        }
    }

    if($UpdateAction -eq 2) {

        foreach ($webApp in $webApps) {  

            Write-Host "Micro-Service: " $webApp.Name -ForegroundColor Green;
            $webAppsFilterList.Add($webApp.Name);
        }
    }

    foreach ($webAppName in $webAppsFilterList) {

        
        $mailTo = New-Object "System.Collections.Generic.List[String]";  
        $mailTo.Add(“
        ”); 
        $action = New-Object "Microsoft.Azure.Management.Insights.Models.RuleEmailAction"; 
        $action = New-AzureRmAlertRuleEmail -CustomEmails $mailTo -SendToServiceOwners
        #$action.SendToServiceOwners = $true; 


        if($UpdateAction -eq 1) {

            # #################################################################################################
            # Alert 1 - Average server response time greater than threshold
            $alertName = "$webAppName - Average server response time greater than threshold";
            $description = "$webAppName - Average server response time greater than threshold";

            Write-Host "Adding alert rule: $alertName" -ForegroundColor Cyan;

            $alertResult = AddAlertRule `
                        -currentResourceGroup $currentResourceGroup `
                        -metricName "AverageResponseTime" `
                        -alertName $alertName `
                        -threshold 0.25 `
                        -windowSize "00:05:00" `
                        -description $description `
                        -action $action `
                        -disableRule $DisableAllAlertRule `
                        -targetResourceId "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$webAppName"

            # #################################################################################################

            # #################################################################################################
            # Alert 2 - Average CPU time greater than threshold
            $alertName = "$webAppName - Average CPU time greater than threshold";
            $description = "$webAppName - Average CPU time greater than threshold";

            Write-Host "Adding alert rule: $alertName" -ForegroundColor Cyan;

            $alertResult = AddAlertRule `
                        -currentResourceGroup $currentResourceGroup `
                        -metricName "AverageResponseTime" `
                        -alertName $alertName `
                        -threshold 80 `
                        -windowSize "00:05:00" `
                        -description $description `
                        -action $action `
                        -disableRule $DisableAllAlertRule `
                        -targetResourceId "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$webAppName"

            # #################################################################################################

            # #################################################################################################
            # Alert 3 - Request Rate
            $alertName = "$webAppName - Average request rate greater than threshold";
            $description = "$webAppName - Average request rate greater than threshold";

            Write-Host "Adding alert rule: $alertName" -ForegroundColor Cyan;

            $alertResult = AddAlertRule `
                        -currentResourceGroup $currentResourceGroup `
                        -metricName "Requests" `
                        -alertName $alertName `
                        -threshold 250 `
                        -windowSize "00:05:00" `
                        -description $description `
                        -action $action `
                        -disableRule $DisableAllAlertRule `
                        -targetResourceId "/subscriptions/$SubscriptionId/
                        resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$webAppName"

            # #################################################################################################

        }

        if($UpdateAction -eq 2) {
            $alertName = "$webAppName - Average server response time greater than threshold";
            Write-Host "removing alert rule: $alertName" -ForegroundColor Magenta;
            Remove-AzureRmAlertRule -ResourceGroup $ResourceGroupName -Name $alertName
            
            $alertName = "$webAppName - Average CPU time greater than threshold";
            Write-Host "removing alert rule: $alertName" -ForegroundColor Magenta;
            Remove-AzureRmAlertRule -ResourceGroup $ResourceGroupName -Name $alertName

            $alertName = "$webAppName - Average request rate greater than threshold";
            Write-Host "removing alert rule: $alertName" -ForegroundColor Magenta;
            Remove-AzureRmAlertRule -ResourceGroup $ResourceGroupName -Name $alertName
        }
    }
}

# ############################################################################################################################################
# DEV
# READ
# AddAlerts -SubscriptionId 2cfe2141-6853-4cef-80d9-635af3ad9b42 -ResourceGroupName rgasedevcc01 -EnvironmentName dev -UpdateAction 0 -Verbose

# Add
# AddAlerts -SubscriptionId 2cfe2141-6853-4cef-80d9-635af3ad9b42 -ResourceGroupName rgasedevcc01 -EnvironmentName dev -UpdateAction 1 -Verbose

# DELETE
# AddAlerts -SubscriptionId 2cfe2141-6853-4cef-80d9-635af3ad9b42 -ResourceGroupName rgasedevcc01 -EnvironmentName dev -UpdateAction 2 -Verbose
# ############################################################################################################################################

# ############################################################################################################################################
# UAT
# READ
# AddAlerts -SubscriptionId 6a7dabba-f52c-4bab-a21b-ed5930adf081 -ResourceGroupName rgaseintcc01 -EnvironmentName integration -UpdateAction 0 -Verbose

# Add
# AddAlerts -SubscriptionId 6a7dabba-f52c-4bab-a21b-ed5930adf081 -ResourceGroupName rgaseintcc01 -EnvironmentName integration -UpdateAction 1 -Verbose

# DELETE
# AddAlerts -SubscriptionId 6a7dabba-f52c-4bab-a21b-ed5930adf081 -ResourceGroupName rgaseintcc01 -EnvironmentName integration -UpdateAction 2 -Verbose
# ############################################################################################################################################

# ############################################################################################################################################
# PROD
# READ
# AddAlerts -SubscriptionId f49866a0-a03d-4e77-bd84-bff800876364 -ResourceGroupName rgaseprdmscc01 -EnvironmentName prod -UpdateAction 0 -Verbose

# Add
# AddAlerts -SubscriptionId f49866a0-a03d-4e77-bd84-bff800876364 -ResourceGroupName rgaseprdmscc01 -EnvironmentName prod -UpdateAction 1 -Verbose

# DELETE
# AddAlerts -SubscriptionId f49866a0-a03d-4e77-bd84-bff800876364 -ResourceGroupName rgaseprdmscc01 -EnvironmentName prod -UpdateAction 2 -Verbose
# ############################################################################################################################################
<#
    DEV -     2cfe2141-6853-4cef-80d9-635af3ad9b42    rgasedevcc01    rgaesdevcc01
    UAT -     6a7dabba-f52c-4bab-a21b-ed5930adf081    rgaseuatcc01    rgaesuatcc01
    PROD -    f49866a0-a03d-4e77-bd84-bff800876364    rgaseprdcc01    rgaesprdcc01
#>

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

function Check-Session2 () {
    Try
    {
        Get-AzureRmContext -ErrorAction Continue
    }
    Catch [System.Management.Automation.PSInvalidOperationException]
    {
        Login-AzureRmAccount
    }
}

function RemoveExcludedWebApps()
{    
    Param
    (    
	    [System.Object[]]$webApps,
	    [System.Collections.Generic.List[System.Object]]$webAppExclusions
    )

    #$webAppExclusions2 = New-Object "System.Collections.Generic.List[System.Object]";
    Write-Host "Removing all web apps that are in the webAppExclusions list" -ForegroundColor Yellow;

    $webAppsFilterList = New-Object "System.Collections.Generic.List[System.Object]";
    #[System.Collections.Generic.List[System.Object]]$webAppsFilterList;

    $webAppsFilterList.Clear();

    foreach ($webApp in $webApps) {

        #if($webAppExclusions.Contains($webApp.Name.ToLower()))
        #{
        #    Write-Host "Removing: " $webApp.Name -ForegroundColor Red;
        #} else 
        #{
            Write-Host "Keeping: " $webApp.Name -ForegroundColor Green;
            $webAppsFilterList.Add($webApp.Name);
        #}
    }
    return $webAppsFilterList;
}

function AddAlertRule()
{
    Param
    (    
        [System.Object[]]$currentResourceGroup,
        [string]$metricName,
        [string]$alertName,
        [double]$threshold,
        [string]$windowSize,
        [string]$description,
        [Microsoft.Azure.Management.Insights.Models.RuleEmailAction] $action,
        #[Switch]$disableRule  = $false,
        [string]$targetResourceId
    )

    Add-AzureRmMetricAlertRule -Location $currentResourceGroup.Location `
                -MetricName $metricName `
                -Name $alertName `
                -Operator GreaterThan `
                -ResourceGroup $currentResourceGroup.ResourceGroupName `
                -TargetResourceId $targetResourceId `
                -Threshold $threshold `
                -TimeAggregationOperator Average `
                -WindowSize $windowSize `
                -Actions $action `
                -Description $description
                #                -DisableRule $disableRule `

}


