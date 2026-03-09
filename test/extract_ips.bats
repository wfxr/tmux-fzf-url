#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "extract_ips: bare IP address" {
    run bash -c 'echo "connect to 192.168.1.1" | extract_ips'
    assert_success
    assert_output "http://192.168.1.1"
}

@test "extract_ips: IP with port" {
    run bash -c 'echo "server at 10.0.0.1:8080" | extract_ips'
    assert_success
    assert_output "http://10.0.0.1:8080"
}

@test "extract_ips: IP with port and path" {
    run bash -c 'echo "api at 10.0.0.1:3000/api/v1" | extract_ips'
    assert_success
    assert_output "http://10.0.0.1:3000/api/v1"
}

@test "extract_ips: IP with path" {
    run bash -c 'echo "see 172.16.0.1/status" | extract_ips'
    assert_success
    assert_output "http://172.16.0.1/status"
}

@test "extract_ips: empty input produces no output" {
    run bash -c 'echo "" | extract_ips'
    assert_success
    assert_output ""
}
