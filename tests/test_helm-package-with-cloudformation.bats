#!/usr/bin/env bats
# vim: set ft=sh sw=4 :

load helper_print-info

function cleanup {
    rm -f *.tgz
}

@test "fails if no chart name given" {
    cleanup

    run ./helm-package-with-cloudformation.sh

    print_run_info
    [ "$status" -eq 11 ] &&
    [[ "$output" = *"Input 'name' not provided"* ]]
}

@test "fails if no version given" {
    cleanup

    run ./helm-package-with-cloudformation.sh

    print_run_info
    [ "$status" -eq 11 ] &&
    [[ "$output" = *"Input 'version' not provided"* ]]
}

@test "fails if chart dir does not exist" {
    cleanup

    export INPUT_NAME=does_not_exist
    export INPUT_VERSION=0.0.0

    run ./helm-package-with-cloudformation.sh

    print_run_info
    [ "$status" -eq 13 ] &&
    [[ "$output" = *"Chart directory 'helm/does_not_exist' not found"* ]]
}

@test "packages a chart without cloudformation" {
    cleanup

    export INPUT_NAME=no-cfn
    export INPUT_VERSION=1.0.0-test
    export INPUT_CHART_DIR=tests/data/chart-no-cfn

    run ./helm-package-with-cloudformation.sh

    print_run_info
    [ "$status" -eq 0 ] &&
    [[ "$output" = *"::set-output name=chart::no-cfn-1.0.0-test.tgz"* ]]
}

@test "fails if chart tgz isn't found" {
    cleanup

    export INPUT_NAME=not-correct-name
    export INPUT_VERSION=1.0.0-test
    export INPUT_CHART_DIR=tests/data/chart-no-cfn

    run ./helm-package-with-cloudformation.sh

    print_run_info
    [ "$status" -eq 15 ] &&
    [[ "$output" = *"does not match the name input to this action"* ]]
}

@test "cleanup" {
    cleanup
}
