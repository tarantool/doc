#!/usr/bin/env bash

set -xe -o pipefail -o nounset

BRANCH=$DEPLOYMENT_NAME
ENDPOINT_URL=$S3_ENDPOINT_URL
S3_PATH=$S3_UPLOAD_PATH

echo "Upload produced documentation outputs to the S3 storage, tarantool/${BRANCH}"

# don't upload the '*.pickle' files
find output -name '*.pickle' -delete

# upload json and images
aws s3 sync output/json $S3_PATH/$BRANCH/json --endpoint-url=$ENDPOINT_URL --delete --include "*" --exclude "*.jpg" --exclude "*.png" --exclude "*.svg"
aws s3 sync output/json/_build_en/json/_images $S3_PATH/$BRANCH/images_en --endpoint-url=$ENDPOINT_URL --delete --size-only
aws s3 sync output/json/_build_ru/json/_images $S3_PATH/$BRANCH/images_ru --endpoint-url=$ENDPOINT_URL --delete --size-only

# upload pdf files
if [ -f output/_latex_en/tarantool.pdf ]; then
  aws s3 cp --acl public-read output/_latex_en/tarantool.pdf $S3_PATH/$BRANCH/Tarantool-en.pdf --endpoint-url=$ENDPOINT_URL
fi
if [ -f output/_latex_ru/tarantool.pdf ]; then
  aws s3 cp --acl public-read output/_latex_ru/tarantool.pdf $S3_PATH/$BRANCH/Tarantool-ru.pdf --endpoint-url=$ENDPOINT_URL
fi

# upload singlehtml and assets
# if [ -f output/html/en/singlehtml.html ]; then
# aws s3 sync --acl public-read output/html/en/_static $S3_PATH/$BRANCH/en/_static --endpoint-url=$ENDPOINT_URL --delete --size-only
# aws s3 sync --acl public-read output/html/en/_images $S3_PATH/$BRANCH/en/_images --endpoint-url=$ENDPOINT_URL --delete --size-only
# aws s3 cp --acl public-read output/html/en/singlehtml.html $S3_PATH/$BRANCH/en/singlehtml.html --endpoint-url=$ENDPOINT_URL
# fi
# if [ -f output/html/ru/singlehtml.html ]; then
# aws s3 sync --acl public-read output/html/ru/_static $S3_PATH/$BRANCH/ru/_static --endpoint-url=$ENDPOINT_URL --delete --size-only
# aws s3 sync --acl public-read output/html/ru/_images $S3_PATH/$BRANCH/ru/_images --endpoint-url=$ENDPOINT_URL --delete --size-only
# aws s3 cp --acl public-read output/html/ru/singlehtml.html $S3_PATH/$BRANCH/ru/singlehtml.html --endpoint-url=$ENDPOINT_URL
# fi
