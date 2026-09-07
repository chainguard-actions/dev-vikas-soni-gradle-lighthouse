<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.3.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.3.2** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Run Lighthouse Audit' run: block directly interpolates user-controlled inputs into the shell command string without routing them through env: variables first. Specifically, ${{ inputs.fail-on-severity }}, ${{ inputs.base-report-path }}, and ${{ inputs.gradle-args }} are embedded directly in the bash script, allowing an attacker who controls these inputs to inject arbitrary shell commands. Sub-rule (a): direct expression interpolation in run: block.

Locations:

- `action.yml:72`

### unpinned-uses (severity: high)

Multiple uses: references are pinned to mutable tags or version strings rather than immutable 40-character SHA digests, making the action vulnerable to supply-chain attacks if those tags are moved. Failing references in action.yml: actions/github-script@v9 (line ~28), github/codeql-action/upload-sarif@v4.37.3 (line ~83), actions/github-script@v9 (line ~97). Failing references in lighthouse-ci.yml: actions/checkout@v7, actions/setup-java@v5.6.0, gradle/actions/setup-gradle@v6 (multiple). Failing references in publish-plugin.yml: actions/checkout@v7, actions/setup-java@v5.6.0, gradle/actions/wrapper-validation@v6, gradle/actions/setup-gradle@v6. Failing references in qodana_code_quality.yml: actions/checkout@v4, JetBrains/qodana-action@v2026.1.

Locations:

- `action.yml:28`
- `action.yml:83`
- `action.yml:97`
- `.github/workflows/lighthouse-ci.yml:13`
- `.github/workflows/lighthouse-ci.yml:16`
- `.github/workflows/lighthouse-ci.yml:20`
- `.github/workflows/lighthouse-ci.yml:31`
- `.github/workflows/lighthouse-ci.yml:34`
- `.github/workflows/lighthouse-ci.yml:38`
- `.github/workflows/publish-plugin.yml:11`
- `.github/workflows/publish-plugin.yml:14`
- `.github/workflows/publish-plugin.yml:20`
- `.github/workflows/publish-plugin.yml:23`
- `.github/workflows/qodana_code_quality.yml:19`
- `.github/workflows/qodana_code_quality.yml:22`

### missing-permissions (severity: medium)

The workflow file lighthouse-ci.yml has no top-level permissions: key and neither the 'build' nor 'publish' jobs define job-level permissions. This means the GITHUB_TOKEN is granted its default (broad) permissions for all jobs in the workflow.

Locations:

- `.github/workflows/lighthouse-ci.yml:1`

### missing-permissions (severity: medium)

The workflow file publish-plugin.yml has no top-level permissions: key and the 'publish' job has no job-level permissions block. This means the GITHUB_TOKEN is granted its default (broad) permissions.

Locations:

- `.github/workflows/publish-plugin.yml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on-severity }}" appears directly in run: block of step "Run Lighthouse Audit"; move to env: map

Locations:

- `action.yml:76`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.base-report-path }}" appears directly in run: block of step "Run Lighthouse Audit"; move to env: map

Locations:

- `action.yml:77`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.gradle-args }}" appears directly in run: block of step "Run Lighthouse Audit"; move to env: map

Locations:

- `action.yml:78`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all findings across action.yml and three workflow files:

1. script-injection/static-inline-injection (action.yml): Moved ${{ inputs.fail-on-severity }}, ${{ inputs.base-report-path }}, and ${{ inputs.gradle-args }} from the run: block into the step's env: map. gradle-args (a list input) is tokenized with xargs into a bash array to preserve argument boundaries.

2. unpinned-uses (action.yml): Pinned actions/github-script@v9 (×2) and github/codeql-action/upload-sarif@v4.37.3 to full commit SHAs.

3. unpinned-uses (lighthouse-ci.yml): Pinned actions/checkout@v7, actions/setup-java@v5.6.0, and gradle/actions/setup-gradle@v6 (×2 each) to full commit SHAs.

4. unpinned-uses (publish-plugin.yml): Pinned actions/checkout@v7, actions/setup-java@v5.6.0, gradle/actions/wrapper-validation@v6, and gradle/actions/setup-gradle@v6 to full commit SHAs.

5. unpinned-uses (qodana_code_quality.yml): Pinned actions/checkout@v4 and JetBrains/qodana-action@v2026.1 to full commit SHAs.

6. missing-permissions (lighthouse-ci.yml): Added top-level permissions: contents: read and per-job permissions: contents: read to both build and publish jobs.

7. missing-permissions (publish-plugin.yml): Added top-level permissions: contents: read and job-level permissions: contents: read to the publish job.

