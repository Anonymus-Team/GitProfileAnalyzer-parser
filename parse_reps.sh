#!/bin/bash

CURRENT_FOLDER=$(pwd)
DATA=$(pwd)/$1
DIFFS_FOLDER=$(pwd)/diffs
TMP_FOLDER=/tmp/GitProfileAnalyzer
mkdir $TMP_FOLDER;

cd $TMP_FOLDER;

while IFS= read -r line; do 
    HASH=$(echo $line | jq -r '.id');

    GHPNICK=$(echo $line | jq -r '.ghpNick')

    touch $DIFFS_FOLDER/$HASH;

    URLS=( $(echo $line | jq -r '.github | join("\n")') );
    for repo in ${URLS[@]}; do 
        # clone only .git folder and one branch only
        git clone $repo $TMP_FOLDER --single-branch --no-tags --bare; 

        # get an array of all commits id and reverse it
        HISTORY=( $(git log --pretty=format:"%h" --author=$GHPNICK) );
        HISTORY=( $(printf '%s\n' "${HISTORY[@]}" | tac | tr '\n' ' '; echo) );

        if [[ $(echo ${HISTORY[@]} | wc -w) = 0 ]]; then
           continue;
        fi;

        for commit in ${HISTORY[@]}; do
            git show --pretty="%b" $cur_commit >> $DIFFS_FOLDER/$HASH;
        done;

        rm -rf *;

    done;
done < $DATA;

cd $CURRENT_FOLDER;
