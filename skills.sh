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
