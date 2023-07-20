#!/bin/bash

# input validation
if [[ -z "${TAG}" ]]; then
   echo "No tag name supplied"
   exit 1
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
   echo "No github token supplied"
   exit 1
fi

if [[ -z "${GITHUB_ACTOR}" ]]; then 
   echo "No actor supplied"
   exit 1
fi

if [[ -z "$GITHUB_HEAD_REF}" ]]; then
   echo "No ref supplied"
   exit 1
fi

if [[ -z "$GITHUB_BASE_REF}" ]]; then
   echo "No ref supplied"
   exit 1
fi

if [[ -z "$GITHUB_HEAD_SHA}" ]]; then 
   echo "No head sha supplied"
   exit 1
fi


# get GitHub API endpoints prefix
git_refs_url=$(jq .repository.git_refs_url $GITHUB_EVENT_PATH | tr -d '"' | sed 's/{\/sha}//g')
git_tags_url=$(jq .repository.git_tags_url $GITHUB_EVENT_PATH | tr -d '"' | sed 's/{\/sha}//g')

# check if tag already exists in the cloned repo
tag_exists="false"
if [ $(git tag -l "$TAG") ]; then
    tag_exists="true"
else
  # check if tag exists in the remote repo
  getReferenceStatus=$(curl "$git_refs_url/tags/$TAG" \
  -H "Authorization: token $GITHUB_TOKEN" \
  --write-out "%{http_code}" -s -o /dev/null)

  if [ "$getReferenceStatus" = '200' ]; then
    tag_exists="true"
  fi
fi

echo "**pushing tag $TAG to repo $GITHUB_REPOSITORY"



if $tag_exists
then
# create new tag
  echo "git tags url: $git_tags_url"
  echo "$GITHUB_HEAD_SHA github head sha"
  curl -X POST "$git_tags_url" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -d @- << EOF
  {
    "tag": "$TAG",
    "object": "$GITHUB_HEAD_SHA",
    "message":"$GITHUB_ACTOR updated PR $GITHUB_HEAD_REF to $GITHUB_BASE_REF",
    "type": "commit"
  }
EOF
fi
