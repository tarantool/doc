#!groovy

stage("Build") {
    node {
        checkout scm

        docker.image('tarantool/build:centos7').inside('--user root:root') {
            sh "sudo yum -y install lua-devel"
            sh "sudo pip install -r requirements.txt --upgrade"
            sh "cmake3 ."
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
            sh "rsync -Pav output/en/doc/1.6/ " +
               "$USER@$SERVER:$DEST_DIR/en/doc/1.6"
            sh "rsync -Pav output/ru/doc/1.6/ " +
               "$USER@$SERVER:$DEST_DIR/ru/doc/1.6"

        }
    }
}
