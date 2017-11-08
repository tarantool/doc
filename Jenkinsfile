#!groovy

stage("Build") {
    node {
        checkout([
            $class: 'GitSCM',
            branches: scm.branches,
            extensions: scm.extensions + [[$class: 'CleanBeforeCheckout']],
            userRemoteConfigs: scm.userRemoteConfigs
        ])

        docker.image('tarantool/doc').inside('') {
            sh "cmake ."
            sh "VERBOSE=1 make sphinx-html sphinx-html-ru"
            sh "VERBOSE=1 make sphinx-singlehtml sphinx-singlehtml-ru"
        }

        sshagent(['3b02c16d-d8fc-4082-ba2f-38e48d8a4993']) {
            env.SERVER = "try.tarantool.org"
            env.USER = "knazarov"
            env.DEST_DIR = "/var/www/tarantool-website"

            sh "mkdir -p ~/.ssh"
            sh "chmod 700 ~/.ssh"
            sh "ssh-keyscan $SERVER > ~/.ssh/known_hosts"
            sh "chmod 600 ~/.ssh/*"
            sh "rsync -Pav output/* $USER@$SERVER:$DEST_DIR"
        }
    }
}
