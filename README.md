# windows-nps-letsencrypt
A PowerShell script that integrates with [simple-acme](https://simple-acme.com/) to provide Let's Encrypt certificates for the Windows Network Policy Server.

This repository contains a minimal PowerShell script to automatically update the server certificate used by the Windows Network Policy Server after a certificate renewal via simple-acme.
A server certificate is needed for server validation with PEAP-MS-CHAP v2, PEAP-TLS, or EAP-TLS as the authentication method.
Let's Encrypt **cannot** issue client certificates to be used with EAP-TLS or PEAP-TLS.

## How it works
The configuration of the Windows Network Policy Server (NPS), including the thumbprint of a configured server certificate for a given RADIUS profile, can be exported to an XML file or can be imported from an XML file. The script exports the configuration to a temporary location, replaces the certificate thumbprint for the given RADIUS profile with the thumbprint of the new certificate, imports the updated NPS configuration and deletes the exported XML file. simple-acme directly passes the thumbprint of the renewed certificate to the script as a parameter. It is not required to restart NPS after the import as the configuration is automatically applied.

## Getting started
1. Download and install simple-acme as described in the [documentation](https://simple-acme.com/manual/installation).
2. Install a [DNS validation plugin](https://simple-acme.com/reference/plugins/validation/dns/) for simple-acme that works with your DNS provider. The following steps assume Cloudflare as your DNS provider.
3. Download the `ImportNPS.ps1` script from the Releases section of this repository and place it in the `Scripts` directory of your simple-acme installation. You may need to allow execution of unsigned PowerShell scripts on your server.
4. Create a directory named `tmp` within the `Scripts` directory. The exported XML configuration file will be saved there.
5. Request a new certificate using simple-acme once without executing the script:
   ```powershell
   wacs.exe --accepttos --emailaddress mail@example.com --source manual --host radius.example.com --validation cloudflare --cloudflareapitoken <API-TOKEN> --store certificatestore --certificatestore My
   ```
6. Select the newly requested certificate when configuring one or more network policies.
7. Manually export the XML file with
    ```powershell
    netsh nps export filename=%USERPROFILE%\Downloads\ias.xml exportPSK=YES
    ```
   Open the exported XML file in a browser or editor of your choice and search for the `RadiusProfiles` node.
8. Replace `<PROFILE>` in the `$node` variable with the name of your RADIUS profile, e.g `Secure_Wireless_Connections`.
9. Update the certificate renewal to execute the script after a successful renewal:
   ```powershell
    wacs.exe --accepttos --emailaddress mail@example.com --source manual --host radius.example.com --validation cloudflare --cloudflareapitoken <API-TOKEN> --store certificatestore --certificatestore My --installation script --script .\Scripts\ImportNPS.ps1 --scriptparameters {CertThumbprint} {OldCertThumbprint}
    ```
