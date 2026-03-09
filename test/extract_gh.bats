#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "extract_gh: single-quoted shorthand" {
    run bash -c "echo \"'user/repo'\" | extract_gh"
    assert_success
    assert_output "https://github.com/user/repo"
}

@test "extract_gh: double-quoted shorthand" {
    run bash -c 'echo "\"user/repo\"" | extract_gh'
    assert_success
    assert_output "https://github.com/user/repo"
}

@test "extract_gh: shorthand with underscores and dots" {
    run bash -c "echo \"'my_org/my.repo'\" | extract_gh"
    assert_success
    assert_output "https://github.com/my_org/my.repo"
}

@test "extract_gh: shorthand with hyphens" {
    run bash -c "echo \"'my-org/my-repo'\" | extract_gh"
    assert_success
    assert_output "https://github.com/my-org/my-repo"
}

@test "extract_gh: unquoted shorthand is not matched" {
    run bash -c 'echo "user/repo" | extract_gh'
    assert_success
    assert_output ""
}
