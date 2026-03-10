# k8s
alias k='kubectl -n $KUBENS'
alias ka='kubectl -n $KUBENS apply -f'
alias kdel='kubectl -n $KUBENS delete'
alias kget='kubectl -n $KUBENS get -o wide'
alias setkube='export KUBECONFIG=$(pwd)/kubeconfig.yaml'

function helm_reinstall() {
  if [[ $# -eq 1 ]]; then
    local target=$1
  elif [[ $# -eq 2 ]]; then
    local target=$1
    local filename=$2
  else
    echo "Usage: helm_reinstall <target> [filename]"
    return 1
  fi

  helm_uninstall "$target"
  helm_install "$target" "$filename"
}

function helm_install() {
  helm repo add moreh https://moreh-dev.github.io/helm-charts
  helm repo update moreh

  if [[ $# -eq 1 ]]; then
    local target=$1
  elif [[ $# -eq 2 ]]; then
    local target=$1
    local filename=$2
  else
    echo "Usage: helm_install <target> [filename]"
    return 1
  fi

  case "$target" in
    heimdall)              _upgrade_heimdall "$filename" ;;
    preset|mif_preset)     _upgrade_mif_preset ;;
    norns)                 _upgrade_norns ;;
    solver|norns_solver)   _upgrade_norns_solver ;;
    *)
      echo "Invalid target $target. <target> should be one of ['heimdall', 'preset', 'mif_preset', 'norns', 'solver', 'norns_solver']"
      return 1
      ;;
  esac
}

function _upgrade_heimdall() {
  local filename="${1:-heimdall-values.yaml}"
  local version_list
  mapfile -t version_list < <(helm search repo moreh/heimdall -l | tail -n +2)

  local i
  for i in "${!version_list[@]}"; do
    echo "  $((i+1))) ${version_list[$i]}"
  done

  local choice
  read -r -p "Select version number: " choice
  if [[ $choice -ge 1 && $choice -le ${#version_list[@]} ]]; then
    local target_version
    target_version=$(echo "${version_list[$((choice-1))]}" | awk '{print $2}')
    helm upgrade -i heimdall moreh/heimdall --version "$target_version" -n "$KUBENS" -f "$filename"
  else
    echo "Invalid selection"
    return 1
  fi
}

function _upgrade_mif_preset() {
  local version_list
  mapfile -t version_list < <(helm search repo moreh/moai-inference-preset -l | tail -n +2)

  local i
  for i in "${!version_list[@]}"; do
    echo "  $((i+1))) ${version_list[$i]}"
  done

  local choice
  read -r -p "Select version number: " choice
  if [[ $choice -ge 1 && $choice -le ${#version_list[@]} ]]; then
    local target_version
    target_version=$(echo "${version_list[$((choice-1))]}" | awk '{print $2}')
    helm upgrade -i moai-inference-preset moreh/moai-inference-preset --version "$target_version" -n "$KUBENS"
  else
    echo "Invalid selection"
    return 1
  fi
}

function _upgrade_norns() {
  helm upgrade -i norns /home/inhyeok/mif/norns/deploy/helm/norns \
    -n "$KUBENS" -f /home/inhyeok/mif/norns/tmp/4-norns/norns-values.yaml
}

function _upgrade_norns_solver() {
  helm upgrade -i norns-solver /home/inhyeok/mif/norns/deploy/helm/norns-solver \
    -n "$KUBENS" -f /home/inhyeok/mif/norns/tmp/3-norns-solver/norns-solver-values.yaml
}

function helm_uninstall() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: helm_uninstall <target>"
    return 1
  fi

  local target=$1
  case "$target" in
    heimdall)            helm uninstall heimdall -n "$KUBENS" ;;
    preset|mif_preset)   helm uninstall moai-inference-preset -n "$KUBENS" ;;
    norns)               helm uninstall norns -n "$KUBENS" ;;
    solver|norns_solver) helm uninstall norns-solver -n "$KUBENS" ;;
    *)
      echo "Invalid target $target. <target> should be one of ['heimdall', 'preset', 'mif_preset', 'norns', 'solver', 'norns_solver']"
      return 1
      ;;
  esac
}
