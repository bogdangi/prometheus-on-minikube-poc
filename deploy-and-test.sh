#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

APP_NAME=prometheus-app-random-metric-go
NAMESPACE=default

source $DIR/utils.sh
source $DIR/fixtures.sh

echo Deploy prometheus
deploy_app prometheus 90s monitoring

echo Deploy $APP_NAME
deploy_app $APP_NAME 30s $NAMESPACE

echo Wait for all targets to be ready
retry 30 wait_for_targets_to_be_ready $APP_NAME 3

echo Run tests
test_number_of_metrics_for_query 'app_random_metric{app="'$APP_NAME'"}' 3 \
        && printf "[PASS]\t" \
        || printf "[FAIL]\t"
echo "Check number of metrics"
