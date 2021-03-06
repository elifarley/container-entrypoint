test "$DEBUG" && set -x

process_env_file() {
  local env_file="$1"
  local to_export="$2"

  local name="$(basename "$env_file")"; local val="$(cat "$env_file")"
  echo "$name='$val'"
  test "$to_export" && export "$name"="$val"
  printf "%s=%s\n" "$name" "$val" >> "$SSH_ENVIRONMENT_FILE"
}

setup_env_vars() {
  local ENV_VARS_DIR="${ENV_VARS_DIR:-/data/env-vars}"
  local PHUSION_ENV_DIR=/etc/container_environment
  local SSH_ENVIRONMENT_FILE="$HOME"/.ssh/environment

  test -s "$HOME"/build-info.txt && {
    cat "$HOME"/build-info.txt >> "$SSH_ENVIRONMENT_FILE"
    while read -r line; do
      test "$line" || continue
      eval export $line
    done < "$HOME"/build-info.txt
  }

  test -d /etc/profile.d && test "$(ls -A /etc/profile.d)" && \
    for v in /etc/profile.d/*; do . "$v"; done

  test -d "$ENV_VARS_DIR" && test "$(ls -A "$ENV_VARS_DIR")" || {
    echo "No env var files at '$ENV_VARS_DIR'"
    ENV_VARS_DIR=/mnt-env-vars
    test -d "$ENV_VARS_DIR" && test "$(ls -A "$ENV_VARS_DIR")" || {
      echo "No env var files at '$ENV_VARS_DIR'"
      return
    }
  }

  test -d "$PHUSION_ENV_DIR" && {
    echo "Copying env var files from '$ENV_VARS_DIR' to '$PHUSION_ENV_DIR'..."
    cp -av "$ENV_VARS_DIR"/* "$PHUSION_ENV_DIR"
    for v in "$ENV_VARS_DIR"/*; do
      process_env_file "$v"
    done
    return
  }

  echo "Loading env var files from '$ENV_VARS_DIR'..."
  for v in "$ENV_VARS_DIR"/*; do
    process_env_file "$v" true
  done
}
