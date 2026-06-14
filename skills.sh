#!/usr/bin/env bash

# Reinstall agent skills via the `skills` CLI (the open agent-skills ecosystem).
# Skills install once into ~/.agents/skills and symlink into each agent
# (Claude, Codex). Re-running is idempotent. Requires Node — provided by npm.sh
# (fnm), so this runs after that.

command -v fnm &>/dev/null && eval "$(fnm env)"

if ! command -v npx &>/dev/null; then
  echo "npx not found (is Node installed?) — skipping skills."
  exit 0
fi

# add <github-repo> <comma-separated-skill-names>
add() {
  npx --yes skills@latest add "$1" --skill "$2" --global --agent '*' --yes
}

add anthropics/skills                "mcp-builder,skill-creator"
add avdlee/swiftui-agent-skill       "swiftui-expert-skill"
add coreyhaines31/marketingskills    "copywriting"
add daymade/claude-code-skills       "macos-cleaner"
add dpearson2699/swift-ios-skills    "realitykit"
add ehmo/platform-design-skills      "macos-design-guidelines"
add mattpocock/skills                "grill-me"
add nextlevelbuilder/ui-ux-pro-max-skill "ui-ux-pro-max"
add phuryn/pm-skills                 "product-name"
add shadcn/improve                   "improve"
add shadcn/ui                        "shadcn"
add vercel-labs/skills               "find-skills"
add flutter/skills                   "flutter-add-integration-test,flutter-add-widget-preview,flutter-add-widget-test,flutter-apply-architecture-best-practices,flutter-build-responsive-layout,flutter-fix-layout-issues,flutter-implement-json-serialization,flutter-setup-declarative-routing,flutter-setup-localization,flutter-use-http-package"

# Personal/hand-authored skills live in their own private repo. Clone it if
# missing, then symlink each skill into both agents. (Clone needs GitHub auth —
# if it fails on a fresh machine, run `gh auth login` and re-run this script.)
PERSONAL_SKILLS_DIR="$HOME/code/other/skills"
PERSONAL_SKILLS_REPO="https://github.com/filipstefansson/skills.git"
if [ ! -d "$PERSONAL_SKILLS_DIR/.git" ]; then
  git clone "$PERSONAL_SKILLS_REPO" "$PERSONAL_SKILLS_DIR" ||
    echo "could not clone personal skills — skipping (try after 'gh auth login')."
fi
if [ -d "$PERSONAL_SKILLS_DIR" ]; then
  for skill in "$PERSONAL_SKILLS_DIR"/*/; do
    [ -f "${skill}SKILL.md" ] || continue
    name="$(basename "$skill")"
    for agent in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
      mkdir -p "$agent"
      ln -sfn "${skill%/}" "$agent/$name"
    done
  done
fi
