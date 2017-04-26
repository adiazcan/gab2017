#Source Blob
$srcUri = "KLNGTLK1.WAV"

#Source Storage Context
$srcsa = $SAunencrypted
$srckey = (Get-AzureKeyVaultSecret -VaultName PSscripts -Name unencryptsakey).SecretValueText
$srcctx = New-AzureStorageContext -StorageAccountName $SAunencrypted -StorageAccountKey $srckey
$srccontainer = "unencryptedblob"

#Target Storage Context
$destsa = $SAencrypted
$destkey = (Get-AzureKeyVaultSecret -VaultName PSscripts -Name encryptsakey).SecretValueText
$destctx = New-AzureStorageContext -StorageAccountName $SAencrypted -StorageAccountKey $destkey
$destcontainer = "encryptedblob"

#Copy blob
Start-AzureStorageBlobCopy -SrcBlob $srcUri -SrcContainer $srccontainer -Context $srcctx -DestContainer $destcontainer -DestContext $destctx

