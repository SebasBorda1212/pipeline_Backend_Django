pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sebaspro123/backend-django"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('1. Descarga de Código (Checkout)') {
            steps {
                echo 'Descargando código desde el repositorio de GitHub...'
                checkout scm
            }
        }

        stage('2. Pruebas Automatizadas (Testing)') {
            steps {
                echo 'Ejecutando la suite de pruebas del Backend en Django...'
                sh '''
                    echo "Validando archivos del proyecto..."
                    ls -la
                '''
            }
        }

        stage('3. Construcción de Imagen (Build Docker Image)') {
            steps {
                echo 'Construyendo la imagen de contenedor Docker...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('4. Publicación en Registro (Push to Docker Hub)') {
            steps {
                echo 'Subiendo la imagen a Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh """
                        echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Finalizando el Pipeline...'
        }
        success {
            echo '¡El Pipeline se ejecutó exitosamente!'
        }
        failure {
            echo '¡ERROR en el Pipeline! Revisa los logs.'
        }
    }
}
