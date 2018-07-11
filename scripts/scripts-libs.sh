# Determine the distribution we are running on, so that we can configure it
# appropriately.
function determine_distro {
    source /etc/os-release 2>/dev/null
    export DISTRO_ID="${ID}"
    export DISTRO_NAME="${NAME}"
    export DISTRO_VERSION_ID="${VERSION_ID}"
}

function ssh_key_create {
  # Ensure that the ssh key exists and is an authorized_key
  key_path="${HOME}/.ssh"
  key_file="${key_path}/id_rsa"

  # Ensure that the .ssh directory exists and has the right mode
  if [ ! -d ${key_path} ]; then
    mkdir -p ${key_path}
    chmod 700 ${key_path}
  fi
  if [ ! -f "${key_file}" -a ! -f "${key_file}.pub" ]; then
    rm -f ${key_file}*
    ssh-keygen -t rsa -f ${key_file} -N ''
  fi

  # Ensure that the public key is included in the authorized_keys
  # for the default root directory and the current home directory
  key_content=$(cat "${key_file}.pub")
  if ! grep -q "${key_content}" ${key_path}/authorized_keys; then
    echo "${key_content}" | tee -a ${key_path}/authorized_keys
  fi
}

function get_pip {

  # The python executable to use when executing get-pip is passed
  # as a parameter to this function.
  GETPIP_PYTHON_EXEC_PATH="${1:-$(which python)}"

  # Download the get-pip script using the primary or secondary URL
  GETPIP_CMD="curl --silent --show-error --retry 5"
  GETPIP_FILE="/opt/get-pip.py"
  # If GET_PIP_URL is set, then just use it
  if [ -n "${GET_PIP_URL:-}" ]; then
    ${GETPIP_CMD} ${GET_PIP_URL} > ${GETPIP_FILE}
  else
    # Otherwise, try the two standard URL's
    ${GETPIP_CMD} https://bootstrap.pypa.io/3.2/get-pip.py > ${GETPIP_FILE}\
      || ${GETPIP_CMD} https://raw.githubusercontent.com/pypa/get-pip/master/3.2/get-pip.py > ${GETPIP_FILE}
  fi

  ${GETPIP_PYTHON_EXEC_PATH} ${GETPIP_FILE} \
    pip setuptools wheel \
    --constraint global-requirement-pins.txt \
    || ${GETPIP_PYTHON_EXEC_PATH} ${GETPIP_FILE} \
         pip setuptools wheel \
         --constraint global-requirement-pins.txt \
         --isolated
}
