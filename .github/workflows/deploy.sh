#!/usr/bin/env bash
set -e

aws_access_key="$AWS_ACCESS_KEY"
aws_access_secret="$AWS_ACCESS_SECRET"
aws_cloudfront_distribution="$AWS_CLOUDFRONT_DISTRIBUTION"
aws_s3_region="$AWS_S3_REGION"
aws_s3_bucket="$AWS_S3_BUCKET"
lf=$'\n'

function hash_sha256 {
  printf "%s" "$1" | openssl dgst -sha256 | sed "s/^.* //"
}

function hmac_sha256 {
  printf "%s" "$2" | openssl dgst -sha256 -mac HMAC -macopt "$1" | sed "s/^.* //"
}

function aws_request {
  req_service="$1"
  req_method="$2"
  req_host="$3"
  req_path="$4"
  req_content_type="$5"
  req_hash="$6"

  req_date="$(date -u "+%Y%m%d")"
  req_datetime="${req_date}T$(date -u "+%H%M%S")Z"

  req_headers=(
    "content-type:$req_content_type"
    "host:$req_host"
    "x-amz-content-sha256:$req_hash"
    "x-amz-date:$req_datetime"
  )

  req_canonical="$req_method$lf"
  req_canonical+="$req_path$lf"
  req_canonical+="$lf"

  for header in "${req_headers[@]}"; do
    req_canonical+="$header$lf"
  done

  req_canonical+="$lf"

  req_signed_headers=""
  req_signed_header_i=0

  for header in "${req_headers[@]}"; do
    if (( req_signed_header_i == 0 )); then
      req_signed_headers+="${header%:*}"
    else
      req_signed_headers+=";${header%:*}"
    fi

    ((req_signed_header_i++))
  done

  req_canonical+="$req_signed_headers$lf"
  req_canonical+="$req_hash"

  sign_str="AWS4-HMAC-SHA256$lf"
  sign_str+="$req_datetime$lf"
  sign_str+="$req_date/$aws_s3_region/$req_service/aws4_request$lf"
  sign_str+="$(hash_sha256 "$req_canonical")"

  step1="$(hmac_sha256 "key:AWS4$aws_access_secret" "$req_date")"
  step2="$(hmac_sha256 "hexkey:$step1" "$aws_s3_region")"
  step3="$(hmac_sha256 "hexkey:$step2" "$req_service")"
  step4="$(hmac_sha256 "hexkey:$step3" "aws4_request")"
  sign="$(hmac_sha256 "hexkey:$step4" "$sign_str")"

  curl_headers=("-H" "authorization:AWS4-HMAC-SHA256 Credential=$aws_access_key/$req_date/$aws_s3_region/$req_service/aws4_request, SignedHeaders=$req_signed_headers, Signature=$sign")

  for header in "${req_headers[@]}"; do
    curl_headers+=("-H" "$header")
  done

  curl -X "$req_method" "${@:7}" "${curl_headers[@]}" "https://$req_host$req_path"
}

function aws_cloudfront_create_invalidation {
  data="<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  data+="<InvalidationBatch xmlns=\"http://cloudfront.amazonaws.com/doc/2020-05-31/\">"
  data+="<CallerReference>$(date -u '+%s')</CallerReference>"
  data+="<Paths>"
  data+="<Items>"

  for path in "${@}"; do
    data+="<Path>$path</Path>"
  done

  data+="</Items>"
  data+="<Quantity>${#@}</Quantity>"
  data+="</Paths>"
  data+="</InvalidationBatch>"

  aws_request cloudfront \
    POST "cloudfront.amazonaws.com" "/2020-05-31/distribution/$aws_cloudfront_distribution/invalidation" \
    "text/xml" \
    "$(hash_sha256 "")" \
    -d "$data"
}

function aws_s3_put_object {
  file="$1"
  name="$2"

  aws_request s3 \
    PUT "s3.$aws_s3_region.amazonaws.com" "/$aws_s3_bucket/$name" \
    "application/octet-stream" \
    "$(openssl dgst -sha256 < "$file" | sed "s/^.* //")" \
    -T "$file"
}

function main {
  aws_s3_put_object "configure.sh" "cli%40latest"
  aws_s3_put_object "the.sh" "the%40latest"
  aws_cloudfront_create_invalidation "/cli%40latest" "/the%40latest"
}

main "$@"
