<#

.EXAMPLE
wacs.exe --accepttos --emailaddress mail@example.com --source manual --host radius.example.com --validation cloudflare --cloudflareapitoken <API-TOKEN> --store certificatestore --certificatestore My --installation script --script .\Scripts\Update-NPSPEAPCert.ps1 --scriptparameters {CertThumbprint}

#>

Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$thumbprint
    )

$path = Join-Path $PSScriptRoot 'tmp\NPSConfig.xml'
$prefix = '190000000000000000000000000000003800000002000000380000000100000014000000'
$suffix = '0100000001000000100000001a00000000000000'
$thumbprint = $thumbprint.ToLower()

netsh nps export filename=$path exportPSK=YES

$xml = [xml](Get-Content -Path $path)
$node = $xml.Root.Children.Microsoft_Internet_Authentication_Service.Children.RadiusProfiles.<PROFILE>.Properties.msEAPConfiguration

$node.'#text' = $prefix + $thumbprint + $suffix

$xml.Save($path)

netsh nps import filename=$path

Remove-Item -Path $path