#create KeyVault
$keyVaultName = "SQLTDEKeys"
New-AzureRmKeyVault -VaultName $keyVaultName -ResourceGroupName $resourcegroupname -Location $location -Sku premium 

ipconfig /flushdns

#Create master key
Add-AzureKeyVaultKey -VaultName $keyVaultName -Name SQLTDEKey -Destination HSM

#create Azure Ad Application
$aadClientSecret = "vv9309r8290rsdvlksdfklwfkljdklfjglk||kwfkljfjwf==sdfkndf=="
$azureAdApp = New-AzureRmADApplication -DisplayName "SQLTDEApp" -HomePage "https://sqltde.startrek.com" -IdentifierUris "https://sqltde.startrek.com" -Password $aadClientSecret
$servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApp.ApplicationId
$servicePrincipal.ApplicationId

#give application access to KeyVault
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $servicePrincipal.ApplicationId -PermissionsToKeys get,wrapKey -PermissionsToSecrets all -ResourceGroupName $resourcegroupname

#https://www.microsoft.com/en-us/download/details.aspx?id=45344