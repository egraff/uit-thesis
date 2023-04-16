#!/usr/bin/env bash

# Exit on failure, verbose
set -ev

if [[ ! -z "$APPVEYOR_PULL_REQUEST_NUMBER" ]]; then
  # Likely a pull request from a forked repository.
  # Committing the test results can only be done when secure environment
  # variables are available.
  echo "Insecure environment, test result will not be persisted..."
  exit 0
fi

# Make sure we're in the top directory
cd $APPVEYOR_BUILD_FOLDER

# Create a new temp directory for committing test results to gh-pages branch
GH_PAGES=$(mktemp -d)
JOB_DIR=${GH_PAGES}/appveyor-builds/${APPVEYOR_BUILD_NUMBER}.${APPVEYOR_JOB_NUMBER}
mkdir -p $JOB_DIR


pushd $GH_PAGES

git init
git config core.autocrlf true
git config user.name "AppVeyor"
git config user.email "appveyor@appveyor.com"
git config remote.origin.url git@github.com:egraff/uit-thesis.git
git config remote.origin.fetch +refs/heads/gh-pages:refs/remotes/origin/gh-pages
git config branch.gh-pages.remote origin
git config branch.gh-pages.merge refs/heads/gh-pages

git fetch
git checkout -l -f -q -b gh-pages origin/gh-pages

popd


cat <<EOF > $JOB_DIR/index.md
---
layout: appveyor-build
appveyor:
  branch: ${APPVEYOR_REPO_BRANCH}
  build-id: ${APPVEYOR_BUILD_ID}
  build-number: ${APPVEYOR_BUILD_NUMBER}
  commit: ${APPVEYOR_REPO_COMMIT}
  job-id: ${APPVEYOR_JOB_ID}
  job-number: ${APPVEYOR_JOB_NUMBER}
  os-name: Ubuntu
  test-result: $1
---
EOF

rsync --archive test/.build/ $JOB_DIR/build/
rsync --archive test/diffs/ $JOB_DIR/diffs/ || true
rsync --archive test/tmp/tests/ $JOB_DIR/tests/ || true
rsync --archive test/tmp/proto/ $JOB_DIR/proto/ || true

cp test/test_result.json $GH_PAGES/_data/appveyor-builds/${APPVEYOR_BUILD_NUMBER}_${APPVEYOR_JOB_NUMBER}.json

pushd $GH_PAGES

git add --all .
git commit -m "AppVeyor: test results from job ${APPVEYOR_BUILD_NUMBER}.${APPVEYOR_JOB_NUMBER}"

# Allow command to fail (no exit on failure)
set +e

maxAttempts=10
numAttempts=0
success=0
while (( numAttempts != maxAttempts )); do
  numAttempts=$(( numAttempts + 1 ))
  git push -q origin gh-pages
  if [ "$?" != "0" ]; then
    git pull --rebase origin gh-pages
  else
    success=1
    break
  fi
done

popd
