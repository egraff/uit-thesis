#!/bin/bash

# Exit on failure, verbose
set -ev

mkdir gh-pages
pushd gh-pages

git init
git config core.autocrlf true
git config user.name "Travis"
git config user.email "travis@travis-ci.com"
git config remote.origin.url git@github.com:egraff/uit-thesis.git
git config remote.origin.fetch +refs/heads/gh-pages:refs/remotes/origin/gh-pages
git config branch.gh-pages.remote origin
git config branch.gh-pages.merge refs/heads/gh-pages

git fetch
git checkout -l -f -q -b gh-pages origin/gh-pages

popd

mkdir -p gh-pages/travis-builds/${TRAVIS_BUILD_NUMBER}

cat <<EOF > gh-pages/travis-builds/${TRAVIS_BUILD_NUMBER}/index.md
---
layout: test-result
travis:
  branch: ${TRAVIS_BRANCH}
  build-id: ${TRAVIS_BUILD_ID}
  build-number: ${TRAVIS_BUILD_NUMBER}
  commit: ${TRAVIS_COMMIT}
  commit-range: ${TRAVIS_COMMIT_RANGE}
  job-id: ${TRAVIS_JOB_ID}
  job-number: ${TRAVIS_JOB_NUMBER}
  test-result: ${TRAVIS_TEST_RESULT}
---
EOF

cp -Rf .build gh-pages/travis-builds/${TRAVIS_BUILD_NUMBER}/build
cp -Rf diffs gh-pages/travis-builds/${TRAVIS_BUILD_NUMBER}/diffs
cp -Rf tmp/. gh-pages/travis-builds/${TRAVIS_BUILD_NUMBER}/diffs

cp test_result.json gh-pages/_data/travis-builds/${TRAVIS_BUILD_NUMBER}.json

pushd gh-pages

git add --all .
git commit -m "Travis: test results from build ${TRAVIS_BUILD_NUMBER}"

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
