<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a), direct expression interpolation in a run: block of step 'Run Lighthouse Audit': `-Plighthouse.failOnSeverity=${{ inputs.fail-on-severity }} \` and `${{ inputs.gradle-args }} \`. These input values are pasted into the bash script before it runs, so an attacker-supplied value can inject shell commands. Fix: pass them through env: variables and quote the expansions. For an optional value forwarded as an argument, use the guarded form ${VAR:+"$VAR"}. gradle-args is meant to hold several arguments, so it needs a bash array or a safe way to split it.

Locations:

- `action.yml:32`
- `action.yml:33`

### unpinned-uses (severity: high)

Two uses: references point to version tags instead of full 40-character commit SHAs: `uses: github/codeql-action/upload-sarif@v4` (line 40) and `uses: actions/github-script@v9` (line 59).

Locations:

- `action.yml:40`
- `action.yml:59`

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

In the 'Run Lighthouse Audit' step, inputs.fail-on-severity and inputs.gradle-args now go through env: (INPUT_FAIL_ON_SEVERITY, INPUT_GRADLE_ARGS). fail-on-severity is passed as one quoted argument. gradle-args is split with the guarded, quote-aware xargs method, because upstream pasted the input straight into the script and the shell honored quotes in it. The xargs -r true check makes the step fail on an unmatched quote. The resulting array is expanded with ${args[@]+...} so it works on bash 3.2 too. Pinned github/codeql-action/upload-sarif to 9b3254085494b55a0f7c4c2b3d2d52cc712ce370 (v4) and actions/github-script to 3a2844b7e9c422d3c10d287c895573f7108da1b3 (v9).

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Repaired the damaged PR Comment `if:` condition back to `inputs.comment-on-pr == 'true' && github.event_name == 'pull_request' && always()`, and pinned actions/github-script to 3a2844b7e9c422d3c10d287c895573f7108da1b3 (v9, checked with lookup_action_sha). Also moved steps.reports.outputs.score out of the inline script and into env (LIGHTHOUSE_SCORE, read with process.env), so the step output is no longer pasted into the JS source.

