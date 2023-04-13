#!/bin/bash

URL="$1"

# format:
# source,salary,currency,github,title,area,gender,age,experience,skills

curl -s  "$URL" \
    | grep -Po '"resume": \K{.*}, "resumeIdsProfTestAttached":' \
    | head -c -31 \
    | jq '{salary: .salary.value,
        git: [.skills.value,
              .keySkills.value[].string,
              .attestationEducation.value[][],
              .experience.value[].prettyUrl,
              .experience.value[].description
             ] | join(" "),
        title: .title.value,
        area: .area.value.title,
        gender: .gender.value,
        age: .age.value,
        experience: [.totalExperience[]],
        skills: [.keySkills.value[].string]}' \
    | sed -E 's/("git": ").*(github.com\/[[:alnum:]-]+).*/\1\2",/I'

# P.S. 31 in head is length of part from regex: ', "resumeIdsProfTestAttached":'

# TODO: one resume can have multiple github links

# TODO: bug: some resumes have github link inside some not yet handled fields.
# For example, "portfolio" probably can have it too
