#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

# jq filter to extract streaming text from assistant messages
stream_text='select(.type == "assistant").message.content[]? | select(.type == "text").text // empty | gsub("\n"; "\r\n") | . + "\r\n\n"'

# jq filter to extract final result
final_result='select(.type == "result").result // empty'

for ((i=1; i<=$1; i++)); do
  tmpfile=$(mktemp)
  trap "rm -f $tmpfile" EXIT

  commits=$(git log -n 5 --format="%H%n%ad%n%B---" --date=short 2>/dev/null || echo "No commits found")
  issues=$(cat issues/*.md 2>/dev/null || echo "No issues found")
  prompt=$(cat ralph/prompt.md)

  copilot \
    -p "$(printf '# Issues\n\n%s\n\n# Previous Commits\n\n%s\n\n%s' "$issues" "$commits" "$prompt")" \
    --model claude-sonnet-4.6 \
    --effort medium \
    --output-format json \
    --allow-all-tools \
    --no-ask-user \
    --log-level debug \
    --log-dir "$SCRIPT_DIR/logs" \
    --deny-tool='shell(git push)' \
    --deny-tool='shell(git reset)' \
    --deny-tool='shell(git rebase)' \
    --deny-tool='shell(git clean)' \
  | grep --line-buffered '^{' \
  | tee "$tmpfile" \
  | jq --unbuffered -rj "$stream_text"

  result=$(jq -r "$final_result" "$tmpfile")

  if [[ "$result" == *"<promise>NO MORE TASKS</promise>"* ]]; then
    echo "Ralph complete after $i iterations."
    exit 0
  fi
done
