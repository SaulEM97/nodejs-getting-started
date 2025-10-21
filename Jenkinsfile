pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ANSIBLE_INVENTORY = 'ansible/inventory.ini'
        PLAYBOOK = 'ansible/playbook_nodejs.yaml'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/SaulEM97/nodejs-getting-started.git',
                    credentialsId: 'github-pat'
            }
        }

        stage('Prepare SSH & Known Hosts') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ANSIBLE_SSH_KEY',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                   sh '''
                   mkdir -p ~/.ssh
                   chmod 700 ~/.ssh

                   # Add known hosts explicitly
                   ssh-keyscan -H 35.170.81.7 >> ~/.ssh/known_hosts

                   chmod 644 ~/.ssh/known_hosts
                   '''
                }
            }
        }

        stage('Run Ansible') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                    sshUserPrivateKey(
                        credentialsId: 'ANSIBLE_SSH_KEY',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                    ansible all -i $ANSIBLE_INVENTORY -m ping -u $SSH_USER --private-key $SSH_KEY
                    ansible-playbook -i $ANSIBLE_INVENTORY $PLAYBOOK -u $SSH_USER --private-key $SSH_KEY
                    '''
                }
            }
        }
    }
}

