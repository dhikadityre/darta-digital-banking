pipeline {
    agent {
        // DEMO NOTE: Di lingkungan production asli, ganti 'any' menjadi 'macos' (label 'macos')
        // karena kompilasi iOS membutuhkan mesin macOS fisik/virtual yang terpasang Xcode.
        any
    }
    
    options {
        // Discard old builds to save disk space
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Build timeout
        timeout(time: 30, unit: 'MINUTES')
        // Enable ANSI color output in Jenkins console
        ansiColor('xterm')
    }
    
    triggers {
        // Automatically trigger builds on GitLab pushes and merge requests
        gitlab(
            triggerOnPush: true,
            triggerOnMergeRequest: true,
            branchFilterType: 'AllBranches',
            secretToken: env.GITLAB_SECRET_TOKEN // Webhook verification token
        )
    }
    
    stages {
        stage('Initialize') {
            steps {
                echo 'Checking Environment...'
                sh 'if command -v xcodebuild >/dev/null 2>&1; then xcodebuild -version; else echo "xcodebuild not found (Demo Mode)"; fi'
                
                echo 'Setting Script Permissions...'
                sh 'chmod +x TapCash/script/*.sh'
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                echo 'Running tests validation stage...'
                // Run the non-interactive test runner
                sh './TapCash/script/run_tests.sh'
            }
        }
    }
    
    post {
        always {
            // Update the commit status in GitLab to show success/failure on the PR
            updateGitlabCommitStatus name: 'Unit Tests Validation', state: currentBuild.currentResult.toLowerCase()
        }
        success {
            echo 'Build succeeded. All unit tests passed!'
        }
        failure {
            echo 'Build failed. One or more unit tests failed, or the compilation encountered an error.'
        }
    }
}
