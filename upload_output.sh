#!/usr/bin/env bash

BRANCH=$BRANCH_NAME
ENDPOINT_URL=$S3_ENDPOINT_URL
S3_PATH=$S3_UPLOAD_PATH

# don't upload the '*.pickle' files
find output -name '*.pickle' -delete

# upload json and images
aws s3 sync output/json $S3_PATH/$BRANCH/json --endpoint-url=$ENDPOINT_URL --delete --include "*" --exclude "*.jpg" --exclude "*.png" --exclude "*.svg"
aws s3 sync output/json/_build_en/json/_images $S3_PATH/$BRANCH/images_en --endpoint-url=$ENDPOINT_URL --delete --size-only
aws s3 sync output/json/_build_ru/json/_images $S3_PATH/$BRANCH/images_ru --endpoint-url=$ENDPOINT_URL --delete --size-only

# upload pdf files
aws s3 cp --acl public-read output/_latex_en/Tarantool.pdf $S3_PATH/$BRANCH/Tarantool-en.pdf --endpoint-url=$ENDPOINT_URL
aws s3 cp --acl public-read output/_latex_ru/Tarantool.pdf $S3_PATH/$BRANCH/Tarantool-ru.pdf --endpoint-url=$ENDPOINT_URL

# upload singlehtml and assets
aws s3 sync --acl public-read output/html/en/_static $S3_PATH/$BRANCH/en/_static --endpoint-url=$ENDPOINT_URL --delete --size-only
aws s3 sync --acl public-read output/html/en/_images $S3_PATH/$BRANCH/en/_images --endpoint-url=$ENDPOINT_URL --delete --size-only
aws s3 cp --acl public-read output/html/en/singlehtml.html $S3_PATH/$BRANCH/en/singlehtml.html --endpoint-url=$ENDPOINT_URL
aws s3 sync --acl public-read output/html/ru/_static $S3_PATH/$BRANCH/ru/_static --endpoint-url=$ENDPOINT_URL --delete --size-only
aws s3 sync --acl public-read output/html/ru/_images $S3_PATH/$BRANCH/ru/_images --endpoint-url=$ENDPOINT_URL --delete --size-only
aws s3 cp --acl public-read output/html/ru/singlehtml.html $S3_PATH/$BRANCH/ru/singlehtml.html --endpoint-url=$ENDPOINT_URL

set -xe
curl --fail --show-error \
    --data '{"update_key":"'"$TARANTOOL_UPDATE_KEY"'"}' \
    --header "Content-Type: application/json" \
    --request POST "$TARANTOOL_UPDATE_URL""$BRANCH"/
