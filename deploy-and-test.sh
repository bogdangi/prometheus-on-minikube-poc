#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/utils.sh
source $DIR/fixtures.sh

echo Deploy prometheus
deploy_prometheus
echo Deploy app
deploy_app

echo Wait for all targets to be ready
retry 30 wait_for_targets_to_be_ready prometheus-app-random-metric-go 3

echo Run tests
test_number_of_metrics_for_query 'app_random_metric{app="prometheus-app-random-metric-go"}' 3 \
        && printf "[PASS]\t" \
        || printf "[FAIL]\t"
echo "Check number of metrics"
