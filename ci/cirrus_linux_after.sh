#!/usr/bin/env bash

# Exit on failure, verbose
set -ev

if [[ ! -z "$CIRRUS_PR" ]]; then
  # Likely a pull request from a forked repository.
  # Committing the test results can only be done when secure environment
  # variables are available.
  echo "Insecure environment, test result will not be persisted..."
  exit 0
fi

# Make sure we're in the top directory
cd $CIRRUS_WORKING_DIR

# Create a new temp directory for committing test results to gh-pages branch
GH_PAGES=$(mktemp -d)
JOB_DIR=${GH_PAGES}/cirrus-builds/${CIRRUS_BUILD_ID}.${CI_NODE_INDEX}
mkdir -p $JOB_DIR


pushd $GH_PAGES

git init
git config core.autocrlf true
git config user.name "Cirrus"
git config user.email "cirrus@cirrus-ci.com"
git config remote.origin.url git@github.com:egraff/uit-thesis.git
git config remote.origin.fetch +refs/heads/gh-pages:refs/remotes/origin/gh-pages
git config branch.gh-pages.remote origin
git config branch.gh-pages.merge refs/heads/gh-pages

git fetch
git checkout -l -f -q -b gh-pages origin/gh-pages

popd


cat <<EOF > $JOB_DIR/index.md
---
layout: cirrus-build
cirrus:
  branch: ${CIRRUS_BRANCH}
  build-id: ${CIRRUS_BUILD_ID}
  commit: ${CIRRUS_CHANGE_IN_REPO}
  task-id: ${CIRRUS_TASK_ID}
  task-number: ${CI_NODE_INDEX}
  os-name: Ubuntu
  test-result: $1
---
EOF

rsync --archive test/.build/ $JOB_DIR/build/
rsync --archive test/diffs/ $JOB_DIR/diffs/ || true
rsync --archive test/tmp/tests/ $JOB_DIR/tests/ || true
rsync --archive test/tmp/proto/ $JOB_DIR/proto/ || true

cp test/test_result.json $GH_PAGES/_data/cirrus-builds/${CIRRUS_BUILD_ID}_${CI_NODE_INDEX}.json

pushd $GH_PAGES

git add --all .
git commit -m "Cirrus: test results from build task ${CIRRUS_BUILD_ID}.${CI_NODE_INDEX}"

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
