<#

.EXAMPLE
wacs.exe --accepttos --emailaddress mail@example.com --source manual --host radius.example.com --validation cloudflare --cloudflareapitoken <API-TOKEN> --store certificatestore --certificatestore My --installation script --script .\Scripts\ImportNPS.ps1 --scriptparameters {CertThumbprint} {OldCertThumbprint}

#>

Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$CertThumbprint,

    [Parameter(Position=1,Mandatory=$true)]
    [string]$OldCertThumbprint
    )

$path = Join-Path $PSScriptRoot 'tmp\ias.xml'

$CertThumbprint = $CertThumbprint.ToLower()
$OldCertThumbprint = $OldCertThumbprint.ToLower()

netsh nps export filename=$path exportPSK=YES

$xml = New-Object System.Xml.XmlDocument
$xml.Load($path)
$node = $xml.Root.Children.Microsoft_Internet_Authentication_Service.Children.RadiusProfiles.Children.<PROFILE>.Properties.msEAPConfiguration

$node.InnerText = $node.InnerText.Replace($OldCertThumbprint, $CertThumbprint)

$xml.Save($path)

netsh nps import filename=$path

Remove-Item -Path $path
