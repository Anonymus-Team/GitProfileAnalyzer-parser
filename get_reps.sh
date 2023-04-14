#!/usr/bin/sh

while IFS= read -r line; do 
    URL=$(echo $line | jq -c .git);

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
                
        if REPS=$(echo $REPS_JSON | jq -ce '[.[].html_url]'); then
            RES=$(echo $line | jq -c --argjson reps $REPS '.git = $reps');
            RES="{\"$(echo $RES | md5sum | cut -f1 -d" ")\":"$RES"}";
            echo $RES;
        fi;
    fi;
done < $1;
