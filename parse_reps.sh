#!/bin/bash

while IFS= read -r line; do 
    HASH=$(echo $line | jq -r '.id');

    touch ./diffs/$HASH;

    URLS=( $(echo $line | jq -r '.github | join("\n")') );
    for repo in ${URLS[@]}; do 
        # clone only .git folder and one branch only
        git clone $repo ./tmp --single-branch --no-tags --bare; 
        cd ./tmp;

        # get an array of all commits id and reverse it
        HISTORY=( $(git log --pretty=format:"%h") );
        HISTORY=( $(printf '%s\n' "${HISTORY[@]}" | tac | tr '\n' ' '; echo) );

        for commit in ${HISTORY[@]}; do
            git show $cur_commit >> ../diffs/$HASH;
        done;

        rm -rf *;

        cd ..;
    done;
done < $1;
