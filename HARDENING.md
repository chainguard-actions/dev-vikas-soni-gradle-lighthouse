<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings. At line 30, `${{ inputs.fail-on-severity }}` is embedded directly in a Gradle command-line argument without quoting or env-var indirection, allowing an attacker to inject arbitrary shell content. At line 31, `${{ inputs.gradle-args }}` is similarly interpolated directly into the shell command, enabling full shell command injection via crafted Gradle arguments. At line 57, `${{ steps.reports.outputs.score }}` is interpolated directly into a JavaScript string inside the `actions/github-script` script block, which could allow JS injection if the score value is attacker-influenced.

Locations:

- `action.yml:30`
- `action.yml:31`
- `action.yml:57`

### unpinned-uses (severity: high)

Two `uses:` references in action.yml use mutable version tags instead of immutable full 40-character SHA digests, making the action vulnerable to supply-chain attacks if the upstream tag is moved or compromised. Failing references: `github/codeql-action/upload-sarif@v4` (line 37) and `actions/github-script@v9` (line 55). These should be pinned to their full commit SHAs, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:37`
- `action.yml:55`

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

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses

**Notes:**

Fixed all findings in action.yml:
1. Moved `${{ inputs.fail-on-severity }}` to env: block as FAIL_ON_SEVERITY; used as "-Plighthouse.failOnSeverity=$FAIL_ON_SEVERITY" in the shell command.
2. Moved `${{ inputs.gradle-args }}` to env: block as GRADLE_ARGS; tokenized via xargs into a bash array (with guard for empty value) to safely handle multi-word/quoted arguments.
3. Moved `${{ steps.reports.outputs.score }}` to env: block as LIGHTHOUSE_SCORE in the PR Comment step; referenced via `process.env.LIGHTHOUSE_SCORE` in the JavaScript script.
4. Pinned `github/codeql-action/upload-sarif@v4` to full SHA `24c54180a607b1449ed407dd24f251e4e9147c8d # v4`.
5. Pinned `actions/github-script@v9` to full SHA `3a2844b7e9c422d3c10d287c895573f7108da1b3 # v9`.

