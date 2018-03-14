$resource = Get-AzureRmResource -ResourceId "/subscriptions/2cfe2141-6853-4cef-80d9-635af3ad9b42/resourceGroups/rgasedevcc01/providers/Microsoft.Insights/components/CanaryServicev1-Dev"

$resource.Properties.InstrumentationKey
$resource.Properties