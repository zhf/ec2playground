#!/bin/bash

while true; do
  prompt="EC2> "
  # Readline
  read -e -r -p "$prompt" cmd

  # EOF
  test $? -ne 0 && break

  # History
  history -s "$cmd"

  # Built-in commands
  case $cmd in
    usage) cmd=help;;
    "") continue;;
    quit, exit) break;;
  esac

  # Execute
  eval ec "$cmd"
done

echo