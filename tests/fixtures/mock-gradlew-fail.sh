#!/bin/bash
# Mock gradlew script that simulates a build failure
echo "Mock Gradle: simulating build failure"
echo "$@" > /tmp/gradle-args-captured.txt

# Create partial output before failing
mkdir -p "$GITHUB_WORKSPACE/build/reports/lighthouse"

cat > "$GITHUB_WORKSPACE/build/reports/lighthouse/module-report.json" << 'JSON_EOF'
{
  "score": 45,
  "categories": {}
}
JSON_EOF

echo "BUILD FAILED"
exit 1
