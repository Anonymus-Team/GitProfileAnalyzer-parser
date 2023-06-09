#!/usr/bin/bash

# git repo size limit (in kilobytes)
export REPO_SIZE_LIMIT=50000

while IFS= read -r line; do 
    URL=$(echo $line | jq -c .github);

    if curl --output /dev/null --silent --head --fail "${URL:1:-1}"; then
        # need a substring cos jq outputs url like "github.com/ExampleUsr",
        # so we need to truncate github.com and all the quotes
        NICK=$(echo ${URL:12:-1});

        # GHP_TOKEN is an enviroment variable with your github access token see: 
        # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
        
        # Script works perfectly even without token, but there is limit for requests without Authorization
        REPS_JSON=$(curl -Ls \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $GHP_TOKEN" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/users/{$NICK}/repos);
                
        if REPS=$(echo $REPS_JSON | jq -ce '[.[] | select(.size < '$REPO_SIZE_LIMIT') | .html_url]'); then
            RES=$(echo $line | jq -c --argjson reps $REPS '.github = $reps');
            HASH=$(echo $RES | md5sum | cut -f1 -d" ");
            RES=$(echo $RES | jq -c --arg hash $HASH '{id: $hash} + .')
            RES=$(echo $RES | jq -c --arg nick $NICK '. + {ghpNick: $nick}')
            echo $RES;
        fi;
    fi;
done < $1;
