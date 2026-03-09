#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "extract_wwws: bare www domain" {
    run bash -c 'echo "visit www.example.com" | extract_wwws'
    assert_success
    assert_output "http://www.example.com"
}

@test "extract_wwws: www with path" {
    run bash -c 'echo "see www.example.com/path/to/page" | extract_wwws'
    assert_success
    assert_output "http://www.example.com/path/to/page"
}

@test "extract_wwws: https://www is filtered out" {
    run bash -c 'echo "https://www.example.com" | extract_wwws'
    assert_success
    assert_output ""
}

@test "extract_wwws: http://www is filtered out" {
    run bash -c 'echo "http://www.example.com" | extract_wwws'
    assert_success
    assert_output ""
}

@test "extract_wwws: quoted www with path strips quotes" {
    run bash -c "echo '\"www.example.com/path\"' | extract_wwws"
    assert_success
    assert_output "http://www.example.com/path"
    run bash -c "echo \"'www.example.com/path'\" | extract_wwws"
    assert_success
    assert_output "http://www.example.com/path"
    run bash -c 'echo "\`www.example.com/path\`" | extract_wwws'
    assert_success
    assert_output "http://www.example.com/path"
}

@test "extract_wwws: empty input produces no output" {
    run bash -c 'echo "" | extract_wwws'
    assert_success
    assert_output ""
}
