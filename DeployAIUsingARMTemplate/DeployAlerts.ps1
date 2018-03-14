

# create environment object to hold deployment values 
$environment = New-Object System.Object
$environment | Add-Member -type NoteProperty -name SubscriptionId -Value ""
$environment | Add-Member -type NoteProperty -name ResourceGroupName -Value ""
$environment | Add-Member -type NoteProperty -name ResourceGroupLocation -Value ""
$environment | Add-Member -type NoteProperty -name TemplatePath -Value ""
$environment | Add-Member -type NoteProperty -name ParameterPath -Value ""


# *** SQL TEST IAAS ***


# PROD - rgUSprdcc01
$environment.SubscriptionId = "f49866a0-a03d-4e77-bd84-bff800876364"
$environment.ResourceGroupName = "rgUSprdcc01"
$environment.ResourceGroupLocation = "Australia Southeast"
$environment.TemplatePath = "Alerts.json"
$environment.ParameterPath = "Alerts.parameters.json"

# paste environment block here 

Write-Host
Write-Host "*** Deployment Details ***" -ForegroundColor Yellow
Write-Host "Selected Subscription: $($environment.SubscriptionId)" -ForegroundColor Yellow
Write-Host "Target Resource Group: $($environment.ResourceGroupName)" -ForegroundColor Yellow
Write-Host "Resource Group Location: $($environment.ResourceGroupLocation)" -ForegroundColor Yellow
Write-Host "Template File: $($environment.TemplatePath)" -ForegroundColor Yellow
Write-Host "Parameters File: $($environment.ParameterPath)" -ForegroundColor Yellow
Write-Host
Write-Host "Is this correct? Press enter to continue deployment..." -ForegroundColor Red
Read-Host

# sign in
Write-Host "Logging in...";
#Login-AzureRmAccount;

Try
{
    Get-AzureRmContext -ErrorAction Continue
}
Catch [System.Management.Automation.PSInvalidOperationException]
{
    Login-AzureRmAccount
}

# select subscription
Write-Host "Selecting subscription $($environment.SubscriptionId)";
Select-AzureRmSubscription -SubscriptionID $environment.SubscriptionId;

# create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $environment.ResourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group $($environment.ResourceGroupName) does not exist.";
    Write-Host "Creating resource group $($environment.ResourceGroupName) in location $($environment.ResourceGroupLocation)";
    #New-AzureRmResourceGroup -Name $environment.ResourceGroupName -Location $environment.ResourceGroupLocation
}
else{
    Write-Host "Using existing resource group $($environment.ResourceGroupName)";
}

# deploy artefacts
Write-Host "Starting deployment...";
New-AzureRmResourceGroupDeployment -ResourceGroupName $environment.ResourceGroupName -TemplateFile $environment.TemplatePath -TemplateParameterFile $environment.ParameterPath -Verbose -DeploymentDebugLogLevel All;

