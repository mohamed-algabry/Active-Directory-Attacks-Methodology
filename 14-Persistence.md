# Chapter 14: Persistence

Persistence in Active Directory refers to techniques used by attackers to maintain access to the network even if their initial foothold is discovered and remediated. These techniques often involve creating backdoors, modifying configurations, or stealing credentials that allow for long-term access.

## Golden Tickets

A Golden Ticket is a forged Ticket Granting Ticket (TGT) created by an attacker who has compromised the KRBTGT account's NTLM hash.

### How it works
- The attacker uses the KRBTGT hash to create a valid TGT for any user, with any privileges (e.g., Domain Admin).
- The ticket can be set to have a long lifetime (e.g., 10 years), providing persistent access.
- Even if the attacker's initial access is revoked, they can continue to use the Golden Ticket to authenticate to services.

### Example using Mimikatz

```text
# Mimikatz (requires KRBTGT hash and Domain SID)
mimikatz # kerberos::golden /user:<Username> /domain:<Domain> /sid:<DomainSID> /krbtgt:<KRBTGT_Hash> /id:500 /ptt
```

### Mitigation
- **Reset KRBTGT Password**: Reset the KRBTGT account password twice to invalidate all existing Golden Tickets.
- **Monitor TGT Lifetime**: Look for TGTs with unusually long lifetimes.

## Silver Tickets

A Silver Ticket is a forged Service Ticket (ST) created by an attacker who has compromised a specific service account's NTLM hash.

### How it works
- The attacker uses the service account's hash to create a valid ST for a specific service (e.g., CIFS, HTTP, MSSQL).
- The ticket allows the attacker to access the service without interacting with the Domain Controller.
- The ticket can be set to have a long lifetime, providing persistent access to the specific service.

### Example using Mimikatz

```text
# Mimikatz (requires service account hash and Domain SID)
mimikatz # kerberos::golden /user:<Username> /domain:<Domain> /sid:<DomainSID> /target:<TargetServer> /service:cifs /rc4:<ServiceHash> /ptt
```

### Mitigation
- **Rotate Service Account Passwords**: Regularly change the passwords of service accounts to invalidate existing Silver Tickets.
- **Monitor ST Usage**: Look for unusual ST usage, particularly for services that are not frequently accessed.

## AdminSDHolder

The AdminSDHolder is a special container in Active Directory that holds the Access Control List (ACL) for protected groups (e.g., Domain Admins, Enterprise Admins).

### How it works
- The SDProp process (Security Descriptor Propagator) runs periodically (default is 60 minutes) on the PDC Emulator.
- It compares the ACL of protected groups with the ACL of the AdminSDHolder container.
- If the ACLs do not match, SDProp overwrites the group's ACL with the AdminSDHolder ACL.
- An attacker can modify the AdminSDHolder ACL to grant themselves persistent access to protected groups.

### Example using PowerView

```powershell
# PowerShell (using PowerView)
Add-ObjectACL -TargetIdentity 'CN=AdminSDHolder,CN=System,DC=contoso,DC=com' -PrincipalIdentity <AttackerUser> -Rights WriteProperty
```

### Mitigation
- **Monitor AdminSDHolder ACL**: Regularly audit the ACL of the AdminSDHolder container for unauthorized modifications.
- **Disable SDProp (Not Recommended)**: Disabling SDProp is generally not recommended as it weakens the security of protected groups.

## ACL Backdoors

ACL backdoors involve modifying the Access Control Lists (ACLs) of sensitive objects (e.g., users, groups, computers) to grant persistent access.

### How it works
- The attacker modifies the DACL of a sensitive object to allow a specific user or group to perform privileged actions (e.g., modify group membership, change passwords).
- Even if the attacker's initial access is revoked, they can use the backdoor to regain access.

### Example using PowerView

```powershell
# PowerShell (using PowerView)
Add-ObjectACL -TargetIdentity "Domain Admins" -PrincipalIdentity <AttackerUser> -Rights WriteProperty
```

### Mitigation
- **Regular ACL Audits**: Regularly audit the ACLs of sensitive objects for unauthorized modifications.
- **Restrict ACL Modification**: Ensure that only authorized users and groups have permission to modify the ACLs of sensitive objects.

## Skeleton Key

The Skeleton Key attack involves injecting a backdoor into the LSASS process on a Domain Controller, allowing any user to authenticate using a master password (the skeleton key) in addition to their real password.

### How it works
- The attacker injects a malicious module into the LSASS process on the Domain Controller.
- The module intercepts authentication requests and allows any user to authenticate using the master password.
- This provides persistent access to all user accounts in the domain.

### Example using Mimikatz

```text
# Mimikatz (requires Domain Admin privileges on DC)
mimikatz # privilege::debug
mimikatz # misc::skeleton
```

### Mitigation
- **Monitor LSASS**: Look for unusual modules loaded into the LSASS process.
- **Protect DCs**: Ensure that Domain Controllers are heavily monitored and protected.

## Malicious GPOs

Malicious Group Policy Objects (GPOs) can be used to apply persistent settings across the domain.

### How it works
- The attacker creates or modifies a GPO to include malicious settings (e.g., scheduled tasks, startup scripts, registry modifications).
- The GPO is linked to an Organizational Unit (OU) containing target computers or users.
- The settings are applied periodically, ensuring persistence.

### Example using PowerView

```powershell
# PowerShell (using PowerView)
New-GPOImmediateTask -TaskName "Persistence" -Command "C:\temp\malicious.exe" -GPOName "MaliciousGPO"
```

### Mitigation
- **Monitor GPO Changes**: Look for new GPOs or modifications to existing GPOs.
- **Restrict GPO Creation**: Ensure that only authorized users and groups have permission to create or modify GPOs.

## Startup Scripts

Startup scripts are executed when a computer boots up. They can be used to establish persistence.

### How it works
- The attacker adds a malicious script to the startup folder or configures a GPO to execute a script at startup.
- The script is executed every time the computer boots up, ensuring persistence.

### Example using PowerShell

```powershell
# PowerShell
Copy-Item "C:\temp\malicious.exe" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
```

### Mitigation
- **Monitor Startup Items**: Look for unusual items in the startup folder or registry run keys.
- **Restrict Startup Folder Access**: Ensure that only authorized users have write access to the startup folder.

## Scheduled Tasks

Scheduled tasks are executed at specific times or intervals. They can be used to establish persistence.

### How it works
- The attacker creates a scheduled task that executes a malicious executable or script.
- The task is configured to run periodically or at specific times, ensuring persistence.

### Example using PowerShell

```powershell
# PowerShell
$Action = New-ScheduledTaskAction -Execute "C:\temp\malicious.exe"
$Trigger = New-ScheduledTaskTrigger -Daily -At 9am
Register-ScheduledTask -TaskName "Persistence" -Action $Action -Trigger $Trigger -RunLevel Highest -User "SYSTEM"
```

### Mitigation
- **Monitor Scheduled Tasks**: Look for new scheduled tasks or modifications to existing tasks.
- **Restrict Task Creation**: Ensure that only authorized users have permission to create or modify scheduled tasks.

## Shadow Credentials

Shadow Credentials involve adding a new key pair to a target computer or user account's `msDS-KeyCredentialLink` attribute.

### How it works
- The attacker adds a new key pair to the target's `msDS-KeyCredentialLink`.
- The attacker uses the private key to request a TGT for the target using PKINIT.
- This provides persistent access to the target account, even if the password is changed.

### Example using Certipy

```bash
# Using Certipy
certipy shadow auto -username '<Username>' -password '<Password>' -target '<TargetUser>' -dc-ip '<DomainController>'
```

### Mitigation
- **Monitor KeyCredentialLink**: Look for modifications to the `msDS-KeyCredentialLink` attribute.
- **Restrict Attribute Modification**: Ensure that only authorized users have permission to modify the `msDS-KeyCredentialLink` attribute.

---
*Persistence ensures that the attacker remains in the network even if their initial access is detected. The next chapter will explore defensive evasion techniques, which help attackers avoid detection.*
