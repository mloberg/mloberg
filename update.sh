#!/usr/bin/env bash
set -eux

# grab latest blog post
post=$(curl -sL https://ivorisoutdoors.com/feed.json | jq -r '.posts[0] | "[\(.title)](\(.link))"')
sed -i -E "s~Latest post: .*~Latest post: $post~" README.md

# update latest commit
commit=$(curl -sL "https://api.github.com/search/commits?q=author:ivorisoutdoors&sort=author-date&order=desc&page=1" | jq -r '[
    .items[] |
    select(.repository.full_name != "ivorisoutdoors/ivorisoutdoors") |
    select(.repository.full_name != "ivorisoutdoors/.github") |
    select(.commit.message | startswith("Merge") | not)
][0] |
. + { message: .commit.message | split("\n") | first } |
"[\(.message)](\(.html_url)) ([\(.repository.full_name)](\(.repository.html_url)))"
')
sed -i -E "s~Latest commit: .*~Latest commit: $commit~" README.md
