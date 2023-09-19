setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export PROJNAME=test-swagger-ui
  export DDEV_NON_INTERACTIVE=true
  export TESTDIR=~/tmp/${PROJNAME}
  mkdir -p $TESTDIR
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

health_checks() {
  set +u # bats-assert has unset variables so turn off unset check
  # Do something useful here that verifies the add-on

  # Make sure we can hit the 8080 port successfully from outside
  curl -s -I -f  https://${PROJNAME}.ddev.site:8080 >/tmp/curlout.txt

  # Make sure we can hit the 8080 port successfully from inside
  ddev exec "curl -s --fail http://localhost:8080"

  # Make sure we can hit the 8080 port successfully from outside
  assert_output "FULLURL https://${PROJNAME}.ddev.site:8080"
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  health_checks
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get ddev/ddev-swagger-ui with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ddev/ddev-swagger-ui
  ddev restart >/dev/null
  health_checks
}

