#!/bin/bash

URL='https://dubna.hh.ru/search/resume?text=github&area=1&ored_clusters=true&order_by=relevance&search_period=0&logic=normal&pos=full_text&exp_period=all_time&label=only_with_salary&page='

get_resumes_from_page() {
    pagenum="$1"
    curl -s "$URL$pagenum" \
        | grep -Po 'href="\K/resume/.*?\?query=' \
        | awk '{printf "https://hh.ru" substr($1, 1, length($1)-7) "\n"}'
    # P.S. 7 in awk substr is length of regexp part "?query="
}

get_resumes_from_page 1
get_resumes_from_page 2
