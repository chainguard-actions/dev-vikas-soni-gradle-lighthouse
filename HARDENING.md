<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.1.1** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Run Lighthouse Audit' step puts GitHub Actions expressions straight into the run: script: `-Plighthouse.failOnSeverity=${{ inputs.fail-on-severity }} \` and `${{ inputs.gradle-args }} \`. Both values are inserted into the script text before bash parses it, so input containing shell metacharacters (;, |, $(...)) runs as commands. Fix: move each input into an env: variable. Quote the failOnSeverity one ("$FAIL_ON_SEVERITY"). gradle-args is meant to be a list split on whitespace, so expand it as an array (ARGS=($GRADLE_ARGS)) with a '# shellcheck disable=SC2206' directive, then pass "${ARGS[@]}".

Locations:

- `action.yml:32`
- `action.yml:33`

### unpinned-uses (severity: high)

action.yml references actions by mutable tags instead of full 40-character commit SHAs: `uses: github/codeql-action/upload-sarif@v4` and `uses: actions/github-script@v9`. Pin each one to a commit SHA and keep the tag in a trailing comment.

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

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index 93be39b..ffa6104 100644
--- a/action.yml
+++ b/action.yml
@@ -25,19 +25,44 @@ inputs:
 runs:
   using: 'composite'
   steps:
     - name: Run Lighthouse Audit
       shell: bash
       run: |
+        args=()
+        if [ -n "$INPUT_GRADLE_ARGS" ]; then
+          printf '%s' "$INPUT_GRADLE_ARGS" | xargs -r true >/dev/null   # fails on an unmatched quote
+          while IFS= read -r -d '' t; do args+=("$t"); done \
+            < <(printf '%s' "$INPUT_GRADLE_ARGS" | xargs -r sh -c 'printf "%s\0" "$@"' sh)
+        fi
         ./gradlew lighthouseAudit lighthouseAggregate \
-          -Plighthouse.failOnSeverity=${{ inputs.fail-on-severity }} \
-          ${{ inputs.gradle-args }} \
+          "-Plighthouse.failOnSeverity=$INPUT_FAIL_ON_SEVERITY" \
+          "${args[@]}" \
           --no-daemon --stacktrace
       env:
         TERM: xterm-256color
+        INPUT_FAIL_ON_SEVERITY: ${{ inputs.fail-on-severity }}
+        INPUT_GRADLE_ARGS: ${{ inputs.gradle-args }}
 
     - name: Upload SARIF
       if: inputs.upload-sarif == 'true' && always()
       uses: github/codeql-action/upload-sarif@v4
       with:
         sarif_file: build/reports/lighthouse/
         category: gradle-lighthouse
@@ -56,10 +81,12 @@ runs:
 
     - name: PR Comment
       if: inputs.comment-on-pr == 'true' && github.event_name == 'pull_request' && always()
       uses: actions/github-script@v9
+      env:
+        LIGHTHOUSE_SCORE: ${{ steps.reports.outputs.score }}
       with:
         script: |
-          const score = '${{ steps.reports.outputs.score }}';
+          const score = process.env.LIGHTHOUSE_SCORE || '';
           const body = `## 🏗️ Gradle Lighthouse Report
 
           | Metric | Value |

```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses, prior-fix

**Notes:**

Moved inputs.fail-on-severity and inputs.gradle-args out of the run: script into env. fail-on-severity is now passed quoted. gradle-args is split into a bash array with the quote-aware xargs method, guarded for an empty value. I used this instead of the suggested ARGS=($GRADLE_ARGS) because upstream pasted the input straight into the script, so the shell honoured quotes inside it, and the xargs split keeps that behaviour. Pinned github/codeql-action/upload-sarif to 33d7b85da1a04171e211befe2c739303b9a4c066 (# v4) and actions/github-script to 3a2844b7e9c422d3c10d287c895573f7108da1b3 (# v9). Re-applied the earlier fix to the github-script step: steps.reports.outputs.score now comes in through env LIGHTHOUSE_SCORE and is read with process.env, instead of being pasted into the JS.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Find SARIF reports' step of action.yml, REPORT_FILES (which can hold several lines) is now written to $GITHUB_OUTPUT as a heredoc block whose delimiter is random on each run, taken from /dev/urandom via od. The list keeps one file per line, and a file name containing newlines can no longer add its own outputs. Upstream's single-line 'sarif_files=...' write could not handle more than one report anyway. I also quoted "$GITHUB_OUTPUT" on both writes. The SCORE write was already safe and is otherwise unchanged. I didn't run the action after the edit.

