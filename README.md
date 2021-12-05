# git-tag-action

GitHub action that adds a lightweight git tag to the current workflow commit.

**Note:** If a tag with the same name already exists, it gets replaced.

It's a fork of [hole19/git-tag-action](https://github.com/hole19/git-tag-action) which is seems to be abandoned. 
The difference is that my action contains an important [fix](https://github.com/cardinalby/git-tag-action/commit/adb9d80398c1aa46bcb677fa8e2dbabfc69cbc69) 
(it checks if the tag exists both in the remote and local repos).

## Environment Variables

* **GITHUB_TOKEN (required)** - Required for permission to tag the repository.
* **TAG (required)** - Name of the tag to be added.

## Example usage

```yaml
uses: cardinalby/git-tag-action@master
env:
  TAG: v1.2.3
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
