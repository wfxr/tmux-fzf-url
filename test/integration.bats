#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "integration: extracts mixed URL types" {
    input="visit https://example.com and www.test.com and 192.168.1.1"
    urls=$(echo "$input" | extract_urls)
    wwws=$(echo "$input" | extract_wwws)
    ips=$(echo "$input" | extract_ips)

    result=$(printf '%s\n' "$urls" "$wwws" "$ips" | grep -v '^$' | sort -u)
    assert [ "$(echo "$result" | wc -l)" -ge 3 ]
}

@test "integration: deduplicates URLs" {
    input=$'https://example.com\nhttps://example.com\nhttps://example.com'
    result=$(echo "$input" | extract_urls | sort -u)
    assert_equal "$(echo "$result" | wc -l | tr -d ' ')" "1"
}

@test "integration: https://www not duplicated with www extractor" {
    input="https://www.example.com"
    urls=$(echo "$input" | extract_urls)
    wwws=$(echo "$input" | extract_wwws)
    # extract_urls should find it, extract_wwws should NOT (filtered by grep -vE)
    assert [ -n "$urls" ]
    assert [ -z "$wwws" ]
}

@test "integration: empty content produces no output" {
    run bash -c 'echo "" | extract_urls'
    assert_failure
    assert_output ""
}

@test "integration: ANSI-wrapped URL is extracted after stripping" {
    input=$(printf '\e[32mhttps://example.com\e[0m')
    cleaned=$(echo "$input" | strip_ansi)
    run bash -c "echo '$cleaned' | extract_urls"
    assert_success
    assert_output "https://example.com"
}

@test "reverse_dedup: reverses and deduplicates" {
    input=$'a\nb\nc\nb\na'
    run bash -c "echo '$input' | reverse_dedup"
    assert_success
    assert_output $'a\nb\nc'
}

@test "reverse_dedup: single item" {
    run bash -c "echo 'only' | reverse_dedup"
    assert_success
    assert_output "only"
}

@test "reverse_dedup: all duplicates" {
    input=$'x\nx\nx'
    run bash -c "echo '$input' | reverse_dedup"
    assert_success
    assert_output "x"
}

@test "reverse_dedup: recency ordering puts last-appearing URL first" {
    input=$'https://old.com\nhttps://mid.com\nhttps://new.com'
    run bash -c "echo '$input' | reverse_dedup"
    assert_success
    assert_line -n 0 "https://new.com"
    assert_line -n 1 "https://mid.com"
    assert_line -n 2 "https://old.com"
}
