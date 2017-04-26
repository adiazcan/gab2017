#create storage account 
New-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $SAunencrypted -Type Standard_LRS -Location $location
New-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $SAencrypted -Type Standard_LRS -Location $location

$storage = Get-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $SAunencrypted
$destContext = $storage.Context 
New-AzureStorageContainer -Name "unencryptedblob" -Context $destContext 
Set-AzureStorageBlobContent -File .\KLNGTLK1.WAV -Container "unencryptedblob" -Blob "KLNGTLK1.WAV" -Context $destContext -Force

$storage = Get-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $SAencrypted
$destContext = $storage.Context 
New-AzureStorageContainer -Name "encryptedblob" -Context $destContext 


#get storage account encryption status
Get-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $SAunencrypted
Get-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $SAencrypted

#encrypt Storage
Set-AzureRmStorageAccount -ResourceGroupName $resourcegroupname -Name $SAencrypted -EnableEncryptionService Blob

#Create KeyVault
New-AzureRmKeyVault -VaultName PSscripts -ResourceGroupName $resourcegroupname -Location $location -Sku Standard

$encriptkey = (Get-AzureRmStorageAccountKey -Name $SAencrypted -ResourceGroupName $resourcegroupname).Value[0]
$unencriptkey = (Get-AzureRmStorageAccountKey -Name $SAunencrypted -ResourceGroupName $resourcegroupname).Value[0]

$secretkey1 = ConvertTo-SecureString $encriptkey -AsPlainText -Force
$secretkey2 = ConvertTo-SecureString $unencriptkey -AsPlainText -Force

$kvsecret1 = Set-AzureKeyVaultSecret -VaultName PSscripts -Name encryptsakey -SecretValue $secretkey1
$kvsecret2 = Set-AzureKeyVaultSecret -VaultName PSscripts -Name unencryptsakey -SecretValue $secretkey2

$kvsecret1
