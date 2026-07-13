# Chapter 18: Reporting

Reporting is a critical component of any penetration test or red team operation. A well-written report communicates the findings, risks, and recommendations to the client or stakeholders, enabling them to understand the security posture and take appropriate remediation actions.

## Executive Summary

The Executive Summary is the first section of the report and is intended for non-technical stakeholders (e.g., C-suite executives, managers). It provides a high-level overview of the assessment, the key findings, and the overall risk level.

### Key Elements
- **Scope**: Briefly describe the scope of the assessment (e.g., internal network, specific domains).
- **Objective**: State the goal of the assessment (e.g., identify vulnerabilities, test detection capabilities).
- **Summary of Findings**: Summarize the most critical findings and their potential impact.
- **Overall Risk Rating**: Provide an overall risk rating (e.g., High, Medium, Low) based on the findings.

### Example Executive Summary

> **Executive Summary**
>
> This report details the findings of an internal penetration test conducted on the Active Directory environment of Contoso Corp. The objective of the assessment was to identify security weaknesses and evaluate the effectiveness of existing security controls.
>
> The assessment revealed several critical vulnerabilities, including misconfigured service accounts, unconstrained delegation, and vulnerable Certificate Services (AD CS). These vulnerabilities allowed the penetration testing team to escalate privileges from a standard user to Domain Admin within a short timeframe.
>
> **Overall Risk Rating: High**
>
> Immediate remediation is recommended to address the critical findings and reduce the risk of a successful cyber attack.

## Technical Findings

The Technical Findings section provides detailed information about each vulnerability discovered during the assessment. It is intended for technical stakeholders (e.g., system administrators, security engineers).

### Key Elements for Each Finding
- **Title**: A clear and descriptive title for the vulnerability.
- **Description**: A detailed description of the vulnerability, including how it was discovered and exploited.
- **Impact**: The potential impact of the vulnerability if exploited by a malicious actor.
- **Proof of Concept (PoC)**: Evidence of the vulnerability, including screenshots, command outputs, and logs.
- **Risk Rating**: The risk rating of the vulnerability (e.g., Critical, High, Medium, Low).
- **Remediation**: Specific recommendations for fixing the vulnerability.

### Example Technical Finding

> **Title: Unconstrained Delegation on Domain Controller**
>
> **Description:**
> The Domain Controller (DC01) was found to have unconstrained delegation enabled. This allows any user who authenticates to DC01 to have their Ticket Granting Ticket (TGT) cached in memory.
>
> **Impact:**
> An attacker who compromises DC01 can extract the cached TGTs and impersonate the users to access other services in the domain. If a Domain Admin authenticates to DC01, the attacker can extract their TGT and gain full control of the domain.
>
> **Proof of Concept:**
> ```text
> mimikatz # sekurlsa::tickets /export
> ```
> *Screenshot of Mimikatz extracting TGTs*
>
> **Risk Rating: Critical**
>
> **Remediation:**
> Disable unconstrained delegation on DC01 and ensure that only authorized services have delegation enabled.

## Attack Paths

The Attack Paths section visualizes how the attacker moved through the network to achieve their objectives. This helps stakeholders understand the sequence of events and the dependencies between vulnerabilities.

### Key Elements
- **Diagram**: A visual representation of the attack path (e.g., using BloodHound or flowcharts).
- **Description**: A step-by-step description of the attack path, including the techniques used at each step.

### Example Attack Path

> **Attack Path: From Standard User to Domain Admin**
>
> 1. **Initial Access**: The attacker gained initial access to a standard user account (User A) via a phishing email.
> 2. **Enumeration**: The attacker used PowerView to enumerate the domain and discovered that User A had write access to a Group Policy Object (GPO 1).
> 3. **Privilege Escalation**: The attacker modified GPO 1 to include a malicious scheduled task that executes when computers in the "Servers" OU reboot.
> 4. **Lateral Movement**: The malicious task executed on a Domain Controller (DC01) with SYSTEM privileges.
> 5. **Credential Theft**: The attacker dumped the LSASS memory on DC01 and extracted the KRBTGT hash.
> 6. **Persistence**: The attacker used the KRBTGT hash to create a Golden Ticket, granting them persistent Domain Admin access.
>
> *Diagram showing the attack path*

## Evidence

The Evidence section provides the raw data and artifacts collected during the assessment. This is crucial for validating the findings and demonstrating the impact.

### Key Elements
- **Screenshots**: Screenshots of tools, commands, and results.
- **Command Outputs**: Textual outputs of commands executed during the assessment.
- **Logs**: Relevant log entries (e.g., Windows Event Logs, Sysmon logs).
- **Files**: Extracted files (e.g., dumped hashes, forged tickets).

### Example Evidence

> **Evidence for Unconstrained Delegation**
>
> *Screenshot of PowerView command showing DC01 has unconstrained delegation enabled*
> ```powershell
> Get-DomainComputer -Unconstrained -Properties dnshostname
> ```
> *Output showing DC01*
>
> *Screenshot of Mimikatz command dumping tickets from DC01*
> ```text
> mimikatz # sekurlsa::tickets /export
> ```
> *Output showing exported tickets*

## Risk Rating

Risk rating is the process of evaluating the severity of a vulnerability based on its likelihood of exploitation and potential impact.

### Common Risk Rating Scales
- **Critical**: Immediate exploitation is likely, and the impact is catastrophic (e.g., full domain compromise).
- **High**: Exploitation is likely, and the impact is severe (e.g., access to sensitive data).
- **Medium**: Exploitation is possible, and the impact is moderate (e.g., access to non-sensitive data).
- **Low**: Exploitation is unlikely, and the impact is minor (e.g., information disclosure).

## CVSS (Common Vulnerability Scoring System)

CVSS is a standardized framework for rating the severity of security vulnerabilities. It provides a numerical score (0.0 to 10.0) based on various metrics (e.g., attack vector, complexity, privileges required, impact).

### Example CVSS Score

> **CVSS Score: 9.8 (Critical)**
>
> - **Attack Vector**: Network
> - **Attack Complexity**: Low
> - **Privileges Required**: None
> - **User Interaction**: None
> - **Scope**: Changed
> - **Confidentiality Impact**: High
> - **Integrity Impact**: High
> - **Availability Impact**: High

## Remediation

The Remediation section provides actionable recommendations for fixing the identified vulnerabilities. It should be tailored to the specific environment and include both immediate and long-term solutions.

### Key Elements
- **Immediate Actions**: Steps to be taken immediately to mitigate the risk (e.g., disable a vulnerable service, reset a password).
- **Long-term Solutions**: Strategic changes to improve the overall security posture (e.g., implement tiering, enforce MFA).
- **Resources**: Links to documentation, guides, or tools that can assist with remediation.

### Example Remediation

> **Remediation for Unconstrained Delegation**
>
> **Immediate Action:**
> Disable unconstrained delegation on DC01 by unchecking the "Trust this computer for delegation to any service (Kerberos only)" option in the computer account properties.
>
> **Long-term Solution:**
> Implement constrained delegation for services that require delegation. Ensure that only authorized services have delegation enabled.
>
> **Resource:**
> [Microsoft Documentation on Constrained Delegation](https://learn.microsoft.com/en-us/windows-server/security/kerberos/kerberos-constrained-delegation-overview)

## Appendices

The Appendices section contains supplementary information that supports the report but is not essential for the main narrative.

### Common Appendices
- **Scope Details**: Detailed description of the scope (e.g., IP ranges, domains, excluded assets).
- **Methodology**: Detailed description of the methodology used during the assessment.
- **Tools Used**: List of tools used during the assessment.
- **Timeline**: Timeline of the assessment activities.
- **Glossary**: Definitions of technical terms used in the report.

## Professional Templates

Using professional templates ensures that the report is well-structured, consistent, and easy to read.

### Key Elements of a Professional Template
- **Cover Page**: Includes the title, date, and author.
- **Table of Contents**: Provides a quick reference to the different sections.
- **Consistent Formatting**: Uses consistent fonts, headings, and styles throughout the report.
- **Clear Language**: Uses clear and concise language, avoiding jargon where possible.

---
*Reporting is the final step in translating technical findings into actionable business intelligence. The next chapter will provide practical labs to help you practice the techniques discussed in this repository.*
