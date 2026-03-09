#!/usr/bin/env bats

setup() {
    load test_helper
}

@test "extract_gits: standard git SSH URL" {
    run bash -c 'echo "git@github.com:user/repo.git" | extract_gits'
    assert_success
    assert_output "https://github.com/user/repo.git"
}

@test "extract_gits: ssh:// prefix git URL" {
    run bash -c 'echo "ssh://git@github.com/user/repo.git" | extract_gits'
    assert_success
    assert_output "https://github.com/user/repo.git"
}

@test "extract_gits: gitlab SSH URL" {
    run bash -c 'echo "git@gitlab.com:group/project.git" | extract_gits'
    assert_success
    assert_output "https://gitlab.com/group/project.git"
}

@test "extract_gits: quoted git URL strips quotes" {
    run bash -c "echo '\"git@github.com:user/repo.git\"' | extract_gits"
    assert_success
    assert_output "https://github.com/user/repo.git"
    run bash -c "echo \"'git@github.com:user/repo.git'\" | extract_gits"
    assert_success
    assert_output "https://github.com/user/repo.git"
    run bash -c 'echo "\`git@github.com:user/repo.git\`" | extract_gits'
    assert_success
    assert_output "https://github.com/user/repo.git"
}

@test "extract_gits: non git@ input produces no output" {
    run bash -c 'echo "https://github.com/user/repo" | extract_gits'
    assert_success
    assert_output ""
}

@test "extract_gits: empty input produces no output" {
    run bash -c 'echo "" | extract_gits'
    assert_success
    assert_output ""
}
