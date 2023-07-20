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
echo "here"
if $tag_exists
then
  echo "Updating tag on remote repo"
  # update tag

curl -s -X PATCH "$git_refs_url/tags/$TAG" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -d @- << EOF

  {
    "sha": "$GITHUB_SHA",
    "force": true
  }
EOF


else
  echo "creating tag in remote repo, and creating reference"
  # create new tag
  echo "tag: $TAG"

  body=$(cat <<EOF
     {
     "tag": "$TAG",
     "object": "$GITHUB_SHA",
     "message":"$GITHUB_ACTOR updated PR $GITHUB_HEAD_REF to $GITHUB_BASE_REF",
     "type": "commit"
  } 
  EOF
  )

  curl -X POST "$git_tags_url" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -d @- $body 


  # create reference
#   curl -X POST "$git_refs_url" \
#  -H "Authorization: token $GITHUB_TOKEN" \
#  -d @- << EOF

#  {
#    "ref": "refs/tags/$TAG",
#    "sha": "$GITHUB_SHA"
#  }
#EOF


fi
