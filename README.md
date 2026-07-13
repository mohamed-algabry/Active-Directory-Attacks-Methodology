# Active Directory Attacks Methodology

This repository is a complete knowledge base and practical methodology for Active Directory Attacks, Internal Penetration Testing, Red Team Operations, Windows Domain Security, Privilege Escalation, Lateral Movement, and Active Directory Exploitation.

It is designed for penetration testers, red teamers, security researchers, SOC analysts, blue teamers, students, and security engineers.

## 📖 Project Description

Active Directory (AD) is the backbone of most enterprise networks. Understanding how AD works, how it can be exploited, and how to defend against attacks is crucial for any cybersecurity professional. This repository provides a comprehensive, deep-dive methodology that goes beyond simple cheat sheets, offering detailed explanations, practical examples, and real-world attack scenarios.

## 🎯 Objectives

- To provide a structured, step-by-step methodology for Active Directory penetration testing and red team operations.
- To offer deep theoretical explanations of AD components, authentication protocols, and Windows internals.
- To present practical, hands-on examples using PowerShell, C#, Python, and common security tools.
- To bridge the gap between offensive techniques and defensive strategies.
- To serve as a comprehensive reference guide for security assessments.

## ✨ Features

- **Comprehensive Coverage**: From basic AD fundamentals to advanced exploitation techniques like Kerberoasting, AS-REP Roasting, Golden Tickets, and AD CS attacks.
- **Practical Examples**: Every concept is backed by PowerShell, CMD, C#, or Python examples.
- **Visual Learning**: Includes Mermaid diagrams, ASCII flowcharts, and detailed attack path illustrations.
- **Defensive Focus**: Every attack technique includes corresponding detection methods and mitigation strategies.
- **Real-World Scenarios**: Attack chains and realistic enterprise attack paths are discussed.
- **Hands-On Labs**: Includes a dedicated section for practical labs to practice techniques in a safe environment.
- **Professional Reporting**: Guidelines and templates for writing high-quality penetration testing reports.

## 📂 Repository Structure

```
Active-Directory-Attacks-Methodology/
├── 01-Introduction.md
├── 02-Active-Directory-Fundamentals.md
├── 03-Windows-Internals.md
├── 04-AD-Enumeration.md
├── 05-Credential-Attacks.md
├── 06-Authentication-Protocols.md
├── 07-Kerberos-Attacks.md
├── 08-NTLM-Attacks.md
├── 09-Privilege-Escalation.md
├── 10-Lateral-Movement.md
├── 11-AD-CS-Attacks.md
├── 12-Delegation-Attacks.md
├── 13-Trust-Attacks.md
├── 14-Persistence.md
├── 15-Defensive-Evasion.md
├── 16-BloodHound.md
├── 17-Detection-and-Defense.md
├── 18-Reporting.md
├── 19-Practical-Labs.md
├── 20-Checklists.md
├── 21-Tools.md
├── 22-Resources.md
├── assets/
│   ├── diagrams/
│   └── images/
├── cheatsheets/
├── labs/
├── references/
├── reports/
└── scripts/
```

## 🗺️ Learning Roadmap

1. **Foundations**: Start with [Introduction](01-Introduction.md), [Active Directory Fundamentals](02-Active-Directory-Fundamentals.md), and [Windows Internals](03-Windows-Internals.md).
2. **Reconnaissance**: Move to [AD Enumeration](04-AD-Enumeration.md) and learn how to map the domain.
3. **Initial Access & Escalation**: Study [Credential Attacks](05-Credential-Attacks.md) and [Privilege Escalation](09-Privilege-Escalation.md).
4. **Core Exploitation**: Dive deep into [Authentication Protocols](06-Authentication-Protocols.md), [Kerberos Attacks](07-Kerberos-Attacks.md), and [NTLM Attacks](08-NTLM-Attacks.md).
5. **Advanced Techniques**: Explore [AD CS Attacks](11-AD-CS-Attacks.md), [Delegation Attacks](12-Delegation-Attacks.md), and [Trust Attacks](13-Trust-Attacks.md).
6. **Operations & Evasion**: Learn about [Lateral Movement](10-Lateral-Movement.md), [Persistence](14-Persistence.md), and [Defensive Evasion](15-Defensive-Evasion.md).
7. **Tools & Analysis**: Master [BloodHound](16-BloodHound.md) and explore the [Tools](21-Tools.md) section.
8. **Defense & Reporting**: Understand [Detection and Defense](17-Detection-and-Defense.md) and how to write professional reports with the [Reporting](18-Reporting.md) guide.
9. **Practice**: Use the [Checklists](20-Checklists.md) during assessments and build your own lab using the [Practical Labs](19-Practical-Labs.md).

## 🛠️ Methodology Overview

The methodology follows a structured approach aligned with the MITRE ATT&CK framework:

1. **Reconnaissance**: Gathering information about the domain structure, users, groups, and policies.
2. **Initial Access**: Gaining a foothold in the network, often through phishing or credential attacks.
3. **Execution & Privilege Escalation**: Running malicious code and elevating privileges within the domain.
4. **Persistence**: Establishing backdoors to maintain access even if the initial entry point is lost.
5. **Lateral Movement**: Moving from the initial compromised host to other systems and the Domain Controller.
6. **Collection & Exfiltration**: Gathering sensitive data and preparing for exfiltration.
7. **Defense & Mitigation**: Understanding how to detect, respond to, and prevent these attacks.

## 🧰 Tools

This repository heavily utilizes and demonstrates the usage of industry-standard tools, including:
- **BloodHound / SharpHound**: For graph-based AD analysis.
- **Mimikatz**: For credential dumping and Kerberos attacks.
- **Rubeus**: For Kerberos interaction and abuse.
- **Impacket**: A suite of Python classes for working with network protocols.
- **PowerView**: For granular Active Directory network enumeration using PowerShell.
- **Responder / Inveigh**: For LLMNR/NBT-NS poisoning and NTLM relay attacks.
- **Certipy**: For certificate abuse and AD CS attacks.
- **CrackMapExec / NetExec**: For network enumeration and lateral movement.

## 🎓 Skills Required

To effectively use this repository, a basic understanding of the following is recommended:
- Windows Operating System fundamentals.
- Basic Networking concepts (TCP/IP, DNS, HTTP).
- Command-line interfaces (CMD, PowerShell).
- Basic scripting knowledge (PowerShell, Python, or C#).

## 🚀 Learning Path

1. **Beginner**: Read chapters 01-03 and set up a basic AD lab.
2. **Intermediate**: Work through chapters 04-08 and practice enumeration and basic credential attacks.
3. **Advanced**: Tackle chapters 09-14, focusing on exploitation, lateral movement, and persistence.
4. **Expert**: Master chapters 15-17, focusing on evasion, advanced analysis with BloodHound, and building robust detection rules.

## ⚠️ Disclaimer

**ALL CONTENT IN THIS REPOSITORY IS INTENDED FOR AUTHORIZED SECURITY ASSESSMENTS, RED TEAM ENGAGEMENTS, LAB ENVIRONMENTS, AND EDUCATIONAL PURPOSES ONLY.**

The author and contributors assume no liability for any misuse of the information, tools, or scripts provided herein. Unauthorized access to computer systems is illegal and unethical. Always ensure you have explicit, written permission before conducting any security assessments.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Mohamed Algabry**

## 🤝 Contributing

Contributions are welcome! If you find errors, have suggestions for improvement, or want to add new techniques, please open an issue or submit a pull request.

## 📚 References

A comprehensive list of references, research papers, and resources is available in the [Resources](22-Resources.md) chapter.

---
*This repository is a living document and will be continuously updated with new techniques and defenses.*
