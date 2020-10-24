#!/bin/bash
set -e
function mirror {
    echo Starting mirroring of $1  in $WORK_DIR
    echo "$ACCESS_TOKEN" | gh auth login --with-token 

    url="$1"
    priv=""
    
    if [[ "$url" = -* ]];
    then
        priv="1"
        url="${url:1}"
    fi
    
    user=$(echo $url | cut -f2 -d'#')
    url=$(echo $url | cut -f1 -d'#')

    host=$(echo $url | cut -f3 -d'/')
    host="${host%.*}"

    if [ "$user" = "$url" ];
    then
        user=$(echo $url | rev | cut -f2 -d'/' | rev )
    fi

    repo=$(echo $url | rev | cut -f1 -d'/' | rev )
    repo="${repo%.*}"

    mirrorId=$repo-$user-$host

    if git ls-remote $url; # Check if it exists
    then
        if  ! gh repo view $BACKUP_ORG_NAME/$mirrorId ;
        then
            echo "Create new repo  $BACKUP_ORG_NAME/$mirrorId"
            v="--public"
            if [ "$priv" = "1" ];
            then
                v="--priv"
            fi
            gh repo create   --enable-issues=false  --enable-wiki=false $BACKUP_ORG_NAME/$mirrorId   -y $v -d "Mirror of $user/$repo from $host" 
            sleep 10
        fi
        cd "$WORK_DIR"
        rm -Rf mirror
        echo "Cloning..."
        git clone --mirror $url mirror
        echo "Pushing..."
        cd mirror
        git remote set-url --push origin https://$ACCESS_USER:$ACCESS_TOKEN@github.com/$BACKUP_ORG_NAME/$mirrorId
        git fetch -p origin
        git push --mirror --force
        cd ..
        rm -Rf mirror
    fi
}
mirror $@