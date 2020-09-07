#!/usr/bin/env bash

# upload json and images
aws s3 rm $S3_PATH/$CI_COMMIT_REF_NAME/json --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
aws s3 cp output/json $S3_PATH/$CI_COMMIT_REF_NAME/json --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive --include "*" --exclude "*.jpg" --exclude "*.png" --exclude "*.svg"
aws s3 cp output/json/_build_en/json/_images $S3_PATH/$CI_COMMIT_REF_NAME/images_en --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
aws s3 cp output/json/_build_ru/json/_images $S3_PATH/$CI_COMMIT_REF_NAME/images_ru --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive

# upload pdf files
aws s3 cp --acl public-read output/_latex_en/Tarantool.pdf $S3_PATH/$CI_COMMIT_REF_NAME/Tarantool-en.pdf --endpoint-url=$AWS_S3_ENDPOINT_URL
aws s3 cp --acl public-read output/_latex_ru/Tarantool.pdf $S3_PATH/$CI_COMMIT_REF_NAME/Tarantool-ru.pdf --endpoint-url=$AWS_S3_ENDPOINT_URL

# upload singlehtml and assets
aws s3 cp --acl public-read output/html/en/_static $S3_PATH/$CI_COMMIT_REF_NAME/en/_static --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
aws s3 cp --acl public-read output/html/en/_images $S3_PATH/$CI_COMMIT_REF_NAME/en/_images --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
aws s3 cp --acl public-read output/html/en/singlehtml.html $S3_PATH/$CI_COMMIT_REF_NAME/en/singlehtml.html --endpoint-url=$AWS_S3_ENDPOINT_URL
aws s3 cp --acl public-read output/html/ru/_static $S3_PATH/$CI_COMMIT_REF_NAME/ru/_static --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
aws s3 cp --acl public-read output/html/ru/_images $S3_PATH/$CI_COMMIT_REF_NAME/ru/_images --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
aws s3 cp --acl public-read output/html/ru/singlehtml.html $S3_PATH/$CI_COMMIT_REF_NAME/ru/singlehtml.html --endpoint-url=$AWS_S3_ENDPOINT_URL

curl --data '{"update_key":"'"$TARANTOOL_UPDATE_KEY"'"}' --header "Content-Type: application/json" --request POST "$TARANTOOL_UPDATE_URL""$CI_COMMIT_REF_NAME"/

if [ "${LATEST_DOC}" = "${CI_COMMIT_REF_NAME}" ]; then
  # upload json and images
  aws s3 rm $S3_PATH/latest/json --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
  aws s3 cp output/json $S3_PATH/latest/json --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive --include "*" --exclude "*.jpg" --exclude "*.png" --exclude "*.svg"
  aws s3 cp output/json/_build_en/json/_images $S3_PATH/latest/images_en --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
  aws s3 cp output/json/_build_ru/json/_images $S3_PATH/latest/images_ru --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive

  # upload pdf files
  aws s3 cp --acl public-read output/_latex_en/Tarantool.pdf $S3_PATH/latest/Tarantool-en.pdf --endpoint-url=$AWS_S3_ENDPOINT_URL
  aws s3 cp --acl public-read output/_latex_ru/Tarantool.pdf $S3_PATH/latest/Tarantool-ru.pdf --endpoint-url=$AWS_S3_ENDPOINT_URL

  # upload singlehtml and assets
  aws s3 cp --acl public-read output/html/en/_static $S3_PATH/latest/en/_static --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
  aws s3 cp --acl public-read output/html/en/_images $S3_PATH/latest/en/_images --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
  aws s3 cp --acl public-read output/html/en/singlehtml.html $S3_PATH/latest/en/singlehtml.html --endpoint-url=$AWS_S3_ENDPOINT_URL
  aws s3 cp --acl public-read output/html/ru/_static $S3_PATH/latest/ru/_static --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
  aws s3 cp --acl public-read output/html/ru/_images $S3_PATH/latest/ru/_images --endpoint-url=$AWS_S3_ENDPOINT_URL --recursive
  aws s3 cp --acl public-read output/html/ru/singlehtml.html $S3_PATH/latest/ru/singlehtml.html --endpoint-url=$AWS_S3_ENDPOINT_URL
fi

curl --data '{"update_key":"'"$TARANTOOL_UPDATE_KEY"'"}' --header "Content-Type: application/json" --request POST "$TARANTOOL_UPDATE_URL"latest/
