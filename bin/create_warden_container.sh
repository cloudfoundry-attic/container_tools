#!/bin/bash
(
    cd "$( dirname "${BASH_SOURCE[0]}" )"/..
    bundle > /dev/null
    bundle exec bin/create_warden_container.rb "$@"
)
