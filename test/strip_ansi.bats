#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "strip_ansi: removes SGR color sequence" {
    run bash -c 'printf "\e[31mhello\e[0m" | strip_ansi'
    assert_success
    assert_output "hello"
}

@test "strip_ansi: removes bold sequence" {
    run bash -c 'printf "\e[1mbold\e[0m" | strip_ansi'
    assert_success
    assert_output "bold"
}

@test "strip_ansi: removes 256-color sequence" {
    run bash -c 'printf "\e[38;5;196mred\e[0m" | strip_ansi'
    assert_success
    assert_output "red"
}

@test "strip_ansi: removes line-clear sequence" {
    run bash -c 'printf "text\e[K" | strip_ansi'
    assert_success
    assert_output "text"
}

@test "strip_ansi: plain text is unchanged" {
    run bash -c 'echo "no escapes here" | strip_ansi'
    assert_success
    assert_output "no escapes here"
}
