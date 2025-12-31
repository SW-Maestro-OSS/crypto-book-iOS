
#!/usr/bin/env bash
set -e

echo "Running Claude..."
cat artifacts/gemini_output.md PROJECT.md CLAUDE.md | claude > artifacts/claude_review.md
echo "Claude review saved to artifacts/claude_review.md"
