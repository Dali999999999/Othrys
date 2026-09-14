# Security Policy

The Othrys core engineering team takes the security of our desktop suite and the remote infrastructure it manages extremely seriously. We are committed to maintaining a robust, enterprise-grade security posture and handling vulnerabilities transparently and promptly.

---

## Supported Versions

Only the latest release branch of Othrys receives active security patches and updates.

| Version | Supported          | Security Status                                 |
| ------- | ------------------ | ----------------------------------------------- |
| 0.1.x   | :white_check_mark: | Active support (current release gate)           |
| < 0.1.0 | :x:                | Deprecated / Pre-release                        |

We strongly encourage all users to stay on the latest version of Othrys. Automated update notifications are delivered directly within the desktop application.

---

## Reporting a Vulnerability

If you believe you have discovered a security vulnerability in Othrys, please **do NOT report it through public GitHub issues or public discussions**.

Instead, please report security vulnerabilities responsibly using one of the following methods:

1. **GitHub Private Vulnerability Reporting** (Preferred):
   - Navigate to the [Security Advisories](https://github.com/Dali999999999/Othrys/security/advisories) tab of our repository.
   - Click **"Report a vulnerability"** to submit an encrypted, private report directly to the maintainers.

2. **Direct Security Email**:
   - Send an email to **security@othrys.dev** (or contact the repository maintainers directly on GitHub).
   - Please include:
     - A detailed description of the vulnerability.
     - Affected versions and environments (OS build, Flutter/Dart runtime).
     - Step-by-step reproduction steps or a minimal proof of concept (PoC).
     - Any proposed remediations or mitigations if available.

### Our Commitment
- **Initial Response**: We will acknowledge receipt of your vulnerability report within **48 hours**.
- **Assessment**: We will provide a preliminary assessment and validation within **5 business days**.
- **Fix & Disclosure**: We aim to produce and release a patch as quickly as possible. Once the patch is released, we will publish a coordinated advisory with public attribution to the reporter (unless anonymity is requested).

---

## Core Security Architecture & Guarantees

Othrys is built around zero-trust engineering principles for local infrastructure management:

### 1. Zero Remote Agent Architecture
Othrys communicates with remote machines strictly over native SSH (`RFC 4251` suite) and SFTP subsystems using `dartssh2`. No proprietary daemon, agent, or background service is installed on your remote server, eliminating remote attack surfaces.

### 2. Encryption at Rest (Client-Side Vault)
- Sensitive credentials (passwords, private SSH keys, passphrases) are encrypted using **AES-256-GCM** authenticated cipher.
- Master keys are derived with **PBKDF2** using **100,000 rounds** and cryptographically secure random salts generated via the operating system's CSPRNG.
- Storage is isolated within operating system-protected application directories.

### 3. Trust-On-First-Use (TOFU) Host Key Verification
- All SSH connections require cryptographic host key verification.
- On first connection, host key fingerprints (Ed25519, RSA, ECDSA) are verified and pinned in an encrypted `known_hosts` store.
- Any mismatch or unexpected host key change halts connection immediately to prevent Man-in-the-Middle (MITM) attacks.

### 4. Remote Command Sanitization
- Commands executed remotely (e.g., Docker commands, systemd controls) pass through strict input validation and argument sanitization (`CommandSanitizer`) to prevent shell escape sequences and injection attacks.

### 5. Silent Exception Prohibition
- Swallowing exceptions without trace is strictly forbidden across the codebase. All network, cryptographic, and filesystem failures are explicitly caught, logged via `AppLogger`, and returned as typed failures via the sealed `Result<T>` monad.

---

## Best Practices for End Users

To maximize the security of your managed infrastructure:
1. **Prefer Ed25519 or ECDSA SSH Keys**: Use modern key algorithms over legacy RSA keys.
2. **Protect Private Keys with Passphrases**: Ensure your local private keys are passphrase-protected.
3. **Use Dedicated Non-Root Users**: Connect to remote Linux machines as a standard user with restricted `sudo` privileges rather than direct `root` access.
4. **Keep Your Workstation Secure**: Ensure your host operating system is patched and free from malware.
