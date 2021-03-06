#!/usr/bin/env bash

#
# Copyright (c) 2021-present Aaron Delasy
# Licensed under the MIT License
#

set -e

base_path="$(pwd -P)"
endpoint_url="https://api.thelang.io"

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

  if res_body="$(curl "${req_params[@]}" 2>&1)"; then
    if [ -n "$res_body" ]; then
      echo "$res_body"
    fi
  else
    throw "Error: Request failed with exit code $?"
  fi
}

function main {
  file_path=""
  is_compile=false
  is_lex=false
  is_upgrade=false
  the="latest"

  if (( $# == 0 )); then
    throw "Error: Action is not set"
  elif [[ $# -eq 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
    echo
    echo "  Usage:"
    echo
    echo "     the [option]"
    echo "     the [action] file [action-options]"
    echo
    echo "  Options:"
    echo
    echo "    -h, --help        Print help information"
    echo "    -v, --version     Print version"
    echo
    echo "  Actions:"
    echo
    echo "    compile           Compile file (soon)"
    echo "    lex               Lex file"
    echo "    upgrade           Self-upgrade CLI to newest version"
    echo
    echo "  Action Options:"
    echo
    echo "    --the=x.x.x       Specify The Programming Language version," \
      "valid values:"
    echo "                        latest"
    echo "                        0.2"
    echo "                        0.2.0"
    echo
    echo "  Examples:"
    echo
    echo "    $ the -h"
    echo "    $ the --version"
    echo
    echo "    $ the compile /path/to/file"
    echo "    $ the lex /path/to/file"
    echo "    $ the compile /path/to/file --the=1.0"
    echo "    $ the lex /path/to/file --the=1.0.0"
    echo "    $ the upgrade"
    echo

    exit
  elif [[ $# -eq 1 && ("$1" == "-v" || "$1" == "--version") ]]; then
    echo "The Programming Language"
    echo "Version 0.2.0 (Nematode)"
    echo "Copyright (c) Aaron Delasy"

    exit
  fi

  for (( i=1; i <= "$#"; i++ )); do
    arg="${!i}"

    if (( i == 1 )); then
      if [ "$arg" == "compile" ]; then
        is_compile=true
      elif [ "$arg" == "lex" ]; then
        is_lex=true
      elif [ "$arg" == "upgrade" ]; then
        is_upgrade=true
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
      if [ "${arg:0:6}" == "--the=" ]; then
        the="${arg:6}"
      else
        throw "Error: Unknown option '$arg'"
      fi
    fi
  done

  if [ "$is_upgrade" == true ]; then
    curl -o /usr/local/bin/the@latest -s https://cdn.thelang.io/the@latest
    chmod +x /usr/local/bin/the@latest

    nohup bash -c "sleep 1 && \
      rm -f /usr/local/bin/the && \
      mv /usr/local/bin/the@latest /usr/local/bin/the" > /dev/null 2>&1 &
  elif [ -z "$file_path" ]; then
    throw "Error: File path is not set"
  elif [ -z "$AUTH_TOKEN" ]; then
    throw "Error: Authentication token is not set"
  fi

  if [ "$is_compile" == true ]; then
    throw "Error: Compiling is not supported yet"
  elif [ "$is_lex" == true ]; then
    request "$endpoint_url/lex?v=$the" "$file_path"
  fi
}

main "$@"
