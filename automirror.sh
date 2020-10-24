#!/bin/bash
set +e
i=0
while true;
do
    #Reload repolist
    echo "" > "$GENERATED_REPOLIST"
    cat "$BASE_REPOLIST"  > "$GENERATED_REPOLIST"
    ## Todo: pull rest from the store
    ####

    readarray -t repolist < "$GENERATED_REPOLIST"
    
    l=${#repolist[@]}
    if [ $i -ge $l ];
    then
        i=0
        echo "Mirroring completed for all the repos. Sleep for $TIME_BETWEEN_EXECUTIONS seconds."
        sleep $TIME_BETWEEN_EXECUTIONS
    fi
    ./mirror.sh "${repolist[$i]}"
    i=`expr $i + 1`
    sleep $TIME_BETWEEN_CLONES
done
