#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "version_ge: equal versions" {
    run version_ge "1.2.3" "1.2.3"
    assert_success
}

@test "version_ge: greater major" {
    run version_ge "2.0.0" "1.9.9"
    assert_success
}

@test "version_ge: greater minor" {
    run version_ge "1.3.0" "1.2.9"
    assert_success
}

@test "version_ge: greater patch" {
    run version_ge "1.2.4" "1.2.3"
    assert_success
}

@test "version_ge: lesser version returns failure" {
    run version_ge "1.2.3" "1.2.4"
    assert_failure
}

@test "version_ge: lesser major returns failure" {
    run version_ge "0.9.9" "1.0.0"
    assert_failure
}
