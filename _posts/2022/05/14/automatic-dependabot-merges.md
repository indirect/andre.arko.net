---
layout: post
title: "Automatic Dependabot merges"
microblog: false
guid: http://indirect-test.micro.blog/2022/05/15/automatic-dependabot-merges/
post_id: 4971983
date: 2022-05-15T00:00:00-0800
lastmod: 2022-05-14T16:00:00-0800
type: post
url: /2022/05/14/automatic-dependabot-merges/
---
I've been using [Dependabot](https://github.com/dependabot) for a long time. Back before GitHub bought it and took away the web dashboard, there was an amazing, glorious, wonderful feature: you could check a checkbox, and Dependabot would merge the open PR as soon as your tests passed.

Now that Dependabot has no web dashboard, and can't be added to a repo with one click, it has also lost the ability to automatically merge updates.

After several days of copying and pasting from blog posts and then troubleshooting YAML syntax, I am here to report that one of those three things can be brought back! (If you run your tests in GitHub actions, anyway.)

Here's what the automerge GitHub action looks like:

{% raw %}
```YAML
# .github/workflows/merge-dependabot.yml
name: "Merge updates"
on:
  workflow_run:
    workflows: ["CI"]
    types: ["completed"]
    branches: ["dependabot/**"]
jobs:
  merge:
    name: "Merge"
    runs-on: "ubuntu-latest"
    if: >
      github.event.workflow_run.event == 'pull_request' &&
      github.event.workflow_run.conclusion == 'success' &&
      github.actor == 'dependabot[bot]'
    steps:
      - name: "Merge pull request"
        uses: "actions/github-script@v6"
        with:
          github-token: "${{ secrets.GITHUB_TOKEN }}"
          script: |
            const pullRequest = context.payload.workflow_run.pull_requests[0]
            const repository = context.repo
            await github.rest.pulls.merge({
              merge_method: "merge",
              owner: repository.owner,
              pull_number: pullRequest.number,
              repo: repository.repo,
            })
```
{% endraw %}

If your CI GitHub action is named something besides "CI", you'll need to put your job's name in the fourth line.

Happy automerging!
