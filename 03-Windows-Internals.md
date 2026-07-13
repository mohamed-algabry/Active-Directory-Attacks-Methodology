# Chapter 3: Windows Internals

Understanding Windows Internals is crucial for penetration testers and red teamers. Active Directory does not operate in a vacuum; it relies on the underlying Windows operating system to process authentication requests, manage credentials, and enforce security policies. This chapter explores the core components of Windows that are directly relevant to AD security.

## LSASS (Local Security Authority Subsystem Service)

The Local Security Authority Subsystem Service (LSASS), running as `lsass.exe`, is a critical system process responsible for enforcing the security policy on the system.

### Role of LSASS
- **Authentication**: LSASS verifies user logons to the local computer or to the domain.
- **Credential Storage**: It manages the security tokens and, historically, stores cached credentials in memory.
- **Security Policy**: It enforces password policies and generates audit messages.

### LSASS Dumping
Because LSASS holds credentials in memory, it is the primary target for credential dumping attacks. Tools like Mimikatz and procdump are used to extract the memory of `lsass.exe` to recover plaintext passwords, NTLM hashes, and Kerberos tickets.

**PowerShell Example (Defensive Evasion):**
```powershell
# Dumping LSASS memory using a legit executable to avoid detection
rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump (Get-Process lsass).Id C:\Windows\Temp\lsass.dmp full
```

**Detection Note:** Dumping LSASS is a high-severity indicator of compromise. Windows Defender Credential Guard can mitigate this by isolating the secrets that allow users to log on in a virtualized container.

## SAM (Security Accounts Manager)

The Security Accounts Manager (SAM) is a database file that exists on local Windows machines (both domain-joined and standalone).

### SAM Database
- **Location**: `%SystemRoot%\System32\config\SAM`
- **Function**: It stores user accounts and security descriptors for users on the local computer.
- **Password Hashes**: The SAM database contains the NTLM hashes of local user passwords. These hashes are encrypted using the system's boot key (Syskey).

### SAM Dumping
Local administrators can dump the SAM database to extract local user password hashes. This is often done using tools like `reg.exe` or `secretsdump.py`.

**PowerShell Example:**
```powershell
# Save SAM, SYSTEM, and SECURITY hives
reg save hklm\sam C:\temp\sam.hive
reg save hklm\system C:\temp\system.hive
reg save hklm\security C:\temp\security.hive
```

## Registry

The Windows Registry is a hierarchical database that stores low-level settings for the Microsoft Windows operating system and for applications that opt to use the registry.

### Security-Relevant Keys
- **HKLM\SYSTEM\CurrentControlSet\Control\Lsa**: Contains security settings like `restrictanonymous` (limits anonymous access) and `nolmhash` (prevents storing LM hashes).
- **HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon**: Contains cached credential count settings (`CachedLogonsCount`).

### Registry Persistence
Attackers often use the registry to establish persistence, such as adding new entries to `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`.

## Tokens and Privileges

Windows uses access tokens to define the security context of a process or thread.

### Access Tokens
- **Primary Token**: Associated with a process when it is created.
- **Impersonation Token**: Associated with a thread when it impersonates a client.

### Privileges
Tokens contain a list of privileges granted to the user. Some highly dangerous privileges include:
- **SeDebugPrivilege**: Allows a process to inspect the memory of other processes (used for LSASS dumping).
- **SeImpersonatePrivilege**: Allows a process to impersonate a client (used for token impersonation attacks, e.g., Juicy Potato, PrintSpoofer).
- **SeTcbPrivilege**: Allows a process to act as part of the operating system (used for generating Golden Tickets).

## Security Identifiers (SIDs)

A Security Identifier (SID) is a unique value of variable length used to identify a security principal or security group in Windows operating systems.

### SID Structure
SIDs consist of the SID version number, a 48-bit identifier authority, and a variable number of relative identifiers (RIDs).
- **Format**: `S-1-5-21-<DomainID>-<RID>`
- **Well-known SIDs**:
  - `S-1-5-18`: Local System
  - `S-1-5-19`: NT Authority
  - `S-1-5-20`: Network Service
  - `S-1-5-21-...-500`: Built-in Administrator
  - `S-1-5-21-...-512`: Domain Admins

## Windows Authentication

When a user logs on to a Windows system, the Local Security Authority (LSA) validates the credentials.

### Interactive Logon
1. The user enters their credentials.
2. The LSA hashes the password (using MD4 for NTLM, or other algorithms for Kerberos).
3. If local, it compares the hash to the one in the SAM.
4. If domain-joined, it sends the credentials to a Domain Controller.

### Service Logon
Services run under specific accounts. If the password is stored in plaintext in a configuration file or registry key, it can be easily harvested.

## Memory Concepts

Understanding how Windows manages memory is vital for attacks like process injection and hollowing.

### Virtual Memory
Windows uses virtual memory to manage physical RAM. Each process has its own virtual address space.

### Process Injection
Attackers inject malicious code into the address space of a legitimate process to evade detection.
- **Remote Thread Creation**: Creating a new thread in a remote process that executes shellcode.
- **Process Hollowing**: Creating a suspended process, replacing its memory with malicious code, and resuming it.

## Practical Examples

### Checking Current Privileges

```powershell
whoami /priv
```

### Dumping Local SAM Hashes with CrackMapExec

```bash
# Using Impacket secretsdump or CrackMapExec
crackmapexec smb 192.168.1.10 -u Administrator -p 'password' --sam
```

### Identifying LSASS Protection

Check if Credential Guard is enabled:

```powershell
Get-ComputerInfo | Select-Object DeviceGuardSecurityServicesRunning
```

---
*Understanding Windows Internals provides the necessary context for how credentials are managed and how processes interact with the OS. The next chapter will focus on how to enumerate Active Directory using this knowledge.*
