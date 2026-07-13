# Chapter 20: Checklists

Checklists are essential tools for penetration testers and red teamers to ensure comprehensive coverage during an assessment. They help organize tasks, track progress, and prevent critical steps from being overlooked. This chapter provides detailed checklists for various phases of an Active Directory engagement.

## AD Enumeration Checklist

- [ ] Identify the current domain and domain controllers.
- [ ] Enumerate trust relationships (internal and external).
- [ ] List all users and identify privileged accounts (Domain Admins, Enterprise Admins).
- [ ] Check user descriptions for sensitive information (e.g., passwords, notes).
- [ ] List all groups and check for nested groups (hidden privileges).
- [ ] Enumerate computers and identify servers (e.g., SQL, IIS, Exchange).
- [ ] Check network shares for sensitive data and accessible paths.
- [ ] Enumerate active sessions and logged-on users (targets for lateral movement).
- [ ] List Group Policy Objects (GPOs) and check for Group Policy Preferences (GPP) with passwords.
- [ ] Run BloodHound/SharpHound to collect data for graph analysis.
- [ ] Perform LDAP queries for advanced enumeration (e.g., finding users with specific attributes).

## Credential Attack Checklist

- [ ] Perform password spraying against the domain (use common passwords).
- [ ] Check for cached credentials on compromised machines.
- [ ] Dump LSASS memory to extract plaintext passwords, NTLM hashes, and Kerberos tickets.
- [ ] Dump the SAM database to extract local user NTLM hashes.
- [ ] Extract the NTDS.dit database (if Domain Admin access is achieved) to dump all domain hashes.
- [ ] Search local machines for hardcoded passwords in files, scripts, and registry keys.
- [ ] Use tools like Mimikatz, CrackMapExec, and Impacket for credential dumping and spraying.

## Kerberos Checklist

- [ ] Perform AS-REP Roasting to extract hashes for users without pre-authentication.
- [ ] Perform Kerberoasting to extract hashes for service accounts with SPNs.
- [ ] Check for unconstrained delegation and attempt to capture TGTs (e.g., using printerbug.py).
- [ ] Check for constrained delegation and attempt to impersonate users (e.g., using Rubeus).
- [ ] Check for Resource-Based Constrained Delegation (RBCD) and attempt to create a new computer account to exploit it.
- [ ] If KRBTGT hash is compromised, create a Golden Ticket for persistence.
- [ ] If service account hash is compromised, create a Silver Ticket for specific service access.

## NTLM Checklist

- [ ] Check for SMB signing enforcement on target servers (if disabled, SMB Relay is possible).
- [ ] Attempt NTLM Relay attacks (e.g., using Impacket ntlmrelayx.py) to LDAP, SMB, or HTTP targets.
- [ ] Perform Pass-the-Hash (PtH) attacks to authenticate to remote services using NTLM hashes.
- [ ] Attempt LLMNR and NBT-NS poisoning (e.g., using Responder or Inveigh) to capture NTLM hashes.
- [ ] Force NTLM authentication from high-privileged users to capture their hashes.

## Privilege Escalation Checklist

- [ ] Check for misconfigured permissions (e.g., WriteProperty, WriteMember) on sensitive objects.
- [ ] Check for unquoted service paths and weak service permissions.
- [ ] Check for weak registry permissions on services.
- [ ] Check for scheduled tasks that can be modified to run as SYSTEM.
- [ ] Check for weak ACLs on computers or users that allow delegation abuse.
- [ ] Check for GPOs that can be modified to apply malicious settings.
- [ ] Check for `SeImpersonatePrivilege` and attempt token impersonation (e.g., using PrintSpoofer or JuicyPotato).
- [ ] Check for Local Admin access and attempt LSASS dumping.

## Lateral Movement Checklist

- [ ] Use PsExec to execute commands on remote systems.
- [ ] Use WMI to execute commands on remote systems without creating services.
- [ ] Use WinRM to establish interactive shells on remote systems.
- [ ] Use SMB to copy malware or dump credentials from remote systems.
- [ ] Use RDP for graphical access to remote systems (if necessary).
- [ ] Use DCOM for remote execution on specific applications.
- [ ] Use Pass-the-Hash (PtH) to authenticate to remote services.
- [ ] Use Pass-the-Ticket to authenticate to remote services using Kerberos tickets.

## AD CS Checklist

- [ ] Enumerate Certificate Authorities (CAs) and certificate templates.
- [ ] Check for ESC1 (templates allowing SAN specification and authentication).
- [ ] Check for ESC2 (templates allowing "Any Purpose" usage).
- [ ] Check for ESC3 (templates allowing "Certificate Request Agent" usage).
- [ ] Check for ESC4 (vulnerable template ACLs allowing modification).
- [ ] Check for ESC5 (vulnerable PKI object ACLs).
- [ ] Check for ESC6 (CA configured to honor SANs regardless of template).
- [ ] Check for ESC7 (vulnerable CA ACLs allowing template management).
- [ ] Check for ESC8 (NTLM Relay to AD CS HTTP endpoints).
- [ ] Check for ESC9 (templates without security extensions).
- [ ] Check for ESC10 (weak certificate mapping).
- [ ] Attempt Shadow Credentials attacks (modifying `msDS-KeyCredentialLink`).

## Persistence Checklist

- [ ] Create Golden Tickets (if KRBTGT hash is available).
- [ ] Create Silver Tickets (if service account hashes are available).
- [ ] Modify AdminSDHolder ACLs to maintain access to protected groups.
- [ ] Create ACL backdoors on sensitive objects (e.g., Domain Admins group).
- [ ] Inject Skeleton Key into LSASS on Domain Controllers.
- [ ] Create or modify Malicious GPOs to execute persistent scripts/tasks.
- [ ] Add malicious Startup Scripts to compromised machines.
- [ ] Create malicious Scheduled Tasks to execute persistent scripts/tasks.
- [ ] Add Shadow Credentials to target accounts.

## Reporting Checklist

- [ ] Write a clear and concise Executive Summary for non-technical stakeholders.
- [ ] Document detailed Technical Findings for each vulnerability discovered.
- [ ] Include Proof of Concept (PoC) evidence (screenshots, command outputs, logs).
- [ ] Map out Attack Paths showing how vulnerabilities were chained together.
- [ ] Assign appropriate Risk Ratings (Critical, High, Medium, Low) to each finding.
- [ ] Calculate CVSS scores for vulnerabilities where applicable.
- [ ] Provide actionable Remediation recommendations for each finding.
- [ ] Include Appendices with supplementary information (scope, methodology, tools used).
- [ ] Review the report for clarity, accuracy, and professional tone before delivery.

## Internal Pentest Checklist

- [ ] Define the scope and objectives of the assessment.
- [ ] Obtain written authorization from the client.
- [ ] Perform reconnaissance and enumeration (AD Enumeration Checklist).
- [ ] Attempt initial access (Credential Attack Checklist, NTLM Checklist).
- [ ] Attempt privilege escalation (Privilege Escalation Checklist).
- [ ] Attempt lateral movement (Lateral Movement Checklist).
- [ ] Attempt advanced exploitation (Kerberos Checklist, AD CS Checklist).
- [ ] Establish persistence (Persistence Checklist).
- [ ] Document findings and evidence throughout the engagement.
- [ ] Clean up artifacts and restore systems to their original state (OpSec).
- [ ] Write and deliver the final report (Reporting Checklist).

---
*Checklists ensure that no critical step is missed during an assessment. The next chapter will provide a comprehensive guide to the tools used in Active Directory security.*
