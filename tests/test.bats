setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-swagger-ui
  mkdir -p $TESTDIR
  export PROJNAME=test-swagger-ui
  export ADDON_PATH="reloxx13/ddev-swagger-ui"
  export USE_VERSION8=false
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

execute_test() {
  echo "# ddev get ${ADDON_PATH} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${ADDON_PATH} >/dev/null
  ddev restart >/dev/null
  health_checks
}

health_checks() {
  ddev exec "curl -s swagger-ui:8080" | grep "${PROJNAME}-swagger-ui"
}

teardown() {
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  ADDON_PATH="${DIR}"
  execute_test
}

@test "install from release" {
  execute_test
}
