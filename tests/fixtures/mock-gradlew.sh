#!/bin/bash
# Mock gradlew script for testing
echo "Mock Gradle: running $@"
# Record args for inspection
echo "$@" > /tmp/gradle-args-captured.txt

# Create expected report directories and files
mkdir -p "$GITHUB_WORKSPACE/build/reports/lighthouse"

# Create a minimal SARIF file matching '*-report.sarif' pattern
cat > "$GITHUB_WORKSPACE/build/reports/lighthouse/module-report.sarif" << 'SARIF_EOF'
{
  "version": "2.1.0",
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "Gradle Lighthouse",
          "rules": []
        }
      },
      "results": []
    }
  ]
}
SARIF_EOF

# Create a minimal JSON report with score
cat > "$GITHUB_WORKSPACE/build/reports/lighthouse/module-report.json" << 'JSON_EOF'
{
  "score": 85,
  "categories": {}
}
JSON_EOF

echo "Mock Gradle completed successfully"
exit 0
