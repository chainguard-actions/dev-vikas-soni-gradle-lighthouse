<!-- markdownlint-disable -->

# Hardening Report: dev-vikas-soni--gradle-lighthouse/v2.3.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **dev-vikas-soni--gradle-lighthouse/v2.3.2** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'Run Lighthouse Audit' step puts GitHub expressions straight into its run: script: `-Plighthouse.failOnSeverity=${{ inputs.fail-on-severity }}`, `-Plighthouse.baseReportDir=${{ inputs.base-report-path }}` and `${{ inputs.gradle-args }}`. These values are substituted into the bash script before it runs, so shell metacharacters in any input (for example `; curl ... `) would run as commands. Fix: move each input into the step's env: block and expand it double-quoted, e.g. "$FAIL_ON_SEVERITY".

Locations:

- `action.yml:76`
- `action.yml:77`
- `action.yml:78`

### unpinned-uses (severity: high)

These composite steps reference actions by mutable tags, not full 40-char commit SHAs: `uses: actions/github-script@v9` (line 34), `uses: github/codeql-action/upload-sarif@v4.37.3` (line 85), `uses: actions/github-script@v9` (line 104).

Locations:

- `action.yml:34`
- `action.yml:85`
- `action.yml:104`

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

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index c2397e7..882816c 100644
--- a/action.yml
+++ b/action.yml
@@ -3,7 +3,6 @@ description: 'Run Gradle Lighthouse audit and post results as PR comments + SARI
 branding:
   icon: 'zap'
   color: 'orange'
-
 inputs:
   gradle-args:
     description: 'Additional Gradle arguments'
@@ -25,13 +24,29 @@ inputs:
     description: 'Path to base reports for delta calculation (optional)'
     required: false
     default: '.lighthouse/base-reports'
-
 runs:
   using: 'composite'
   steps:
     - name: Download Base Reports (Main Branch)
       if: github.event_name == 'pull_request'
-      uses: actions/github-script@v9
+      uses: actions/github-script@3a2844b7e9c422d3c10d287c895573f7108da1b3 # v9
       with:
         script: |
           try {
@@ -68,25 +83,30 @@ runs:
           } catch (e) {
             console.log('Could not download base reports: ' + e.message);
           }
-
     - name: Run Lighthouse Audit
       shell: bash
+      env:
+        TERM: xterm-256color
+        INPUT_FAIL_ON_SEVERITY: ${{ inputs.fail-on-severity }}
+        INPUT_BASE_REPORT_PATH: ${{ inputs.base-report-path }}
+        INPUT_GRADLE_ARGS: ${{ inputs.gradle-args }}
       run: |
+        gradle_extra_args=()
+        if [ -n "$INPUT_GRADLE_ARGS" ]; then
+          while IFS= read -r -d '' t; do gradle_extra_args+=("$t"); done \
+            < <(printf '%s' "$INPUT_GRADLE_ARGS" | xargs printf '%s\0')
+        fi
         ./gradlew lighthouseAudit lighthouseAggregate \
-          -Plighthouse.failOnSeverity=${{ inputs.fail-on-severity }} \
-          -Plighthouse.baseReportDir=${{ inputs.base-report-path }} \
-          ${{ inputs.gradle-args }} \
+          "-Plighthouse.failOnSeverity=$INPUT_FAIL_ON_SEVERITY" \
+          "-Plighthouse.baseReportDir=$INPUT_BASE_REPORT_PATH" \
+          "${gradle_extra_args[@]}" \
           --no-daemon --stacktrace
-      env:
-        TERM: xterm-256color
-
     - name: Upload SARIF
       if: inputs.upload-sarif == 'true' && always()
-      uses: github/codeql-action/upload-sarif@v4.37.3
+      uses: github/codeql-action/upload-sarif@e4fba868fa4b1b91e1fdab776edc8cfbe6e9fb81 # v4.37.3
       with:
         sarif_file: build/reports/lighthouse/
         category: gradle-lighthouse
-
     - name: Find SARIF reports
       if: always()
       shell: bash
@@ -98,52 +118,8 @@ runs:
         # Extract score from root module report
         SCORE=$(grep -o '"score": [0-9]*' build/reports/lighthouse/module-report.json 2>/dev/null | head -1 | grep -o '[0-9]*' || echo "N/A")
         echo "score=$SCORE" >> $GITHUB_OUTPUT
-
     - name: PR Comment
       if: inputs.comment-on-pr == 'true' && github.event_name == 'pull_request' && always()
-      uses: actions/github-script@v9
+      uses: actions/github-script@3a2844b7e9c422d3c10d287c895573f7108da1b3 # v9
       with:
-        script: |
-          const fs = require('fs');
-          const summaryPath = 'build/reports/lighthouse/lighthouse-pr-summary.md';
-          let body = '';
-
-          if (fs.existsSync(summaryPath)) {
-            body = fs.readFileSync(summaryPath, 'utf8');
-          } else {
-            const score = '${{ steps.reports.outputs.score }}';
-            body = `## 🏗️ Gradle Lighthouse Report
-
-            | Metric | Value |
-            |--------|-------|
-            | **Health Score** | ${score}/100 |
-            | **Status** | ${parseInt(score) >= 70 ? '✅ Passing' : '⚠️ Needs attention'} |
-
-            > Full report available in the [Actions artifacts](${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}).
-            > SARIF results uploaded to the Security tab.`;
-          }
-
-          // Find existing comment
-          const { data: comments } = await github.rest.issues.listComments({
-            owner: context.repo.owner,
-            repo: context.repo.repo,
-            issue_number: context.issue.number,
-          });
-          const existing = comments.find(c => c.body.includes('Gradle Lighthouse Report'));
-
-          if (e
... (truncated)
```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, static-inline-injection, prior-fix

**Notes:**

Pinned actions/github-script@v9 (3a2844b7…) and github/codeql-action/upload-sarif@v4.37.3 (e4fba868…). Moved fail-on-severity, base-report-path and gradle-args into the env: of the 'Run Lighthouse Audit' step. The first two are now passed double-quoted. gradle-args used to be pasted straight into the script, so the shell honoured quotes in it; it is now split the same quote-aware way (xargs with an unmatched-quote check, -r, the built-in printf via sh -c) into an array before going to Gradle. Re-applied the earlier security changes to the github-script steps as well: github.workspace, inputs.base-report-path and steps.reports.outputs.score are now read through process.env and env:, not pasted into the JS. Not tested by running the action. One extra change: in the base-report download step I took out upstream's `require('@actions/exec')` and used the `exec` that github-script already provides.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Find SARIF reports' step of action.yml, sarif_files is now written as a multi-line value between heredoc delimiters. The delimiter is generated fresh from /dev/urandom on each run, so the list of paths keeps its line breaks and a path containing a newline can't add other outputs. The score value now has newlines stripped before it is written, and $GITHUB_OUTPUT is quoted. Nothing was run to test this.

