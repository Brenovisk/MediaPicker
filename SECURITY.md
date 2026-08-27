# Security Policy

## Supported versions

MediaPicker is still in early development and has not published its first
tagged release. Security fixes are applied to the latest revision of the
default development branch. After releases begin, this section will identify
the versions that receive security updates.

## Reporting a vulnerability

Do not disclose a suspected vulnerability in a public issue, pull request,
discussion, commit, or log. Report it privately through
[GitHub Security Advisories](https://github.com/Brenovisk/MediaPicker/security/advisories/new).

Include enough information to reproduce and assess the report safely:

- the affected MediaPicker version or commit;
- the affected iOS, Swift, and Xcode versions;
- the security impact and the conditions required to trigger it;
- minimal reproduction steps or a small sample project;
- relevant sanitized logs, stack traces, or screenshots;
- any known workaround or suggested remediation.

Remove credentials, private media, personal information, and unrelated
application data before submitting the report.

The maintainer will acknowledge the report through the private advisory,
evaluate its severity and scope, and coordinate remediation and disclosure with
the reporter. Please keep details confidential until a fix or an agreed
disclosure plan is available. Reports that are not security-sensitive may be
redirected to the public issue tracker.

## Security expectations for contributions

Contributions must not commit secrets, signing material, provisioning profiles,
private media, local paths, or user data. Handle camera, microphone, and photo
library permissions only when required by the active flow, and avoid exposing
sensitive values in logs or errors. Follow the review and validation standards
in [CONTRIBUTING.md](CONTRIBUTING.md).
