#!/usr/bin/env bash
set -e

base_path="$(pwd -P)"
endpoint_url="https://api.the.delasy.com"

function throw {
  echo "$1" 1>&2
  exit 1
}

function request {
  req_params=(
    "-S" "-f" "-s"
    "-H" "Authorization: $AUTH_TOKEN"
    "-H" "Content-Type: application/octet-stream"
    "-X" "POST"
    "--data-binary" "@$2"
    "$1"
  )

  res_body="$(curl "${req_params[@]}" 2>&1)"
  res_code="$?"

  if [ "$res_code" -eq 0 ]; then
    if [ -n "$res_body" ]; then
      echo "$res_body"
    fi
  else
    throw "Error: Request failed with exit code $res_code"
  fi
}

function main {
  file_path=""
  is_compile=false
  is_lex=false

  if (( $# == 0 )); then
    throw "Error: Action is not set"
  fi

  for (( i=1; i <= "$#"; i++ )); do
    arg="${!i}"

    if (( i == 1 )); then
      if [ "$arg" == "compile" ]; then
        is_compile=true
      elif [ "$arg" == "lex" ]; then
        is_lex=true
      else
        throw "Error: Unknown action '$arg'"
      fi
    elif (( i == 2 )); then
      file_relative_dir="$(dirname "$arg")"

      if [ "${file_relative_dir:0:1}" == "/" ]; then
        file_dir="$file_relative_dir"
      else
        file_dir="$(cd "$base_path/$(dirname "$arg")" && pwd -P)"
      fi

      file_name="$(basename "$arg")"
      file_path="$file_dir/$file_name"

      if [ -e "$file_path" ]; then
        if [ ! -f "$file_path" ]; then
          throw "Error: '$file_path' is not a file"
        fi
      else
        throw "Error: File '$file_path' does not exists"
      fi
    else
      throw "Error: Unknown option '$arg'"
    fi
  done

  if [ -z "$file_path" ]; then
    throw "Error: File path is not set"
  elif [ -z "$AUTH_TOKEN" ]; then
    throw "Error: Authentication token is not set"
  fi

  if [ "$is_compile" == true ]; then
    throw "Error: Compiling is not supported yet"
  elif [ "$is_lex" == true ]; then
    request "$endpoint_url/lex" "$file_path"
  fi
}

main "$@"
