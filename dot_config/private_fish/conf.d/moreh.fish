# k8s
alias k "kubectl -n $KUBENS"
alias ka "k apply -f"
alias kdel "k delete"
alias kget "k get -o wide"
alias setkube "set -gx KUBECONFIG $(pwd)/kubeconfig.yaml"

function helm_reinstall
    if test (count $argv) -eq 1
        set -f target $argv[1]
    else if test (count $argv) -eq 2
        set -f target $argv[1]
        set -f filename $argv[2]
    else
        echo "Usage: helm_reinstall <target> [filename]"
    end

    helm_uninstall $target
    helm_install $target $filename
end

function helm_install
    helm repo add moreh https://moreh-dev.github.io/helm-charts
    helm repo update moreh

    if test (count $argv) -eq 1
        set -f target $argv[1]
    else if test (count $argv) -eq 2
        set -f target $argv[1]
        set -f filename $argv[2]
    else
        echo "Usage: helm_upgrade <target> [filename]"
    end

    switch $target
        case heimdall
            _upgrade_heimdall $filename
        case preset mif_preset
            _upgrade_mif_preset
        case norns
            _upgrade_norns
        case solver norns_solver
            _upgrade_norns_solver
        case '*'
            echo "Invalid target $target. <target> should be one of ['heimdall', 'preset', 'mif_preset', 'norns', 'solver', 'norns_solver']"
    end
end

function _upgrade_heimdall
    if test (count $argv) -eq 1
        set -f filename $argv[1]
    else
        set -f filename "heimdall-values.yaml"
    end
    set -f version_list (helm search repo moreh/heimdall -l | tail +2)

    for i in (seq (count $version_list))
        echo "  $i) $version_list[$i]"
    end
    read -P "Select version number: " choice
    if test $choice -ge 1 -a $choice -le (count $version_list)
        set -f target_version (echo $version_list[$choice] | awk '{print $2}')
        helm upgrade -i heimdall moreh/heimdall --version $version -n $KUBENS -f $filename
    else
        echo "Invalid selection"
        return 1
    end
end

function _upgrade_mif_preset
    set -f version_list (helm search repo moreh/moai-inference-preset -f | tail +2)

    for i in (seq (count $version_list))
        echo "  $i) $version_list[$i]"
    end
    read -P "Select version number: " choice
    if test $choice -ge 1 -a $choice -le (count $version_list)
        set -f target_version (echo $version_list[$choice] | awk '{print $2}')
        helm upgrade -i moai-inference-preset moreh/moai-inference-preset --version $target_version -n $KUBENS
    else
        echo "Invalid selection"
        return 1
    end
end

function _upgrade_norns
    helm upgrade -i norns /home/inhyeok/mif/norns/deploy/helm/norns -n $KUBENS -f /home/inhyeok/mif/norns/tmp/4-norns/norns-values.yaml
end

function _upgrade_norns_solver
    helm upgrade -i norns-solver /home/inhyeok/mif/norns/deploy/helm/norns-solver -n $KUBENS -f /home/inhyeok/mif/norns/tmp/3-norns-solver/norns-solver-values.yaml
end

function helm_uninstall
    if test (count $argv) -eq 1
        set -f target $argv[1]
    else
        echo "Usage: helm_uninstall <target>"
    end

    switch $target
        case heimdall
            helm uninstall heimdall -n $KUBENS
        case preset mif_preset
            helm uninstall moai-inference-preset -n $KUBENS
        case norns
            helm uninstall norns -n $KUBENS
        case solver norns_solver
            helm uninstall norns-solver -n $KUBENS
        case '*'
            echo "Invalid target $target. <target> should be one of ['heimdall', 'preset', 'mif_preset', 'norns', 'solver', 'norns_solver']"
    end
end
