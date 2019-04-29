#!groovy

node {
    checkout()
    test()
    // clean()
    // unitTest()
    // sonarServer()
    // buildApk()
}

def isPRMergeBuild() {
    return (env.BRANCH_NAME ==~ /^PR-\d+$/)
}

def checkout () {
    stage('Checkout code') {
      checkout scm
      // statuses = pullRequest.getStatuses()
      // statuses.each {
      //   sh "echo context: ${it.getContext()}, desc: ${it.getDescription()}, state: ${it.getState()}"
      // }
    }
}

def test () {
  stage('TEST') {
    githubPRStatusPublisher buildMessage: 
      message(failureMsg: githubPRMessage('Can\'t set status; build failed.'), 
      successMsg: githubPRMessage('Can\'t set status; build succeeded.')), 
      statusMsg: githubPRMessage('${GITHUB_PR_COND_REF} run ended'), 
      unstableAs: 'SUCCESS'
  }
}


def unitTest() {
    stage('Unit Tests') {
       def context = "Unit Tests"
       pullRequest.createStatus('pending', context, 'Unit Test running...', 'http://192.168.1.128:8080/job/ci-test/job/PR-4')
        sh './gradlew testDebugUnitTest'
        junit '**/TEST-*.xml'
       if (currentBuild.result == 'UNSTABLE') {
          pullRequest.createStatus('failure', context, 'This tests is fail.', 'http://192.168.1.128:8080/job/ci-test/job/PR-4')
       } else {
          pullRequest.createStatus('success', context, 'This tests is good.', 'http://192.168.1.128:8080/job/ci-test/job/PR-4')
       }
    }
}

def clean() {
    stage('Clean') {
        sh './make_prerun.sh'
        sh './gradlew clean'
        def context = "Clean repository..."
        updateCommitStatus(context, 'This step is passed.', 'success')
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
        def context = "Build Apk"
        pullRequest.createStatus('success', context, 'Build complete', 'http://192.168.1.128:8080/job/ci-test/job/PR-4')
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

def updateCommitStatus(context, description, state) {
  post {
    script {
      if (env.CHANGE_ID) {
        pullRequest.createStatus(state, context, description, "${env.JOB_URL}")
      } else {
        sh 'echo ---------> ERROR: empty CHANGE_ID <---------'
      }
    }
  }
}