#!/usr/bin/env bash

s3bucket="$AWS_S3_BUCKET_NAME"
s3id="$AWS_ACCESS_KEY_ID"
s3secret="$AWS_ACCESS_KEY_SECRET"

function main () {
  upload "configure.sh" "cli@latest"
  upload "the.sh" "the@latest"
}

function upload () {
  file="$1"
  name="$2"

  acl="x-amz-acl: public-read"
  content_type="application/octet-stream"
  date="$(date +"%a, %d %b %Y %T %z")"
  data="PUT\n\n$content_type\n$date\n$acl\n/$s3bucket/$name"
  sign="$(echo -en "$data" | openssl sha1 -hmac "$s3secret" -binary | base64)"

  curl -X PUT -T "$file" \
    -H "Authorization: AWS $s3id:$sign" \
    -H "Content-Type: $content_type" \
    -H "Date: $date" \
    -H "Host: $s3bucket.s3.amazonaws.com" \
    -H "$acl" \
    "https://$s3bucket.s3.amazonaws.com/$name"
}

main "$@"
