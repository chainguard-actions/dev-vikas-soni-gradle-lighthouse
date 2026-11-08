<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): the 'Run Lighthouse Audit' step puts GitHub expressions straight into a run: script: `-Plighthouse.failOnSeverity=${{ inputs.fail-on-severity }} \` and `${{ inputs.gradle-args }} \`. Whoever calls the action controls these input values, so they can inject shell commands. Pass them in through env: variables and quote them when the shell expands them.

Locations:

- `action.yml:32`
- `action.yml:33`

### unpinned-uses (severity: high)

Two uses: refs point at mutable tags instead of 40-char commit SHAs: `uses: github/codeql-action/upload-sarif@v4` (line 40) and `uses: actions/github-script@v9` (line 58).

Locations:

- `action.yml:40`
- `action.yml:58`

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

All changes are in action.yml. Nothing was run to test them.

- **Script injection (`Run Lighthouse Audit` step):** The `fail-on-severity` and `gradle-args` inputs no longer go straight into the `run:` script. They now come in through `env:` as `INPUT_FAIL_ON_SEVERITY` and `INPUT_GRADLE_ARGS`.
  - `fail-on-severity` is a single value, passed quoted as `"-Plighthouse.failOnSeverity=$INPUT_FAIL_ON_SEVERITY"`.
  - `gradle-args` is a list of arguments. It is split into an array the same way the shell split it before, respecting quotes, using `xargs` (an unmatched quote now fails the step). The split only runs when the input is non-empty, and the result is passed as `"${args[@]}"`. Nothing in the value gets run as a command.
- **Unpinned actions:** `github/codeql-action/upload-sarif` is pinned to `33d7b85da1a04171e211befe2c739303b9a4c066` (v4) and `actions/github-script` to `3a2844b7e9c422d3c10d287c895573f7108da1b3` (v9).
- **Extra change, not in the findings:** the PR comment script used to paste the step output `steps.reports.outputs.score` directly into its JavaScript. It now reads it from `process.env.LIGHTHOUSE_SCORE` instead.

