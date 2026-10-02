# Security policy

## Supported versions

Only the latest release receives security fixes.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability. Use GitHub's private
security advisory flow for this repository:

`Security > Advisories > New draft security advisory`

Include the affected version, reproduction steps, impact, and any proposed
mitigation. Avoid including device serial numbers, credentials, or unrelated
system logs.

This app requires Input Monitoring and Accessibility because it reads the
XENEON HID reports and injects corrected pointer events. It does not require
root access, a kernel extension, disabled SIP, or network access.
