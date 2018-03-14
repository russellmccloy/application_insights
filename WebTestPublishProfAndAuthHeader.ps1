function Get-AzureRmWebAppPublishingCredentials($resourceGroupName, $webAppName, $slotName = $null){
	if ([string]::IsNullOrWhiteSpace($slotName)){
		$resourceType = "Microsoft.Web/sites/config"
		$resourceName = "$webAppName/publishingcredentials"
	}
	else{
		$resourceType = "Microsoft.Web/sites/slots/config"
		$resourceName = "$webAppName/$slotName/publishingcredentials"
	}
	$publishingCredentials = Invoke-AzureRmResourceAction -ResourceGroupName $resourceGroupName -ResourceType $resourceType -ResourceName $resourceName -Action list -ApiVersion 2015-08-01 -Force
    	return $publishingCredentials
}

function Get-KuduApiAuthorisationHeaderValue($resourceGroupName, $webAppName, $slotName = $null){
    $publishingCredentials = Get-AzureRmWebAppPublishingCredentials $resourceGroupName $webAppName $slotName
    return ("Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $publishingCredentials.Properties.PublishingUserName, $publishingCredentials.Properties.PublishingPassword))))
}

cls

$resourceGroupName = 'rgaseintcc01';
#$webAppName = 'PatronRegistrationv1-integration';
$webAppName = 'sfmcintegrationv1-integration';

Try
{
    Get-AzureRmContext -ErrorAction Continue;
}
Catch [System.Management.Automation.PSInvalidOperationException]
{
    Login-AzureRmAccount;
}
$publishingCredentials = Get-AzureRmWebAppPublishingCredentials -resourceGroupName $resourceGroupName -webAppName $webAppName -slotName $null;
$publishingCredentials;

$authHeader = Get-KuduApiAuthorisationHeaderValue -resourceGroupName $resourceGroupName -webAppName $webAppName -slotName $null;
$authHeader
