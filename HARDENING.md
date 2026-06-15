<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Two untrusted input expressions are interpolated directly into a run: shell command in the 'Run Lighthouse Audit' step. `${{ inputs.fail-on-severity }}` is passed as a Gradle property value and `${{ inputs.gradle-args }}` is passed as raw additional arguments — both are expanded by the YAML template engine before the shell ever sees them, allowing an attacker to inject arbitrary shell commands via these inputs. Offending lines:
  `-Plighthouse.failOnSeverity=${{ inputs.fail-on-severity }}`
  `${{ inputs.gradle-args }}`

Locations:

- `action.yml:30`
- `action.yml:31`

### script-injection (severity: high)

Sub-rule (a): `${{ steps.reports.outputs.score }}` is interpolated directly into the `script:` block of the `actions/github-script` step ('PR Comment'). The score value originates from a prior run: step's GITHUB_OUTPUT write and is injected into JavaScript source code without quoting or sanitization. A malicious value containing backticks, quotes, or semicolons could break out of the string literal and execute arbitrary JavaScript in the actions/github-script context. Offending line:
  `const score = '${{ steps.reports.outputs.score }}';`

Locations:

- `action.yml:57`

### github-env-injection (severity: high)

The 'Find SARIF reports' step writes `$REPORT_FILES` (the output of `find`, which may include attacker-influenced filenames containing newlines) to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A filename containing a newline could inject additional key=value pairs into GITHUB_OUTPUT, poisoning subsequent steps. Offending line:
  `echo "sarif_files=$REPORT_FILES" >> $GITHUB_OUTPUT`

Locations:

- `action.yml:43`

### unpinned-uses (severity: high)

Two `uses:` references in action.yml use mutable version tags instead of pinned 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the referenced tag is moved or the repository is compromised:
  - `uses: github/codeql-action/upload-sarif@v4`
  - `uses: actions/github-script@v9`

Locations:

- `action.yml:38`
- `action.yml:53`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.fail-on-severity }}" appears directly in run: block of step "Run Lighthouse Audit"; move to env: map

Locations:

- `action.yml:32`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.gradle-args }}" appears directly in run: block of step "Run Lighthouse Audit"; move to env: map

Locations:

- `action.yml:33`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all 6 findings in action.yml:
1. script-injection/static-inline-injection: Moved inputs.fail-on-severity and inputs.gradle-args from run: block to env: block (as FAIL_ON_SEVERITY and GRADLE_ARGS). Used ${GRADLE_ARGS:+"$GRADLE_ARGS"} for the optional gradle-args to avoid passing an empty argument.
2. script-injection: Moved steps.reports.outputs.score from the github-script script: block to the step's env: block as LIGHTHOUSE_SCORE, accessed via process.env.LIGHTHOUSE_SCORE in JavaScript.
3. github-env-injection: Added printf '%s' ... | tr -d '\n\r' sanitization for both REPORT_FILES and SCORE before writing to $GITHUB_OUTPUT.
4. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to SHA 8aad20d150bbac5944a9f9d289da16a4b0d87c1e and actions/github-script@v9 to SHA 3a2844b7e9c422d3c10d287c895573f7108da1b3.

