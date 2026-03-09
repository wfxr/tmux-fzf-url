#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "extract_urls: https URL" {
    run bash -c 'echo "visit https://example.com today" | extract_urls'
    assert_success
    assert_output "https://example.com"
}

@test "extract_urls: http URL" {
    run bash -c 'echo "visit http://example.com today" | extract_urls'
    assert_success
    assert_output "http://example.com"
}

@test "extract_urls: ftp URL" {
    run bash -c 'echo "download ftp://files.example.com/file.tar.gz" | extract_urls'
    assert_success
    assert_output "ftp://files.example.com/file.tar.gz"
}

@test "extract_urls: file URL" {
    run bash -c 'echo "open file:///home/user/doc.pdf" | extract_urls'
    assert_success
    assert_output "file:///home/user/doc.pdf"
}

@test "extract_urls: URL with query and fragment" {
    run bash -c 'echo "https://example.com/path?q=1&r=2#section" | extract_urls'
    assert_success
    assert_output "https://example.com/path?q=1&r=2#section"
}

@test "extract_urls: URL with port" {
    run bash -c 'echo "http://localhost:8080/api" | extract_urls'
    assert_success
    assert_output "http://localhost:8080/api"
}

@test "extract_urls: trailing period is stripped" {
    run bash -c 'echo "Visit https://example.com." | extract_urls'
    assert_success
    assert_output "https://example.com"
}

@test "extract_urls: trailing comma is stripped" {
    run bash -c 'echo "See https://example.com, and more" | extract_urls'
    assert_success
    assert_output "https://example.com"
}

@test "extract_urls: multiple URLs on one line" {
    run bash -c 'echo "https://a.com and https://b.com" | extract_urls'
    assert_success
    assert_line --index 0 "https://a.com"
    assert_line --index 1 "https://b.com"
}

@test "extract_urls: empty input produces no output" {
    run bash -c 'echo "" | extract_urls'
    assert_failure
    assert_output ""
}
