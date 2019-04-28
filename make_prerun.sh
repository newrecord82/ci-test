#!/usr/bin/env bash

make_local_properties() {

    local_properties="./local.properties"
    if [[ -e "${local_properties}" ]]; then
            echo "exist local.properties"
        else
            echo "not exist local.properties"
            echo "create local.properties"
            echo 'sdk.dir=/Users/newrecord/Library/Android/sdk' > ${local_properties}
    fi

}


make_local_properties
exit 0