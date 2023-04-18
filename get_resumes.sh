#!/bin/bash

SEARCH_URL='https://hh.ru/search/resume?label=only_with_salary&relocation=living_or_relocation&gender=unknown&text=github.com%2F.%2B&isDefaultArea=true&exp_period=all_time&logic=normal&pos=full_text&search_period=0&items_on_page=100&page='

export RESUME_URL='https://hh.ru/resume/'

get_resumes_from_page() {
    pagenum="$1"
    curl -s "$SEARCH_URL$pagenum" \
        | grep -Po '"resumes": \K\[.*\], "settings":' \
        | head -c -14 \
        | jq -r '@text "\(env.RESUME_URL)\(.[]._attributes.hash)"'
    # P.S. 14 in head is length of part from regex: ', "settings":'
    # P.P.S. there, in jq, we already have most of the metadata, but not all of
    # them, so we don't have fields which contains github links. So sad
}

# TODO: dirty hack, should retrieve and consider real pages count
seq 0 8 | while read -r page; do
    get_resumes_from_page $page
done
