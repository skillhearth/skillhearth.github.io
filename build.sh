#!/usr/bin/env bash
# Regenerates index.html from src/index.template.html.
# Paid buttons stay disabled ("Coming soon") unless a link is provided:
#   STRIPE_LINK_JOB_TAILOR='https://buy.stripe.com/...' \
#   STRIPE_LINK_DEBT_PLANNER='https://buy.stripe.com/...' ./build.sh
set -euo pipefail
shopt -u patsub_replacement 2>/dev/null || true
cd "$(dirname "$0")"

button() { # $1 = url (may be empty)
  local url="$1"
  if [ -z "$url" ]; then
    printf '<span class="btn" role="link" aria-disabled="true">Coming soon</span>'
  else
    case "$url" in
      https://*[\"\'\<\>\ ]*) echo "Invalid link (forbidden characters)" >&2; exit 1;;
      https://*) ;;
      *) echo "Link must start with https://" >&2; exit 1;;
    esac
    local esc="${url//&/&amp;}"
    printf '<a class="btn" href="%s" rel="noopener">Buy &ndash; one-time payment</a>' "$esc"
  fi
}

tpl=$(<src/index.template.html)
tpl="${tpl//<!--BUTTON_JOB_TAILOR-->/$(button "${STRIPE_LINK_JOB_TAILOR:-}")}"
tpl="${tpl//<!--BUTTON_DEBT_PLANNER-->/$(button "${STRIPE_LINK_DEBT_PLANNER:-}")}"
printf '%s\n' "$tpl" > index.html
st() { if [ -n "$1" ]; then echo "link set"; else echo "disabled"; fi; }
echo "index.html generated (job-tailor: $(st "${STRIPE_LINK_JOB_TAILOR:-}"); debt-planner: $(st "${STRIPE_LINK_DEBT_PLANNER:-}"))"
