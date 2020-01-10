function deploy_app {
        local app_name=$1
        local timeout=$2
        local namespace=${3:-default}

        kubectl apply -f k8s/$app_name
        kubectl wait \
                --for=condition=available \
                --timeout=$timeout \
                --namespace=$namespace \
                deployment/$app_name
}

function get_prometheus_url {
        minikube service -n monitoring prometheus --url
}

function wait_for_targets_to_be_ready {
        local prometheus_url=$(get_prometheus_url)

        local label_app=$1
        local number_of_targets=$2

        curl "$prometheus_url/api/v1/targets?state=active" -s | \
                jq -c '.data.activeTargets[] | select( .health == "up" and .labels.app == "'$label_app'") | .health' |\
                wc -l |\
                xargs test $number_of_targets -eq 

}

function test_number_of_metrics_for_query {
        local prometheus_url=$(get_prometheus_url)

        local query=$1
        local number_of_metrics=$2

        curl "$prometheus_url/api/v1/query?query=$(urlencode $query)" -s | \
                jq .data.result[].value[1] | \
                wc -l |\
                xargs test $number_of_metrics -eq 
}
