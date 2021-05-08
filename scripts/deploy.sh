#!/usr/bin/env bash

s3bucket="$AWS_S3_BUCKET_NAME"
s3id="$AWS_ACCESS_KEY_ID"
s3region="$AWS_S3_REGION"
s3secret="$AWS_ACCESS_KEY_SECRET"

function hash_sha256 {
  printf "%s" "$1" | openssl dgst -sha256 | sed "s/^.* //"
}

function hmac_sha256 {
  printf "%s" "$2" | openssl dgst -sha256 -mac HMAC -macopt "$1" | sed "s/^.* //"
}

function aws_s3_put_object {
  file="$1"
  name="$2"

  method="PUT"
  host="s3.$s3region.amazonaws.com"
  resource="/$s3bucket/$name"

  date="$(date -u "+%Y%m%d")"
  datetime="${date}T$(date -u "+%H%M%S")Z"
  hash="$(hash_sha256 "")"

  header_content_type="content-type:application/octet-stream"
  header_host="host:$host"
  header_x_amz_content_sha256="x-amz-content-sha256:$hash"
  header_x_amz_date="x-amz-date:$datetime"

  canonical_headers="$header_content_type"$'\n'
  canonical_headers+="$header_host"$'\n'
  canonical_headers+="$header_x_amz_content_sha256"$'\n'
  canonical_headers+="$header_x_amz_date"

  signed_headers="content-type;"
  signed_headers+="host;"
  signed_headers+="x-amz-content-sha256;"
  signed_headers+="x-amz-date"

  canonical_req="$method"$'\n'
  canonical_req+="$resource"$'\n'
  canonical_req+=$'\n'
  canonical_req+="$canonical_headers"$'\n'
  canonical_req+=$'\n'
  canonical_req+="$signed_headers"$'\n'
  canonical_req+="$hash"

  sign_str="AWS4-HMAC-SHA256"$'\n'
  sign_str+="$datetime"$'\n'
  sign_str+="$date/$s3region/s3/aws4_request"$'\n'
  sign_str+="$(hash_sha256 "$canonical_req")"

  step1="$(hmac_sha256 "key:AWS4$s3secret" "$date")"
  step2="$(hmac_sha256 "hexkey:$step1" "$s3region")"
  step3="$(hmac_sha256 "hexkey:$step2" "s3")"
  step4="$(hmac_sha256 "hexkey:$step3" "aws4_request")"
  sign="$(hmac_sha256 "hexkey:$step4" "$sign_str")"

  header_authorization="authorization:AWS4-HMAC-SHA256 Credential=$s3id/$date/$s3region/s3/aws4_request, SignedHeaders=$signed_headers, Signature=$sign"

  curl -X "$method" -T "$file" \
    -H "$header_authorization" \
    -H "$header_content_type" \
    -H "$header_host" \
    -H "$header_x_amz_content_sha256" \
    -H "$header_x_amz_date" \
    "https://$host$resource"
}

function main {
  # aws_s3_put_object "configure.sh" "cli@latest"
  # aws_s3_put_object "the.sh" "the@latest"
  aws_s3_put_object "configure.sh" "cli"
}

main "$@"
