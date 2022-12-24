#/usr/bin/env bash

set -e

src_args_content=$(< src/args)
src_builder_content=$(< src/builder)
src_command_content=$(< src/command)
src_error_content=$(< src/error)
src_fs_content=$(< src/fs)
src_main_content=$(< src/main)
src_parser_content=$(< src/parser)
src_str_content=$(< src/str)

content="${src_main_content:0:137}"
content+="${src_command_content:78:75}"
content+="${src_args_content:78:42}"

content+="${src_error_content:78}"
content+="${src_fs_content:76}"
content+="${src_str_content:76}"
content+="${src_args_content:118}"
content+="${src_builder_content:76}"
content+="${src_command_content:151}"
content+="${src_parser_content:76}"
content+="${src_main_content:135}"

printf '%s\n' "$content" > build.out
