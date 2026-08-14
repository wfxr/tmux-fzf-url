#!/usr/bin/env bats

setup() {
    load test_helper
}

# --- Plain text (no ANSI escape sequences) ---

@test "join: URL split across two lines" {
    input=$'https://example.com/very/long/path/that/gets\n  /split/here'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "https://example.com/very/long/path/that/gets/split/here"
}

@test "join: URL split across three lines" {
    input=$'https://example.com/path\n  /continued\n  /again'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "https://example.com/path/continued/again"
}

@test "join: continuation with tab indent" {
    input=$'https://example.com/path\n\t/continued'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "https://example.com/path/continued"
}

@test "join: non-URL line is not joined" {
    input=$'some plain text\n  more text'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_line --index 0 "some plain text"
    assert_line --index 1 "  more text"
}

@test "join: line after URL without leading whitespace is not joined" {
    input=$'https://example.com/path\nnot-a-continuation'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_line --index 0 "https://example.com/path"
    assert_line --index 1 "not-a-continuation"
}

@test "join: URL on single line passes through unchanged" {
    run bash -c 'echo "https://example.com/complete" | join_wrapped_urls'
    assert_success
    assert_output "https://example.com/complete"
}

@test "join: mixed URL and non-URL lines" {
    input=$'before\nhttps://example.com/long\n  /path\nafter'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_line --index 0 "before"
    assert_line --index 1 "https://example.com/long/path"
    assert_line --index 2 "after"
}

@test "join: multiple split URLs in same input" {
    input=$'https://a.com/long\n  /path1\nhttps://b.com/long\n  /path2'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_line --index 0 "https://a.com/long/path1"
    assert_line --index 1 "https://b.com/long/path2"
}

@test "join: ftp URL is also joined" {
    input=$'ftp://files.example.com/large\n  /file.tar.gz'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "ftp://files.example.com/large/file.tar.gz"
}

@test "join: file URL is also joined" {
    input=$'file:///home/user/documents\n  /report.pdf'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "file:///home/user/documents/report.pdf"
}

@test "join: URL with query params split across lines" {
    input=$'https://example.com/search?q=hello\n  &page=2&lang=en'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "https://example.com/search?q=hello&page=2&lang=en"
}

@test "join: empty input produces no output" {
    run bash -c 'echo "" | join_wrapped_urls'
    assert_success
    assert_output ""
}

# --- With ANSI escape sequences ---

@test "join: ANSI-wrapped URL split across lines" {
    input=$'\x1b[32mhttps://example.com/very/long\x1b[0m\n\x1b[32m  /path/here\x1b[0m'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "https://example.com/very/long/path/here"
}

@test "join: ANSI escapes stripped from non-split URL" {
    run bash -c 'printf "\x1b[1;34mhttps://example.com\x1b[0m\n" | join_wrapped_urls'
    assert_success
    assert_output "https://example.com"
}

@test "join: ANSI escapes on continuation lines are stripped" {
    input=$'https://example.com/path\n  \x1b[33m/continued\x1b[0m'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "https://example.com/path/continued"
}

@test "join: mixed ANSI and plain lines" {
    input=$'\x1b[36mhttps://a.com/split\x1b[0m\n  /end\nplain text\nhttps://b.com/whole'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_line --index 0 "https://a.com/split/end"
    assert_line --index 1 "plain text"
    assert_line --index 2 "https://b.com/whole"
}

@test "join: heavy ANSI escapes with multiple params" {
    input=$'\x1b[1;4;38;2;255;100;0mhttps://example.com/styled\x1b[0m\n\x1b[1m  /more\x1b[0m'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_output "https://example.com/styled/more"
}

@test "join: ANSI on non-URL line does not trigger joining" {
    input=$'\x1b[31msome error message\x1b[0m\n  indented line'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls' _ "$input"
    assert_success
    assert_line --index 0 "some error message"
    assert_line --index 1 "  indented line"
}

# --- End-to-end: join + extract ---

@test "e2e: split URL is joined then extracted" {
    input=$'check https://example.com/very/long\n  /path/to/resource today'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls | xre_extract' _ "$input"
    assert_success
    assert_output "https://example.com/very/long/path/to/resource"
}

@test "e2e: ANSI-wrapped split URL is joined then extracted" {
    input=$'\x1b[32mhttps://example.com/long\x1b[0m\n\x1b[32m  /path\x1b[0m'
    run bash -c 'printf "%s\n" "$1" | join_wrapped_urls | xre_extract' _ "$input"
    assert_success
    assert_output "https://example.com/long/path"
}
