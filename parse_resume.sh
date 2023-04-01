#!/bin/bash

URL="$1"

curl -s  "$URL" \
    | grep -Po '"resume": \K{.*}, "resumeIdsProfTestAttached":' \
    | head -c -31 \
    | jq '{salary: .salary.value, git: [.skills.value, .experience.value[].description] | join(" "), skills: [.keySkills.value[].string] | join(";")}' \
    | sed -E 's/("git": ").*(github.com\/[[:alnum:]\-]+).*/\1\2",/' \
    | jq -r '[.. | if type != "object" then . else empty end] | join(",")'

# last jq is finally to flatten all

# P.S. 31 in head is length of part from regex: ', "resumeIdsProfTestAttached":'

# format:
# salary,currency,skills,github,source
