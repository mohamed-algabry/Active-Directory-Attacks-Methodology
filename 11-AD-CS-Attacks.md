# Chapter 11: AD CS Attacks

Active Directory Certificate Services (AD CS) allows organizations to issue and manage public key certificates. While essential for securing communications, AD CS is frequently misconfigured, leading to critical vulnerabilities that allow attackers to escalate privileges, perform lateral movement, and maintain persistence.

## Certificate Services Overview

AD CS uses Certificate Templates to define the properties of certificates that can be requested by users or computers. The misconfiguration of these templates is the root cause of most AD CS attacks.

### Key Concepts
- **Certificate Template**: Defines the permissions, usage, and validity of a certificate.
- **Certificate Authority (CA)**: The server that issues certificates based on the templates.
- **Enrollment**: The process of requesting a certificate from the CA.

## ESC1: Misconfigured Certificate Templates

ESC1 occurs when a certificate template allows users to specify a Subject Alternative Name (SAN) and can be used for authentication.

### How it works
1. The attacker requests a certificate using the vulnerable template.
2. The attacker specifies a SAN (e.g., `user@domain.com` or `CN=Administrator`) in the request.
3. The CA issues a certificate that authenticates as the specified user (e.g., a Domain Admin).

### Example using Certipy

```bash
# Using Certipy
certipy req -ca '<CA_Name>' -template 'VulnerableTemplate' -upn 'administrator@domain.com'
```

## ESC2: Misconfigured Certificate Templates (Any Purpose)

ESC2 occurs when a certificate template allows for "Any Purpose" usage and is accessible to low-privileged users.

### How it works
1. The attacker requests a certificate using the "Any Purpose" template.
2. The attacker uses this certificate to request a new certificate on behalf of any user (e.g., a Domain Admin) using the Certificate Request Agent template.

### Example using Certipy

```bash
# Using Certipy
certipy req -ca '<CA_Name>' -template 'AnyPurposeTemplate'
```

## ESC3: Misconfigured Certificate Templates (Enrollment Agent)

ESC3 occurs when a certificate template allows for "Certificate Request Agent" usage and is accessible to low-privileged users.

### How it works
1. The attacker requests a Certificate Request Agent certificate.
2. The attacker uses this certificate to request a new certificate on behalf of any user (e.g., a Domain Admin) using a vulnerable template (like ESC1 or ESC2).

### Example using Certipy

```bash
# Using Certipy
certipy req -ca '<CA_Name>' -template 'EnrollmentAgentTemplate'
```

## ESC4: Vulnerable Certificate Template Access Control

ESC4 occurs when a low-privileged user has write access to a certificate template.

### How it works
1. The attacker modifies the vulnerable certificate template to add their own user as an authorized requester or enables the "Sanitize" flag.
2. The attacker then exploits the template using ESC1, ESC2, or ESC3.

### Example using Certipy

```bash
# Using Certipy
certipy template -template 'VulnerableTemplate' -save-old
certipy req -ca '<CA_Name>' -template 'VulnerableTemplate' -upn 'administrator@domain.com'
```

## ESC5: Vulnerable PKI Object Access Control

ESC5 occurs when a low-privileged user has write access to PKI-related objects (e.g., the CA server, the CA certificate, or the CA's private key).

### How it works
1. The attacker modifies the CA's configuration or certificate to allow for the issuance of unauthorized certificates.
2. The attacker issues certificates to escalate privileges.

## ESC6: EDITF_ATTRIBUTESUBJECTALTNAME2 Flag

ESC6 occurs when the CA has the `EDITF_ATTRIBUTESUBJECTALTNAME2` flag set. This flag allows all templates to honor the SAN specified in the request, regardless of the template's configuration.

### How it works
1. The attacker requests a certificate using any valid template.
2. The attacker specifies a SAN (e.g., `user@domain.com` or `CN=Administrator`) in the request.
3. The CA issues a certificate that authenticates as the specified user.

### Example using Certipy

```bash
# Using Certipy
certipy req -ca '<CA_Name>' -template 'ValidTemplate' -upn 'administrator@domain.com'
```

## ESC7: Vulnerable Certificate Authority Access Control

ESC7 occurs when a low-privileged user has write access to the Certificate Authority itself (e.g., `Manage CA` or `Manage Certificates` permissions).

### How it works
1. The attacker enables a disabled certificate template (e.g., `SubCA`) or changes its configuration.
2. The attacker requests a certificate using the enabled template to escalate privileges.

### Example using Certipy

```bash
# Using Certipy
certipy ca -ca '<CA_Name>' -enable-template 'SubCA'
```

## ESC8: NTLM Relay to AD CS HTTP Endpoints

ESC8 occurs when an attacker can relay an NTLM authentication request to an AD CS HTTP enrollment endpoint (e.g., `http://<CA_Server>/certsrv/certfnsh.asp`).

### How it works
1. The attacker forces a high-privileged user (e.g., a Domain Admin) to authenticate to the attacker's machine (e.g., via LLMNR poisoning).
2. The attacker relays the NTLM authentication to the AD CS HTTP endpoint.
3. The CA issues a certificate that authenticates as the high-privileged user.

### Example using Certipy and Impacket

```bash
# Using Impacket to relay NTLM
python3 ntlmrelayx.py -t http://<CA_Server>/certsrv/certfnsh.asp -smb2support --adcs
```

## ESC9: No Security Extension

ESC9 occurs when a certificate template does not have the `CT_FLAG_NO_SECURITY_EXTENSION` flag set, but the CA is configured to issue certificates without the PKINIT encryption key.

### How it works
1. The attacker requests a certificate using a vulnerable template.
2. The attacker uses the certificate to authenticate without PKINIT encryption, allowing for potential manipulation.

## ESC10: Weak Certificate Mapping

ESC10 occurs when the CA is configured to map certificates to users based on weak criteria (e.g., only the UPN).

### How it works
1. The attacker requests a certificate with a SAN that matches a high-privileged user's UPN.
2. The CA maps the certificate to the high-privileged user, allowing the attacker to authenticate as them.

### Example using Certipy

```bash
# Using Certipy
certipy req -ca '<CA_Name>' -template 'VulnerableTemplate' -upn 'administrator@domain.com'
```

## Shadow Credentials

Shadow Credentials involve adding a new key pair to a target computer or user account's `msDS-KeyCredentialLink` attribute.

### How it works
1. The attacker adds a new key pair to the target's `msDS-KeyCredentialLink`.
2. The attacker uses the private key to request a TGT for the target using PKINIT.
3. This allows the attacker to authenticate as the target.

### Example using Whisker

```powershell
# PowerShell (using Whisker)
.\Whisker.exe add /target:<TargetUser> /domain:<Domain> /dc:<DomainController>
```

### Example using Certipy

```bash
# Using Certipy
certipy shadow auto -username '<Username>' -password '<Password>' -target '<TargetUser>' -dc-ip '<DomainController>'
```

## Certificate Abuse

Certificates can be used for various attacks, including:
- **Authentication**: Using a certificate to authenticate as a specific user (e.g., Domain Admin).
- **Signing**: Using a certificate to sign malicious code or documents.
- **Encryption**: Using a certificate to encrypt sensitive data.

### Example using Certipy

```bash
# Using Certipy to authenticate using a certificate
certipy auth -pfx 'administrator.pfx' -dc-ip '<DomainController>'
```

## Mitigations

### Detection
- **Certificate Requests**: Monitor for unusual certificate requests, particularly for templates with high privileges.
- **CA Configuration**: Monitor for changes to the CA's configuration or certificate templates.
- **NTLM Relay**: Monitor for NTLM relay attacks to AD CS HTTP endpoints.

### Mitigation
- **Restrict Permissions**: Ensure that only authorized users and groups have access to sensitive certificate templates.
- **Enable SAN Restriction**: Configure certificate templates to reject requests with SANs that do not match the requester's identity.
- **Disable NTLM Relay**: Enforce SMB signing and disable NTLM authentication on AD CS HTTP endpoints.
- **Regular Audits**: Regularly audit AD CS configurations and certificate templates for vulnerabilities.

---
*AD CS attacks provide a powerful avenue for privilege escalation. The next chapter will explore delegation attacks, another critical area of Active Directory security.*
