<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Run Lighthouse Audit' step directly interpolates ${{ inputs.fail-on-severity }} and ${{ inputs.gradle-args }} inside a run: shell command. These user-controlled inputs go through YAML template substitution before the shell processes them, enabling command injection (e.g., a value like `; malicious-command` would be executed). They must be passed via env: variables and then referenced as quoted shell variables instead.

Locations:

- `action.yml:33`

### script-injection (severity: high)

Sub-rule (a): The 'PR Comment' step (using actions/github-script) directly interpolates ${{ steps.reports.outputs.score }} inside the script: block. The step output value flows through YAML template substitution before the JavaScript is evaluated, which can allow injection of arbitrary JavaScript if the score value is attacker-influenced. It should be passed via an env: variable and read as process.env.SCORE inside the script.

Locations:

- `action.yml:62`

### unpinned-uses (severity: high)

Two uses: references are pinned to mutable version tags rather than immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks if those tags are moved: (1) github/codeql-action/upload-sarif@v4 — should be pinned to a full SHA digest; (2) actions/github-script@v9 — should be pinned to a full SHA digest.

Locations:

- `action.yml:41`
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

Fixed all findings in action.yml:
1. script-injection/static-inline-injection (Run Lighthouse Audit): Moved ${{ inputs.fail-on-severity }} and ${{ inputs.gradle-args }} to env: block as FAIL_ON_SEVERITY and GRADLE_ARGS. FAIL_ON_SEVERITY is used as a single quoted value; GRADLE_ARGS (list-style input) is tokenized via xargs into a bash array and expanded safely.
2. script-injection (PR Comment / actions/github-script): Moved ${{ steps.reports.outputs.score }} to the step's env: block as SCORE, read in JavaScript via process.env.SCORE.
3. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to SHA 6f2ac81f5cd81fe351a197ba0b00d91d03cd2aee and actions/github-script@v9 to SHA 3a2844b7e9c422d3c10d287c895573f7108da1b3.

