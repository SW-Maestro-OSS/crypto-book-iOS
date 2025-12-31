
#!/usr/bin/env bash
set -e

echo "Running Gemini..."
cat TASK.md PROJECT.md GEMINI.md | gemini > artifacts/gemini_output.md
echo "Gemini output saved to artifacts/gemini_output.md"
