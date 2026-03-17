#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "extract: https URL" {
    run bash -c 'echo "visit https://example.com today" | xre_extract'
    assert_success
    assert_output "https://example.com"
}

@test "extract: http URL" {
    run bash -c 'echo "visit http://example.com today" | xre_extract'
    assert_success
    assert_output "http://example.com"
}

@test "extract: ftp URL" {
    run bash -c 'echo "download ftp://files.example.com/file.tar.gz" | xre_extract'
    assert_success
    assert_output "ftp://files.example.com/file.tar.gz"
}

@test "extract: file URL" {
    run bash -c 'echo "open file:///home/user/doc.pdf" | xre_extract'
    assert_success
    assert_output "file:///home/user/doc.pdf"
}

@test "extract: URL with query and fragment" {
    run bash -c 'echo "https://example.com/path?q=1&r=2#section" | xre_extract'
    assert_success
    assert_output "https://example.com/path?q=1&r=2#section"
}

@test "extract: trailing period is stripped" {
    run bash -c 'echo "Visit https://example.com." | xre_extract'
    assert_success
    assert_output "https://example.com"
}

@test "extract: trailing comma is stripped" {
    run bash -c 'echo "See https://example.com, and more" | xre_extract'
    assert_success
    assert_output "https://example.com"
}

@test "extract: multiple URLs on one line" {
    run bash -c 'echo "https://a.com and https://b.com" | xre_extract'
    assert_success
    assert_line --index 0 "https://a.com"
    assert_line --index 1 "https://b.com"
}

@test "extract: git SSH URL" {
    run bash -c 'echo "git@github.com:user/repo.git" | xre_extract'
    assert_success
    assert_output "https://github.com/user/repo.git"
}

@test "extract: ssh:// prefix git URL" {
    run bash -c 'echo "ssh://git@github.com/user/repo.git" | xre_extract'
    assert_success
    assert_output "https://github.com/user/repo.git"
}

@test "extract: gitlab SSH URL" {
    run bash -c 'echo "git@gitlab.com:group/project.git" | xre_extract'
    assert_success
    assert_output "https://gitlab.com/group/project.git"
}

@test "extract: bare www domain" {
    run bash -c 'echo "visit www.example.com" | xre_extract'
    assert_success
    assert_output "http://www.example.com"
}

@test "extract: www with path" {
    run bash -c 'echo "see www.example.com/path/to/page" | xre_extract'
    assert_success
    assert_output "http://www.example.com/path/to/page"
}

@test "extract: bare IP address" {
    run bash -c 'echo "connect to 192.168.1.1" | xre_extract'
    assert_success
    assert_output "http://192.168.1.1"
}

@test "extract: IP with port" {
    run bash -c 'echo "server at 10.0.0.1:8080" | xre_extract'
    assert_success
    assert_output "http://10.0.0.1:8080"
}

@test "extract: IP with port and path" {
    run bash -c 'echo "api at 10.0.0.1:3000/api/v1" | xre_extract'
    assert_success
    assert_output "http://10.0.0.1:3000/api/v1"
}

@test "extract: single-quoted GitHub shorthand" {
    run bash -c "echo \"'user/repo'\" | xre_extract"
    assert_success
    assert_output "https://github.com/user/repo"
}

@test "extract: double-quoted GitHub shorthand" {
    run bash -c 'echo "\"user/repo\"" | xre_extract'
    assert_success
    assert_output "https://github.com/user/repo"
}

@test "extract: GitHub shorthand with hyphens" {
    run bash -c "echo \"'my-org/my-repo'\" | xre_extract"
    assert_success
    assert_output "https://github.com/my-org/my-repo"
}

@test "extract: mixed URL types" {
    input="visit https://example.com and www.test.com and 192.168.1.1"
    run bash -c "echo '$input' | xre_extract"
    assert_success
    assert_line --index 0 "https://example.com"
    assert_line --index 1 "http://www.test.com"
    assert_line --index 2 "http://192.168.1.1"
}

@test "extract: deduplicates URLs" {
    input=$'https://example.com\nhttps://example.com\nhttps://example.com'
    run bash -c "echo '$input' | xre_extract"
    assert_success
    assert_output "https://example.com"
}

@test "extract: https://www not duplicated by www pattern" {
    run bash -c 'echo "https://www.example.com" | xre_extract'
    assert_success
    assert_output "https://www.example.com"
}

@test "extract: ANSI-wrapped URL is extracted" {
    run bash -c 'printf '"'"'\e[32mhttps://example.com\e[0m'"'"' | xre_extract'
    assert_success
    assert_output "https://example.com"
}

@test "extract: empty input produces no output" {
    run bash -c 'echo "" | xre_extract'
    assert_success
    assert_output ""
}
