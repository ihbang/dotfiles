alias vi nvim
alias claude "SHELL=/bin/bash command claude"

# k8s
alias k "kubectl -n cluster"
alias setkube "set -gx KUBECONFIG $(pwd)/kubeconfig.yaml"

## run inference service
function krun
    if test (count $argv) -ne 2
        echo "Usage: krun <prefill_replicas> <decode_replicas>"
        return 1
    end

    set -l prefill_replicas $argv[1]
    set -l decode_replicas $argv[2]

    echo "Deploying inference-service with prefill=$prefill_replicas, decode=$decode_replicas"
    helm upgrade -i inference-service moreh/inference-service \
        --version v0.6.1 \
        -n cluster \
        -f inference-service-values.yaml \
        --set prefill.replicas=$prefill_replicas \
        --set decode.replicas=$decode_replicas
end

## print list of pods
alias kls "k get pod -o wide"

## watch logs
function klog
    if test (count $argv) -eq 0
        echo "Usage: klog <search_string>"
        return 1
    end

    set -l search_term $argv[1]
    set -l pod_info (kubectl -n cluster get pod --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName" | grep $search_term | grep -E "Running|Succeeded|Failed")

    if test (count $pod_info) -eq 0
        echo "No pod with logs found matching '$search_term' (Running/Succeeded/Failed only)"
        return 1
    else if test (count $pod_info) -eq 1
        set -l pod_name (echo $pod_info[1] | awk '{print $1}')
        echo "Found pod: $pod_name"
        kubectl -n cluster logs -f $pod_name
    else
        echo "Multiple pods found:"
        for i in (seq (count $pod_info))
            echo "  $i) $pod_info[$i]"
        end
        read -P "Select pod number: " choice
        if test $choice -ge 1 -a $choice -le (count $pod_info)
            set -l pod_name (echo $pod_info[$choice] | awk '{print $1}')
            kubectl -n cluster logs -f $pod_name
        else
            echo "Invalid selection"
            return 1
        end
    end
end

## describe a status of pod
function kdesc
    if test (count $argv) -eq 0
        echo "Usage: kdesc <search_string>"
        return 1
    end

    set -l search_term $argv[1]
    set -l pod_info (kubectl -n cluster get pod --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName" | grep $search_term)

    if test (count $pod_info) -eq 0
        echo "No pod found matching '$search_term'"
        return 1
    else if test (count $pod_info) -eq 1
        set -l pod_name (echo $pod_info[1] | awk '{print $1}')
        echo "Describing pod: $pod_name"
        kubectl -n cluster describe pod $pod_name
    else
        echo "Multiple pods found:"
        for i in (seq (count $pod_info))
            echo "  $i) $pod_info[$i]"
        end
        read -P "Select pod number: " choice
        if test $choice -ge 1 -a $choice -le (count $pod_info)
            set -l pod_name (echo $pod_info[$choice] | awk '{print $1}')
            kubectl -n cluster describe pod $pod_name
        else
            echo "Invalid selection"
            return 1
        end
    end
end

## attach to pod
function kattach
    if test (count $argv) -eq 0
        echo "Usage: kattach <search_string>"
        return 1
    end

    set -l search_term $argv[1]
    set -l pod_info (kubectl -n cluster get pod --no-headers -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName" | grep $search_term | grep Running)

    if test (count $pod_info) -eq 0
        echo "No running pod found matching '$search_term'"
        return 1
    else if test (count $pod_info) -eq 1
        set -l pod_name (echo $pod_info[1] | awk '{print $1}')
        echo "Attaching to pod: $pod_name"
        kubectl -n cluster exec -it $pod_name -- bash
    else
        echo "Multiple running pods found:"
        for i in (seq (count $pod_info))
            echo "  $i) $pod_info[$i]"
        end
        read -P "Select pod number: " choice
        if test $choice -ge 1 -a $choice -le (count $pod_info)
            set -l pod_name (echo $pod_info[$choice] | awk '{print $1}')
            kubectl -n cluster exec -it $pod_name -- bash
        else
            echo "Invalid selection"
            return 1
        end
    end
end

## clear prefill and decode pods
alias kclp "k patch deploy inference-service-prefill --type=merge -p '{\"spec\":{\"replicas\": 0}}'"
alias kcld "k patch deploy inference-service-decode --type=merge -p '{\"spec\":{\"replicas\": 0}}'"
alias kcl "kclp && kcld"
