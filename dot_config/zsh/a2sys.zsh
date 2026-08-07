alias sshdev='gcloud compute ssh a2sys-shared-01 --zone=asia-northeast3-a --ssh-flag="-p 30022"'

function scpdev {
  if (( $# < 2 )); then
    print -u2 "usage: scpdev <src_path> [src_path...] <dst_path>"
    return 1
  fi

  local project="${GCP_PROJECT:-cs-poc-6qmyyhra03nr8izqgj3wecj}"
  local zone="${GCP_ZONE:-asia-northeast3-a}"
  local port="${GCP_PORT:-30022}"

  gcloud compute scp --recurse \
    --project "$project" \
    --zone "$zone" \
    --port "$port" \
    "$@"
}
