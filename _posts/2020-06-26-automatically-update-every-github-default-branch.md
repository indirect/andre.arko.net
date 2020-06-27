---
title: "Automatically update every GitHub default branch"
layout: post
---

When I wrote about [how to change git and GitHub's default branches](/2020/06/06/changing-git-and-githubs-default-branch-name/), I was thinking entirely in terms of fixing the problem one repo at a time. The next day, GitHub announced they would be changing the default, so I thought my script wouldn't even be necessary, since surely GitHub would offer a bulk change tool as part of changing the default.

Unfortunately, it's been 20 days, and GitHub not only hasn't shipped a tool to bulk-change default branches, it hasn't shipped the default branch name change at all. In the spirit of solving the problem as quickly as possible, here's a script that will change the default branch for every repository in a particular user or organization on GitHub. You'll need [hub](https://hub.github.com) installed. On macOS, that means running `brew install hub`, and then `hub api user` to trigger authentication.

```bash
#!/bin/bash
NAME="$1"
BRANCH="${2:-main}"
HUB=$(which hub || echo /usr/local/bin/hub)

# get repos that belong to the given user/org, are not archived, and are not forks
repos=($($HUB api --paginate --obey-ratelimit --flat graphql -f query='
  query($endCursor: String) {
    repositoryOwner(login: "'"$NAME"'") {
      repositories(isLocked: false, isFork: false, first: 100, after: $endCursor) {
        nodes { nameWithOwner }
        pageInfo { hasNextPage, endCursor }
      }
    }
  }
' | grep nameWithOwner | cut -f2 | grep "$NAME/"))

count=$(echo $(echo "${repos[*]}" | wc -w))
echo "found $count repos belonging to $NAME"

for repo in ${repos[@]}; do
  echo "$repo"

  # look for a branch with the right name
  if $HUB api --flat "repos/$repo/git/refs/heads/$BRANCH" | grep ".object.sha" 1> /dev/null; then
    echo "  found branch $BRANCH"
  else
    # create the branch we need if it doesn't exist
    SHA=$($HUB api --flat "repos/$repo/git/refs/heads/master" | grep ".object.sha" | cut -f2)
    $HUB api "repos/$repo/git/refs" -F "ref=refs/heads/$BRANCH" -F "sha=$SHA" 1> /dev/null
    echo "  created branch $BRANCH"
  fi

  # now that the branch exists, update the repo default branch
  $HUB api "repos/$repo" -X PATCH -F default_branch="$BRANCH" --flat 1> /dev/null
  echo "  set default branch to $BRANCH"

  # check how close we are to the rate limit
  ratelimit=$($HUB api rate_limit --flat | grep .core)
  if [[ $(echo "$ratelimit" | grep .remaining | cut -f2) < 4 ]]; then
    # if we have less than 4 API calls left, sleep until the limit resets
    sleep $(expr $(echo "$ratelimit" | grep .reset | cut -f2) - $(date +%s))
  fi
done
```

If you just want to do the thing, you can run it directly like this:

```bash
curl -L https://git.io/JJeCZ | bash -s USERNAME [BRANCH]
```

Replace `USERNAME` with your GitHub username, or the name of an organization whose repos you want to update. The second argument `BRANCH` is optional, and defaults to `main`. Keep in mind that you might not have permission to change the default branch on every repo in an organization unless you have "Owner" permissions in that org.

If anything goes wrong, it shouldn't hurt anything to run the script more than once--repos that have already updated will get processed faster, with less API calls.

Depending on how many repos you want to update, this might take a couple of hours. GitHub only allows 5000 API requests per hour, and this script needs 2-4 requests per repo. If the script hits the rate limit, it will sleep until the time GitHub said the limit would reset and then keep going.

While you're waiting for all of your repos to update, why not donate to [The Loveland Foundation](https://thelovelandfoundation.org/loveland-therapy-fund/), [The Okra Project](https://www.theokraproject.com), or [The Innocence Project](https://www.innocenceproject.org)?
