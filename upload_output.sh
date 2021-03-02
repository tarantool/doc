#!/usr/bin/env bash

BRANCH=$BRANCH_NAME
ENDPOINT_URL=$S3_ENDPOINT_URL
S3_PATH=$S3_UPLOAD_PATH

# upload json and images
aws s3 rm $S3_PATH/$BRANCH/json --endpoint-url=$ENDPOINT_URL --recursive
aws s3 cp output/json $S3_PATH/$BRANCH/json --endpoint-url=$ENDPOINT_URL --recursive --include "*" --exclude "*.jpg" --exclude "*.png" --exclude "*.svg"
aws s3 cp output/json/_build_en/json/_images $S3_PATH/$BRANCH/images_en --endpoint-url=$ENDPOINT_URL --recursive
aws s3 cp output/json/_build_ru/json/_images $S3_PATH/$BRANCH/images_ru --endpoint-url=$ENDPOINT_URL --recursive

# upload pdf files
aws s3 cp --acl public-read output/_latex_en/Tarantool.pdf $S3_PATH/$BRANCH/Tarantool-en.pdf --endpoint-url=$ENDPOINT_URL
aws s3 cp --acl public-read output/_latex_ru/Tarantool.pdf $S3_PATH/$BRANCH/Tarantool-ru.pdf --endpoint-url=$ENDPOINT_URL

# upload singlehtml and assets
aws s3 cp --acl public-read output/html/en/_static $S3_PATH/$BRANCH/en/_static --endpoint-url=$ENDPOINT_URL --recursive
aws s3 cp --acl public-read output/html/en/_images $S3_PATH/$BRANCH/en/_images --endpoint-url=$ENDPOINT_URL --recursive
aws s3 cp --acl public-read output/html/en/singlehtml.html $S3_PATH/$BRANCH/en/singlehtml.html --endpoint-url=$ENDPOINT_URL
aws s3 cp --acl public-read output/html/ru/_static $S3_PATH/$BRANCH/ru/_static --endpoint-url=$ENDPOINT_URL --recursive
aws s3 cp --acl public-read output/html/ru/_images $S3_PATH/$BRANCH/ru/_images --endpoint-url=$ENDPOINT_URL --recursive
aws s3 cp --acl public-read output/html/ru/singlehtml.html $S3_PATH/$BRANCH/ru/singlehtml.html --endpoint-url=$ENDPOINT_URL

curl --data '{"update_key":"'"$TARANTOOL_UPDATE_KEY"'"}' --header "Content-Type: application/json" --request POST "$TARANTOOL_UPDATE_URL""$BRANCH"/
