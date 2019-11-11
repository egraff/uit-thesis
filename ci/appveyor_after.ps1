Param(
    [Parameter(Mandatory=$true)]
    [int]
    $TestResult
)

$ErrorActionPreference = "Stop"

if ($env:APPVEYOR_PULL_REQUEST_NUMBER) {
    # Likely a pull request from a forked repository.
    # Committing the test results can only be done when secure environment
    # variables are available.
    exit 0
}

$ErrorActionPreference = "Continue"
ssh -o StrictHostKeyChecking=no -T git@github.com 2>&1 | %{ "$_" }
$ErrorActionPreference = "Stop"

# Make sure we're in the top directory
cd $env:APPVEYOR_BUILD_FOLDER

Write-Host "Creating temporary directory"
$GhPages = md (Join-Path ([System.IO.Path]::GetTempPath()) ([string][System.Guid]::NewGuid())) -Force | %{ $_.FullName }


Push-Location -Path $GhPages

$ErrorActionPreference = "Continue"

git init
git config core.autocrlf true
git config user.name "AppVeyor"
git config user.email "appveyor@appveyor.com"
git config remote.origin.url git@github.com:egraff/uit-thesis.git
git config remote.origin.fetch +refs/heads/gh-pages:refs/remotes/origin/gh-pages
git config branch.gh-pages.remote origin
git config branch.gh-pages.merge refs/heads/gh-pages

git fetch 2>&1 | %{ "$_" }
git checkout -l -f -q -b gh-pages origin/gh-pages

$ErrorActionPreference = "Stop"

Pop-Location


$JobDir = md "$GhPages\appveyor-builds\${env:APPVEYOR_BUILD_NUMBER}.${env:APPVEYOR_JOB_NUMBER}" | %{ $_.FullName }

@"
---
layout: appveyor-build
appveyor:
  branch: ${env:APPVEYOR_REPO_BRANCH}
  build-id: ${env:APPVEYOR_BUILD_ID}
  build-number: ${env:APPVEYOR_BUILD_NUMBER}
  commit: ${env:APPVEYOR_REPO_COMMIT}
  job-id: ${env:APPVEYOR_JOB_ID}
  job-number: ${env:APPVEYOR_JOB_NUMBER}
  os-name: Windows
  test-result: $TestResult
---
"@ | Set-Content -Path "$JobDir\index.md"


Get-Content -Path "$JobDir\index.md" | Out-String


cp test\.build "$JobDir\build" -Recurse -ErrorAction Ignore
cp test\diffs "$JobDir\diffs" -Recurse -ErrorAction Ignore
cp test\tmp\tests "$JobDir\tests" -Recurse -ErrorAction Ignore
cp test\tmp\proto "$JobDir\proto" -Recurse -ErrorAction Ignore

md "$GhPages\_data\appveyor-builds" -Force | Out-Null
cp test\test_result.json "$GhPages\_data\appveyor-builds\${env:APPVEYOR_BUILD_NUMBER}_${env:APPVEYOR_JOB_NUMBER}.json"


Push-Location -Path $GhPages

$ErrorActionPreference = "Continue"

git add --all . 2>&1 | %{ "$_" }
git commit -m "AppVeyor: test results from job ${env:APPVEYOR_BUILD_NUMBER}.${env:APPVEYOR_JOB_NUMBER}" 2>&1 | %{ "$_" }

$maxAttempts = 10
$numAttempts = 0

while ($numAttempts -lt $maxAttempts) {
    $numAttempts++
    git push -q origin gh-pages 2>&1 | %{ "$_" }
    if (-not $?) {
        git pull --rebase origin gh-pages 2>&1 | %{ "$_" }
    } else {
        break
    }
}

$ErrorActionPreference = "Stop"

Pop-Location
