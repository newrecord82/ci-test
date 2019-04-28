#!groovy
import groovy.json.JsonBuilder
import wslite.rest.*


node {
    checkout()
    testLog()
    clean()
    unitTest()
    // sonarServer()
    buildApk()
}

def testLog() {
  stage 'Test log'
  context="-- Test context --"
  // setBuildStatus("${context}", 'Test log success.', 'UNSTABLE')
  // setGitHubPullRequestStatus context: 'Test context', message: 'Succes cleanning...', state: 'SUCCESS'
  updateBuildStatus(context, 'Test-log...', 'SUCCESS')
}

def isPRMergeBuild() {
    return (env.BRANCH_NAME ==~ /^PR-\d+$/)
}

def checkout () {
    stage 'Checkout code'
   context="continuous-integration/jenkins/"
   context += isPRMergeBuild()?"pr-merge/checkout":"branch/checkout"
    checkout scm
  //  setBuildStatus ("${context}", 'Checking out completed', 'SUCCESS')
  updateBuildStatus(context, 'Checking-out-completed', 'SUCCESS')
}


def unitTest() {
    stage('Unit Tests') {
       def context = "Unit Tests"
       setBuildStatus("${context}", 'Unit Test running...', 'PENDING')
        sh './gradlew testDebugUnitTest'
        junit '**/TEST-*.xml'
       if (currentBuild.result == 'UNSTABLE') {
           updateBuildStatus(context, 'Unit-Test-result.', 'UNSTABLE')
          //  setBuildStatus("${context}", 'Unit Test result.', 'UNSTABLE')
       } else {
           updateBuildStatus(context, 'Unit-Test-result.', 'STABLE')
          //  setBuildStatus("${context}", 'Unit Test result.', 'STABLE')
       }
    }
}

def clean() {
    stage('Clean') {
        sh './make_prerun.sh'
        sh './gradlew clean'
      //  def context = "Clean repository..."
      //  setBuildStatus ("${context}", "Code clean...", 'SUCCESS')
        updateBuildStatus(context, 'Code-clean...', 'SUCCESS')
    }
}

def sonarServer() {
    stage('Quality Gate-SonarQube') {
        withSonarQubeEnv('SonarQube server') {
            sh './gradlew sonarqube'
        }

//        def context = "SonarQube/QualityGate"
//        setBuildStatus("${context}", 'Checking Sonarqube quality gate', 'PENDING')
//        timeout(time: 15, unit: 'MINUTES') {
//            def qg = waitForQualityGate()
//            if (qg.status != 'OK') {
//                setBuildStatus("${context}", "Sonarqube quality gate fail: ${qg.status}", 'FAILURE')
//                error "Pipeline aborted due to quality gate failure: ${qg.status}"
//            } else {
//                setBuildStatus ("${context}", "Sonarqube quality gate pass: ${qg.status}", 'SUCCESS')
//            }
//        }
    }
}

def buildApk() {
    stage('Build Apk') {
        sh './gradlew assembleDebug'
        updateBuildStatus("Build apk", 'Apk-build...', 'SUCCESS')
    }
}

def getRepoURL() {
  sh "git config --get remote.origin.url > .git/remote-url"
  return readFile(".git/remote-url").trim()
}

def getCommitSha() {
  sh "git rev-parse HEAD > .git/current-commit"
  return readFile(".git/current-commit").trim()
}

void updateBuildStatus(context, desc, state) {
  // PENDING, SUCCESS, FAILURE, UNSTABLE, STABLE
  repoUrl = getRepoURL()
  commitSha = getCommitSha()
  target_url = "http://192.168.1.128:8080/job/ci-test/job/PR-3"
  contentType = "Content-Type: application/json"
  accessToken ="94ffbe3f1306e10f0a2977c1700aca1eefe34a3d"
  tmpUrl = "https://api.github.com/repos/newrecord82/ci-test"
  // body = "{\\\"context\\\": \\\"${context}\\\", \\\"description\\\": \\\"${desc}\\\", \\\"state\\\": \\\"${state}\\\", \\\"target_url\\\": \\\"${target_url}\\\"}"
  // sh "echo ${body}"
  // sh "curl \"${repoUrl}/statuses/${commitSha}?access_token=${accessToken}\" -H \"${contentType}\" -X POST -d \"${body}\""
  sh """
    curl '${tmpUrl}/statuses/${commitSha}?access_token=${accessToken}' \
    -H '${contentType}' \
    -X POST \
    -d '{\"context\": \"${context}\", \"description\": \"${desc}\", \"state\": \"${state}\", \"target_url\": \"${target_url}\"}'
  """
}

void setBuildStatus(contextName, message, state) {

  repoUrl = getRepoURL()
  commitSha = getCommitSha()
  sh "echo ${repoUrl}"
  sh "echo ${commitSha}"
  step([
      $class: "GitHubCommitStatusSetter",
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: contextName],
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: repoUrl],
      commitShaSource: [$class: "ManuallyEnteredShaSource", sha: commitSha],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [
        $class: "ConditionalStatusResultSource",
        results: [
            [$class: "AnyBuildResult", message: message, state: state]
          ]
      ]
  ])
}