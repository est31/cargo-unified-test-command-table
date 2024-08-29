#!/usr/bin/env bash

function say {
    #>&2 echo $1
    return
}

function prepare_pattern {
    find . -path ./target -prune -o -name '*.rs' -exec sed -i "s#\(\* $1 \*.\).*\$#\1$2#" {} \;
}

function try_command_with_pattern {
    say "    Trying command '$1' with pattern '$2'"
    prepare_pattern $2 " compile_error!(\"injected failure\");"
    $1 &> /dev/null
    local exit_code=$?
    say "    exit code: $exit_code"
    prepare_pattern $2 " "
    return $exit_code
}

#pattern_headings=("lib.rs" "main.rs" "lib.rs cfg test" "tests/" "examples/" "benches/" "doctests")
#patterns=("lib.rs" "main.rs" "lib_cfg_test" "test.rs" "example.rs" "bench.rs" "doctest")

pattern_headings=("lib.rs" "main.rs" "lib.rs cfg test" "tests/" "benches/" "doctests")
patterns=("lib.rs" "main.rs" "lib_cfg_test" "test.rs" "bench.rs" "doctest")

commands=("cargo c" "cargo c --all-targets" "cargo t --no-run" "cargo t" "cargo t --all-targets" "cargo t --no-run --all-targets" "cargo t --doc")

function try_command {
    say "  Trying command '$1' with patterns"
    local padding=30
    printf "| %-${padding}s" "${1/cargo /}"
    for pattern in "${patterns[@]}"; do
        if try_command_with_pattern "$1" "$pattern"; then
            printf " | %3s" "no"
        else
            printf " | %3s" "yes"
        fi
    done
    printf " |\n"
}

function try_commands {
    printf "| cargo command"
    for hd in "${pattern_headings[@]}"; do
        printf " | %5s" "$hd"
    done
    printf " |\n"

    printf "| -----"
    for hd in "${pattern_headings[@]}"; do
        printf " | -----"
    done
    printf " |\n"

    for command in "${commands[@]}"; do
        try_command "$command"
    done
}

#try_command_with_pattern "cargo c" main.rs
#try_command "cargo c"
try_commands
