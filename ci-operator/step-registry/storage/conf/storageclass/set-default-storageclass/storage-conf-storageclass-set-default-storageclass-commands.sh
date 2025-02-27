#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

function set_proxy () {
    if test -s "${SHARED_DIR}/proxy-conf.sh" ; then
        echo "setting the proxy"
        echo "source ${SHARED_DIR}/proxy-conf.sh"
        source "${SHARED_DIR}/proxy-conf.sh"
    else
        echo "no proxy setting."
    fi
}

function run_command() {
    local CMD="$1"
    echo "Running Command: ${CMD}"
    eval "${CMD}"
}

function get_current_sc() {
    run_command "oc get sc"
}

function get_default_sc() {
    CURRENT_DEFAULT_SC=$(oc get sc -ojsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')
    echo "Current default storageclass is:" "${CURRENT_DEFAULT_SC}"
}

function remove_all_default_sc_annotations () {
  run_command "oc annotate sc storageclass.kubernetes.io/is-default-class=false --all --overwrite"
}

function set_required_sc_as_default () {
  run_command "oc annotate sc ${REQUIRED_DEFAULT_STORAGECLASS} storageclass.kubernetes.io/is-default-class=true --overwrite"
}

set_proxy
get_default_sc
remove_all_default_sc_annotations
set_required_sc_as_default
# For debugging
get_current_sc
