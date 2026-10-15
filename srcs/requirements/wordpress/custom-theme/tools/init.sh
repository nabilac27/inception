#!/bin/bash

set -e

# ------------------------ ACTIVATE CUSTOM THEME -------------------------------------------
if wp theme is-installed custom-theme --allow-root;
then
    wp theme activate custom-theme --allow-root
else
    echo "Error: Custom WordPress theme not found." >&2
    exit 1
fi

# ------------------------ CONFIGURE PERMALINKS --------------------------------------------
wp rewrite structure '/%postname%/' --allow-root

# ------------------------ CREATE POSTS PAGE ------------------------------------------------
POSTS_PAGE_ID=$(wp post list \
    --post_type=page \
    --name=posts \
    --field=ID \
    --allow-root)

if [ -z "$POSTS_PAGE_ID" ];
then
    wp post create \
        --post_type=page \
        --post_title="Posts" \
        --post_name="posts" \
        --post_status=publish \
        --allow-root
fi

# ------------------------ CREATE BONUS PAGE ------------------------------------------------
BONUS_PAGE_ID=$(wp post list \
    --post_type=page \
    --name=bonus \
    --field=ID \
    --allow-root)

if [ -z "$BONUS_PAGE_ID" ];
then
    wp post create \
        --post_type=page \
        --post_title="Bonus" \
        --post_name="bonus" \
        --post_status=publish \
        --allow-root
fi
