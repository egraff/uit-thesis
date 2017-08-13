#!/bin/bash

# Exit on failure
set -e

if [ "$TRAVIS_SECURE_ENV_VARS" = "false" ]; then
  # Likely a pull request from a forked repository.
  # Committing the test results can only be done when secure environment
  # variables are available.
  exit 0
fi

cd `dirname "${BASH_SOURCE[0]}"`
openssl aes-256-cbc -K $encrypted_06732d003ed9_key -iv $encrypted_06732d003ed9_iv -in travis-deploy-key.enc -out travis-deploy-key -d;
chmod 600 travis-deploy-key;
eval `ssh-agent -s`;
ssh-add travis-deploy-key;

ssh-add -l
ssh -o StrictHostKeyChecking=no -T git@github.com || (exit 0)

# Make sure we're in the top directory
cd $TRAVIS_BUILD_DIR

# Create a new temp directory for committing test results to gh-pages branch
GH_PAGES=$(mktemp -d)
mkdir -p $GH_PAGES/travis-builds/${TRAVIS_JOB_NUMBER}


pushd $GH_PAGES

git init
git config core.autocrlf true
git config user.name "Travis"
git config user.email "travis@travis-ci.org"
git config remote.origin.url git@github.com:egraff/uit-thesis.git
git config remote.origin.fetch +refs/heads/gh-pages:refs/remotes/origin/gh-pages
git config branch.gh-pages.remote origin
git config branch.gh-pages.merge refs/heads/gh-pages

git fetch
git checkout -l -f -q -b gh-pages origin/gh-pages

popd


cat <<EOF > $GH_PAGES/travis-builds/${TRAVIS_JOB_NUMBER}/index.md
---
layout: travis-job
travis:
  branch: ${TRAVIS_BRANCH}
  build-id: ${TRAVIS_BUILD_ID}
  build-number: ${TRAVIS_BUILD_NUMBER}
  commit: ${TRAVIS_COMMIT}
  commit-range: ${TRAVIS_COMMIT_RANGE}
  job-id: ${TRAVIS_JOB_ID}
  job-number: ${TRAVIS_JOB_NUMBER}
  os-name: ${TRAVIS_OS_NAME}
  test-result: ${TRAVIS_TEST_RESULT}
---
EOF

cp -Rf test/.build $GH_PAGES/travis-builds/${TRAVIS_JOB_NUMBER}/build
cp -Rf test/diffs $GH_PAGES/travis-builds/${TRAVIS_JOB_NUMBER}/diffs || true
cp -Rf test/tmp/tests $GH_PAGES/travis-builds/${TRAVIS_JOB_NUMBER}/tests || true
cp -Rf test/tmp/proto $GH_PAGES/travis-builds/${TRAVIS_JOB_NUMBER}/proto || true

cp test/test_result.json $GH_PAGES/_data/travis-builds/${TRAVIS_JOB_NUMBER//\./_}.json

pushd $GH_PAGES

git add --all .
git commit -m "Travis: test results from job ${TRAVIS_JOB_NUMBER}"

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
