<#

.EXAMPLE
wacs.exe --accepttos --emailaddress mail@example.com --source manual --host radius.example.com --validation cloudflare --cloudflareapitoken <API-TOKEN> --store certificatestore --certificatestore My --installation script --script .\Scripts\ImportNPS.ps1 --scriptparameters {CertThumbprint}

#>

Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$thumbprint
    )

$path = Join-Path $PSScriptRoot 'tmp\ias.xml'
#get current certs thumbprints
$certs=Get-ChildItem -Path "Cert:\LocalMachine\my" -Recurse|select Thumbprint
$thumbprintsregex=$certs.Thumbprint.ToLower() -join "|"

$thumbprint = $thumbprint.ToLower()

netsh nps export filename=$path exportPSK=YES

$xml = New-Object System.Xml.XmlDocument
$xml.Load($path)
$node = $xml.Root.Children.Microsoft_Internet_Authentication_Service.Children.RadiusProfiles.Children.<PROFILE>.Properties.msEAPConfiguration

#replace only the thumbprint leaving the rest of the EAP Configuration Intact
$newnodetext= $node.'#text' -replace $thumbprintsregex,$thumbprint
$node.'#text' = $newnodetext

$xml.Save($path)

netsh nps import filename=$path

Remove-Item -Path $path
