---
title: Rails 6 containers, but really quickly
layout: post

---
Running `docker build` always feels too slow. Most of the time, new builds still have to download and install something that every previous build also had to download and install—whether apt, yum, npm, or gem, there a lot of options for something that has to be done slowly, over and over.

Using layer caching helps, but it's still sort of infuriating. A single change (for example, adding just one gem) means Docker has to start completely from scratch for that step. Have 400 gems already built into an image, and add a single new gem? Now Docker has to install not 1 gem, but 401 gems.

Even worse, whatever steps come after that step are no longer cached either. Now that you've added your one gem, you also have to wait through reinstalling 8,000 npm packages from scratch, even though they haven't changed at all.

I felt frustrated by this for years of using Docker, but never really had a good solution. Usually I would just reorder my Dockerfile to put whatever I was changing last, so that edits at least wouldn't mean re-running any unchanged steps.

Then, earlier this year, I ran across [a novel approach using a relatively new Docker feature called ONBUILD](https://ledermann.dev/blog/2020/01/29/building-docker-images-the-performant-way/). Excitingly, it offers an actual solution to the problem: create a base image that has all current gems installed, and use that base to build a per-commit image that updates only new gems. That might change over time, but if you also use scheduled builds, you can guarantee that the build only has to install gems added since the last scheduled build. With this tactic, per-commit images build in a little as 1-2 minutes!

To set it up, you create two Dockerfiles. The first Dockerfile (I usually call it `Dockerfile-base`) installs the OS packages you'll need to build gems from source, and installs gems and packages. Here's a simplified version of the logic from `Dockerfile-base`.

```dockerfile
# Dockerfile-base
FROM ruby:alpine

# Install base app gems into the base image
COPY Gemfile* .ruby-version /app/
RUN bundle install --deployment --path /app/vendor/bundle

# In builds using this as a base, install new gems and remove obsolete gems
ONBUILD COPY Gemfile* .ruby-version /app/
ONBUILD RUN bundle install --clean

# After updating gems for the child image, copy in the latest app code
ONBUILD COPY . /app
```

Note that the ONBUILD steps _do not_ run when this image is built. Instead, those steps run when another image uses this image as a base.

The base needs to be rebuilt periodically, but it's not super important—each individual change to the underlying gems or packages typically adds just a few seconds to the build. I typically set GitHub Actions to rebuild the base image and push once each night, rolling up all the changes from the previous day and speeding up builds for the next day. Here's an example GitHub Action to rebuild the base image each night.

```yaml
# .github/workflows/daily-build-base.yml
name: Build base image

on:
  schedule:
    - cron: "3 8 * * *" # 8am UTC is 1am PST

steps:
  - name: Checkout code
    uses: actions/checkout@v2

  - name: Build and push Docker images
    uses: docker/build-push-action@v1
    with:
      username: ${{ secrets.DOCKER_USERNAME }}
      password: ${{ secrets.DOCKER_PASSWORD }}
      repository: myorg/myrepo
      tags: latest
```

Then, the main Dockerfile uses that image as a base. The especial genius of this move is that Bundler and npm/yarn no longer start from nothing, but install on top of a complete set of packages from the recent past. If you add a new gem, the base image already has every gem except that one, and the only work Bundler has to do at build time is add that one gem. Here's what a `Dockerfile` might look like with this strategy.

```dockerfile
FROM myorg/myrepo-base:latest AS base
FROM ruby:alpine


COPY --from=base /app /app

CMD ["bin/puma", "-p" "$PORT"]
```

You can't see it in this Dockerfile, but the ONBUILD steps from `Dockerfile-base` will update the base image to have the latest gems and app files before the COPY steps add those files to the final image.

Using this technique, it's possible to build Rails 6 production containers, including running webpacker to generate assets, in as little as 2-3 minutes—even when there are changes to gems or node modules.