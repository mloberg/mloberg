#!/usr/bin/env bash
set -eux

# grab latest post
feed=$(curl -sL https://mlo.io/feed.json)
title=$(echo "$feed" | jq -r '.posts[0].title')
link=$(echo "$feed" | jq -r '.posts[0].link')

sed -i -E "s~Latest post: .*~Latest post: [$title]($link)~" README.md

# update latest commit
latest=$(curl -s "https://api.github.com/users/mloberg/events?per_page=100" | jq -r '[
    .[] |
    select(.type == "PushEvent") |
    select(.repo.name != "mloberg/mloberg") |
    select(.repo.name != "mloberg/.github") |
    select(.payload.commits | length > 0) |
    select(.payload.commits[-1].message | startswith("Merge") | not) |
    select(.payload.commits[-1].author.name | contains("[bot]") | not) |
    { repo: .repo, commit: .payload.commits[-1] }
][0]')
[ "$latest" == "null" ] && exit 0
repo_url=$(curl -s "$(echo "$latest" | jq -r '.repo.url')" | jq -r '.html_url')
commit_url=$(curl -s "$(echo "$latest" | jq -r '.commit.url')" | jq -r '.html_url')

repo=$(echo "$latest" | jq -r '.repo.name')
commit=$(echo "$latest" | jq -r '[.commit.message | splits("\n")][0]')

msg="[$commit]($commit_url) ([$repo]($repo_url))"

sed -i -E "s~Latest commit: .*~Latest commit: $msg~" README.md
