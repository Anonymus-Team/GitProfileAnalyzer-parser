#!/bin/bash

SEARCH_URL='https://dubna.hh.ru/search/resume?text=github.com%2F.%2B&area=1&ored_clusters=true&order_by=relevance&search_period=0&logic=normal&pos=full_text&exp_period=all_time&label=only_with_salary&items_on_page=100&page='

export RESUME_URL='https://dubna.hh.ru/resume/'

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

get_resumes_from_page 0
get_resumes_from_page 1
