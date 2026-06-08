#!/usr/bin/env bash
# Block destructive operations targeting ~/data, and tell the agent WHY.
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

DATA_DIR="$HOME/data"
EXPANDED=${CMD//\~\/data/$DATA_DIR}

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0   # exit 0, NOT 2 — the JSON is what blocks here
}

# Deletion / destructive verbs touching the data dir
if echo "$EXPANDED" | grep -Eq '(\brm\b|\brmdir\b|\bshred\b|\bunlink\b|\btrash\b|\btruncate\b|-delete\b)'; then
  if echo "$EXPANDED" | grep -qF "$DATA_DIR"; then
    deny "Blocked by user policy: files under $DATA_DIR are protected and must never be deleted by the agent. This is intentional, not an error. If the user truly wants this removed, they will do it themselves in their own terminal — do not retry, and tell them to do it manually."
  fi
fi

# Overwrites via redirection into the data dir
if echo "$EXPANDED" | grep -Eq ">[[:space:]]*${DATA_DIR}"; then
  deny "Blocked by user policy: overwriting files under $DATA_DIR is not allowed. This is intentional; do not retry."
fi

exit 0
