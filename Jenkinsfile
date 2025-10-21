pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'  // Adjust if needed
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
		    #!/bin/bash
		    mkdir -p ~/.ssh
		    chmod 700 ~/.ssh

		    # Use bash-compatible loop
		    while read host; do
    		    ssh-keyscan -H $host >> ~/.ssh/known_hosts
		    done <<< "$(grep -v '^#' $ANSIBLE_INVENTORY | awk '{print $1}')"

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
                    # Export AWS credentials
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                    # Test connection
                    ansible all -i $ANSIBLE_INVENTORY -m ping -u $SSH_USER --private-key $SSH_KEY

                    # Run playbook
                    ansible-playbook -i $ANSIBLE_INVENTORY $PLAYBOOK -u $SSH_USER --private-key $SSH_KEY
                    '''
                }
            }
        }
    }
}
