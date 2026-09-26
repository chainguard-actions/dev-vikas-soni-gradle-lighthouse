<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Two untrusted input expressions are interpolated directly inside a run: shell command string. On line 30, `${{ inputs.fail-on-severity }}` is embedded as a Gradle property value without quoting or env-var indirection, and on line 31, `${{ inputs.gradle-args }}` is passed directly as additional Gradle arguments. An attacker who controls these inputs (e.g. via workflow_dispatch or a calling workflow) can inject arbitrary shell metacharacters (`;`, `|`, `$(...)`, etc.) to execute arbitrary commands on the runner.

Locations:

- `action.yml:30`
- `action.yml:31`

### script-injection (severity: high)

Sub-rule (a): The expression `${{ steps.reports.outputs.score }}` is interpolated directly inside the `script:` value of the `actions/github-script` step (line 57). The value is embedded inside a JavaScript string literal (`const score = '${{ steps.reports.outputs.score }}'`). If the step output contains a single-quote or other JavaScript metacharacter, it can break out of the string and execute arbitrary JavaScript in the github-script context, which has access to the GitHub API token.

Locations:

- `action.yml:57`

### unpinned-uses (severity: high)

Two `uses:` references are pinned to mutable version tags rather than immutable 40-character commit SHA digests, making the action vulnerable to supply-chain attacks if the upstream tag is moved or the repository is compromised:
- `github/codeql-action/upload-sarif@v4` (line 37) — should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`
- `actions/github-script@v9` (line 55) — should be pinned to a full SHA, e.g. `actions/github-script@<40-char-sha> # v9`

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

Fixed all 5 findings in action.yml:
1. Moved `${{ inputs.fail-on-severity }}` to env var `INPUT_FAIL_ON_SEVERITY` and used it safely as `"-Plighthouse.failOnSeverity=$INPUT_FAIL_ON_SEVERITY"` in the run block.
2. Moved `${{ inputs.gradle-args }}` to env var `INPUT_GRADLE_ARGS` and used xargs-based bash array tokenization (`while IFS= read -r -d '' t; do extra_args+=("$t"); done < <(printf '%s' "$INPUT_GRADLE_ARGS" | xargs printf '%s\0')`) to safely expand the list-style input.
3. Moved `${{ steps.reports.outputs.score }}` to env var `LIGHTHOUSE_SCORE` on the github-script step and referenced it via `process.env.LIGHTHOUSE_SCORE` in the JavaScript, preventing JS string injection.
4. Pinned `github/codeql-action/upload-sarif@v4` → `@2892aa5e19bbd11bc0cff5427e3b750a04d9e3c2 # v4`.
5. Pinned `actions/github-script@v9` → `@3a2844b7e9c422d3c10d287c895573f7108da1b3 # v9`.

