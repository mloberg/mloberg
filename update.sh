#!/usr/bin/env bash
set -e

# grab latest post
rss=$(curl -s https://mlo.io/feed.xml | node rss2Json.js)
title=$(echo "$rss" | jq -r '.items[0].title')
link=$(echo "$rss" | jq -r '.items[0].link')

sed -i -E "s~(<!--POST-->).*(<!--/POST-->)~\1[$title]($link)\2~" README.md

# update latest commit
latest=$(curl -s "https://api.github.com/users/mloberg/events?per_page=100" | jq -r '[
    .[] |
    select(.type == "PushEvent") |
    select(.repo.name != "mloberg/mloberg") |
    select(.repo.name != "mloberg/.github") |
    select(.payload.commits[-1].message | startswith("Merge") | not) |
    { repo: .repo, commit: .payload.commits[-1] }
][0]')
repo_url=$(curl -s "$(echo "$latest" | jq -r '.repo.url')" | jq -r '.html_url')
commit_url=$(curl -s "$(echo "$latest" | jq -r '.commit.url')" | jq -r '.html_url')

repo=$(echo "$latest" | jq -r '.repo.name')
commit=$(echo "$latest" | jq -r '[.commit.message | splits("\n")][0]')

msg="[$commit]($commit_url) ([$repo]($repo_url))"

sed -i -E "s~(<!--COMMIT-->).*(<!--/COMMIT-->)~\1$msg\2~" README.md
