#!/bin/bash

dirname=${0%/*}

run_test () {

    cd $dirname

    preparation

    generate_entry

    result=`run_app`

    remove_generated_js

    evaluate_result $result
}

preparation () {
    rm -f "src/domain/master-data/all.json"
}

generate_entry () {
    ./node_modules/.bin/bd-generate-entry src/facade.js src/domain
}

run_app () {
    result=`node app.js`
    echo $result
}

remove_generated_js () {
    rm -f "src/entry.js"
}

evaluate_result () {
    result="$*"

    expected="coke"

    if [[ $result == $expected ]]; then
        echo 'generate-entry succeeded!'
        exit 0
    else
        echo 'generate-entry failed'
        exit 1
    fi
}

run_test
