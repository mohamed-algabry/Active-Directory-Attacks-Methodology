# Chapter 17: Detection and Defense

While understanding offensive techniques is crucial for red teamers and penetration testers, defensive strategies are equally important for blue teams and security analysts. This chapter explores how to detect, respond to, and mitigate the Active Directory attacks discussed in previous chapters.

## Monitoring

Effective monitoring is the foundation of a strong defense. It involves collecting and analyzing data from various sources to identify suspicious activities.

### Key Monitoring Sources
- **Windows Event Logs**: Capture system, security, and application events.
- **Sysmon**: A system service and device driver that logs system activity to the Windows event log.
- **Network Traffic**: Analyze network packets for anomalous behavior or known attack patterns.
- **Endpoint Detection and Response (EDR)**: Monitor endpoint activities, process behaviors, and file system changes.
- **Active Directory Audit Policies**: Enable specific audit policies to track changes to AD objects.

## Event IDs

Specific Windows Event IDs are strong indicators of Active Directory attacks.

### Authentication and Logon Events
- **Event ID 4624**: Successful logon. Look for Logon Type 3 (Network) or 10 (RDP) from unexpected sources.
- **Event ID 4625**: Failed logon. Multiple failures from a single source may indicate brute force or password spraying.
- **Event ID 4648**: Logon using explicit credentials. Indicates a user is attempting to log on with different credentials (e.g., Pass-the-Hash, PsExec).

### Kerberos Events
- **Event ID 4768**: A Kerberos authentication ticket (TGT) was requested. Look for AS-REQ without pre-authentication (AS-REP Roasting).
- **Event ID 4769**: A Kerberos service ticket was requested. Look for TGS-REQ for SPNs (Kerberoasting) or S4U2Self/S4U2Proxy (delegation attacks).
- **Event ID 4771**: Kerberos pre-authentication failed. Indicates incorrect password attempts.

### AD Object Modification Events
- **Event ID 4720**: A user account was created. Look for accounts created with excessive privileges.
- **Event ID 4726**: A user account was deleted.
- **Event ID 4728**: A member was added to a security-enabled global group. Look for additions to Domain Admins.
- **Event ID 4732**: A member was added to a security-enabled local group. Look for additions to local administrators.
- **Event ID 5136**: A directory service object was modified. Indicates changes to AD objects (e.g., ACLs, GPOs).

### LSASS and Credential Dumping
- **Event ID 10 (Sysmon)**: Process Access. Look for `SourceImage` accessing `TargetImage` (`lsass.exe`) with `GrantedAccess` `0x1FFFFF`.

## SIEM Integration

Security Information and Event Management (SIEM) systems aggregate logs from various sources and provide centralized monitoring, correlation, and alerting.

### How SIEM Helps
- **Log Aggregation**: Collects logs from Domain Controllers, endpoints, and network devices.
- **Correlation**: Correlates events across different sources to identify complex attack patterns.
- **Alerting**: Generates alerts based on predefined rules or anomalies.
- **Visualization**: Provides dashboards and visualizations for monitoring the security posture.

## Detection Rules

Detection rules are used by SIEMs and EDRs to identify specific attack techniques.

### Example: Detecting Pass-the-Hash

```json
{
  "rule_name": "Pass_the_Hash_Attempt",
  "description": "Detects attempts to authenticate using Pass-the-Hash",
  "condition": "EventID == 4624 AND LogonType == 3 AND AuthenticationPackageName == 'NTLM' AND LogonProcessName == 'Advapi' AND TargetUserName != 'ANONYMOUS LOGON'",
  "severity": "High"
}
```

### Example: Detecting Golden Ticket

```json
{
  "rule_name": "Golden_Ticket_Usage",
  "description": "Detects potential usage of a forged Golden Ticket",
  "condition": "EventID == 4768 AND TicketOptions contains '0x40810000' AND TicketEncryptionType == '0x17' AND AccountName != 'krbtgt'",
  "severity": "Critical"
}
```

## Hardening

Hardening involves configuring systems to reduce their attack surface and make them more resistant to attacks.

### Key Hardening Steps
- **Disable Unnecessary Services**: Disable services that are not required to reduce the attack surface.
- **Patch Management**: Regularly apply security patches to operating systems and applications.
- **Least Privilege**: Grant users and services only the minimum privileges necessary to perform their tasks.
- **Network Segmentation**: Segment the network to limit lateral movement.

## Tiering

Tiering is a security model that organizes assets and identities into different tiers based on their sensitivity and criticality.

### Tier Model
- **Tier 0**: Assets that can fully control the Active Directory forest (e.g., Domain Controllers, PKI infrastructure).
- **Tier 1**: Assets that control applications and servers (e.g., application servers, database servers).
- **Tier 2**: Assets that control user workstations (e.g., user workstations).

### Benefits of Tiering
- **Isolation**: Prevents high-privileged accounts from being used on lower-tier assets, reducing the risk of credential theft.
- **Strict Access Control**: Enforces strict access controls between tiers.

## Least Privilege

The principle of least privilege states that users and services should only be granted the minimum privileges necessary to perform their tasks.

### Implementation
- **Role-Based Access Control (RBAC)**: Assign privileges based on roles rather than individual users.
- **Just-In-Time (JIT) Access**: Grant elevated privileges only when needed and for a limited time.
- **Regular Audits**: Regularly review and revoke unnecessary privileges.

## Credential Protection

Credential protection involves safeguarding credentials from theft and misuse.

### Techniques
- **Strong Password Policies**: Enforce complex passwords and regular rotation.
- **Multi-Factor Authentication (MFA)**: Require MFA for accessing sensitive resources.
- **Credential Guard**: Use Windows Defender Credential Guard to isolate secrets in a virtualized container.

## Protected Users

The Protected Users group is a security group in Active Directory that provides additional protection for high-privileged accounts.

### Benefits
- **Prevents NTLM Authentication**: Members cannot authenticate using NTLM.
- **Prevents Credential Caching**: Credentials are not cached locally.
- **Prevents Delegation**: Members cannot be delegated to other services.
- **Prevents Kerberos Deskey**: Kerberos tickets are not encrypted with the user's DES key.

## LAPS (Local Administrator Password Solution)

LAPS is a Microsoft tool that manages the local administrator password for each domain-joined computer.

### Benefits
- **Unique Passwords**: Each computer has a unique, complex local administrator password.
- **Automatic Rotation**: Passwords are rotated automatically based on a configurable policy.
- **Secure Storage**: Passwords are stored securely in Active Directory and are only accessible to authorized users.

## Windows Defender and Microsoft Defender for Identity

Windows Defender and Microsoft Defender for Identity (formerly Azure ATP) provide advanced threat protection for Active Directory environments.

### Windows Defender
- **Real-time Protection**: Scans files and processes in real-time for malware.
- **Behavioral Monitoring**: Monitors system behavior for anomalous activities.

### Microsoft Defender for Identity
- **Identity Monitoring**: Monitors identity-related activities for signs of compromise.
- **Threat Detection**: Detects known attack techniques (e.g., Golden Ticket, DCSync).
- **Vulnerability Assessment**: Identifies security weaknesses in the Active Directory configuration.

## Practical Examples

### Enabling Audit Policies

```cmd
# Command Prompt
auditpol /set /subcategory:"Credential Validation" /success:enable /failure:enable
auditpol /set /subcategory:"Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Computer Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Group Membership" /success:enable /failure:enable
```

### Configuring Sysmon

```xml
<!-- Sysmon Configuration (sysmonconfig.xml) -->
<Sysmon schemaversion="4.22">
  <EventFiltering>
    <!-- Log all process creations -->
    <ProcessCreate onmatch="include"/>
    <!-- Log network connections -->
    <NetworkConnect onmatch="include"/>
    <!-- Log process access (for LSASS dumping) -->
    <ProcessAccess onmatch="include">
      <TargetImage condition="contains">lsass.exe</TargetImage>
    </ProcessAccess>
  </EventFiltering>
</Sysmon>
```

---
*Detection and defense are the final line of protection against Active Directory attacks. The next chapter will explore how to effectively report security findings to stakeholders.*
