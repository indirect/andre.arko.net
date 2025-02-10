---
date: "2020-12-08T00:00:00Z"
title: GitHub Apps, a high-wtf introduction
---
So maybe you've heard about those [GitHub App things](https://docs.github.com/en/free-pro-team@latest/developers/apps) that can programmatically interact with GitHub, and do useful stuff. "I want to build useful stuff!", you might say to yourself.

Well, there's good news and bad news. The good news is that it's a huge step up to interact with GitHub as an app, rather than trying to borrow a GitHub user's credentials. Creating a dedicated GitHub user account for every installation of a bot service was technically against the terms of service, as well as fiddly, error-prone, and typically a giant pain in the butt.

The bad news is that GitHub Apps are _also_ fiddly, error-prone, and incredibly complicated and confusing in ways that "pretend to be a single user" could never be complicated or confusing. Brace yourself, here we go.

To build a GitHub app, you need to use FIVE different GitHub API clients.

1. What GitHub calls an "app". These are available in the [GitHub Marketplace](https://github.com/marketplace), and can be installed into one or more repos belonging to a user or org. Every "app" also has its own GitHub account with a "bot" label.

    When you first create your "app", GitHub generates a .pem certificate file that you must download and use to generate a JWT for the `Authentication` header in API calls to the GitHub App API, which lives at `api.github.com`. You'll also need to add the `Accept` header `application/vnd.github.doctor-strange-preview+json`, because this API still lives behind a feature flag.

1. What GitHub calls an "installation". After an "app" has been installed by a user or org, you can make API call that returns a short-lived per-installation access token. The Installation API is more or less the same as if you created a dedicated GitHub account for your bot to use and gave that account read/write permission on the repo in question.

    Use that per-installation access token in the `Authentication` header to interact with the GitHub Installation API at `api.github.com`. You'll also need to add the `Accept` header `application/vnd.github.machine-man-preview+json`, because this API is feature-flagged.

1. What GitHub calls an "oauth app". When you create an "app", GitHub also creates linked "oauth app" at the same time, with a generated Client ID and a Client Secret.

    You use the Client ID and Client Secret as your username and password to interact with the GitHub OAuth App API at `api.github.com`.

    As an "oauth app", you can also provide a "Log in with GitHub" flow, which allows your app to not just authenticate users but also call the regular GitHub API as if you are that user. To do this, redirect a user to GitHub to log in and authorize your app, after which GitHub will redirect back to your app with a code.

1. Use the code provided by GitHub's redirect back to your site to request a short-lived per-user access token. The access token API does not use any HTTP authentication, and instead requires both your Client ID and Client Secret provided as query parameters.

    Extra confusingly, for _only_ these API calls that fetch user access tokens, you _must_ use `github.com` instead of `api.github.com`. Don't spend an hour debugging permissions errors only to discover you're calling the wrong domain like I did.

1. Finally, we made it: the regular user-facing GitHub API. These API responses will contain content as if you are the user who has authorized your app, allowing you to check permissions and (if you have been granted the right permissions) take actions on GitHub as that user.

    You use the short-lived access token mentioned above in the `Authorization` header, and send your GitHub API requests to `api.github.com`.

### tl;dr

1. GitHub App: auth with JWT, `Accept: doctor-strange-preview`, `api.github.com`.
1. GitHub App Installation: auth with installation access token, `Accept: man-machine-preview`, `api.github.com`.
1. GitHub OAuth App: auth with client ID and client secret, `api.github.com`.
1. GitHub OAuth Access Tokens: don't auth, include client ID and client secret in params, `github.com`.
1. GitHub User: auth with user access token, `api.github.com`.

Now you know everything I learned about GitHub Apps this week. Good luck building yours!
