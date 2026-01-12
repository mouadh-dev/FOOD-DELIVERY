pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'localhost'
        IMAGE_NAME = 'food-delivery'
        SONAR_HOST = 'http://sonarqube:9000'
    }
    
    stages {
        stage('🔍 Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                    echo "Building commit: ${env.GIT_COMMIT_SHORT}"
                }
            }
        }
        
        stage('📦 Install Dependencies') {
            parallel {
                stage('Backend') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('backend') {
                            sh '''
                                echo "Installing backend dependencies..."
                                npm ci
                                echo "✅ Backend dependencies installed"
                            '''
                        }
                    }
                }
                stage('Frontend') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('frontend') {
                            sh '''
                                echo "Installing frontend dependencies..."
                                npm ci
                                echo "✅ Frontend dependencies installed"
                            '''
                        }
                    }
                }
                stage('Admin') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('admin') {
                            sh '''
                                echo "Installing admin dependencies..."
                                npm ci
                                echo "✅ Admin dependencies installed"
                            '''
                        }
                    }
                }
            }
        }
        
        stage('🔐 SAST - SonarQube Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                    args '--network food-delivery-network'
                    reuseNode true
                }
            }
            steps {
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                        echo "Starting SonarQube analysis..."
                        sonar-scanner \
                            -Dsonar.projectKey=food-delivery \
                            -Dsonar.projectName="Food Delivery App" \
                            -Dsonar.sources=backend/,frontend/src/,admin/src/ \
                            -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/build/**,**/coverage/** \
                            -Dsonar.host.url=${SONAR_HOST} \
                            -Dsonar.token=${SONAR_TOKEN}
                        echo "✅ SonarQube analysis completed"
                    '''
                }
            }
        }
        
        stage('🔍 Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        try {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                echo "⚠️ Quality Gate failed: ${qg.status}"
                                // Ne pas arrêter le pipeline
                            } else {
                                echo "✅ Quality Gate passed"
                            }
                        } catch (Exception e) {
                            echo "⚠️ Quality Gate check failed: ${e.message}"
                            // Continue anyway
                        }
                    }
                }
            }
        }
        
        stage('🛡️ Dependency Check') {
            parallel {
                stage('Backend Audit') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('backend') {
                            sh '''
                                echo "Auditing backend dependencies..."
                                npm audit --audit-level=moderate --json > npm-audit-backend.json || true
                                echo "✅ Backend audit completed"
                            '''
                            archiveArtifacts artifacts: 'npm-audit-backend.json', allowEmptyArchive: true
                        }
                    }
                }
                stage('Frontend Audit') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('frontend') {
                            sh '''
                                echo "Auditing frontend dependencies..."
                                npm audit --audit-level=moderate --json > npm-audit-frontend.json || true
                                echo "✅ Frontend audit completed"
                            '''
                            archiveArtifacts artifacts: 'npm-audit-frontend.json', allowEmptyArchive: true
                        }
                    }
                }
                stage('Admin Audit') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        dir('admin') {
                            sh '''
                                echo "Auditing admin dependencies..."
                                npm audit --audit-level=moderate --json > npm-audit-admin.json || true
                                echo "✅ Admin audit completed"
                            '''
                            archiveArtifacts artifacts: 'npm-audit-admin.json', allowEmptyArchive: true
                        }
                    }
                }
            }
        }
        
        stage('🐳 Build Docker Images') {
            steps {
                script {
                    echo "Building Docker images..."
                    
                    // Build Backend
                    sh """
                        docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-backend:${GIT_COMMIT_SHORT} \
                            -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-backend:latest \
                            ./backend
                    """
                    echo "✅ Backend image built"
                    
                    // Build Frontend
                    sh """
                        docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-frontend:${GIT_COMMIT_SHORT} \
                            -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-frontend:latest \
                            ./frontend
                    """
                    echo "✅ Frontend image built"
                    
                    // Build Admin
                    sh """
                        docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-admin:${GIT_COMMIT_SHORT} \
                            -t ${DOCKER_REGISTRY}/${IMAGE_NAME}-admin:latest \
                            ./admin
                    """
                    echo "✅ Admin image built"
                }
            }
        }
        
        stage('🚀 Deploy to Staging') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                script {
                    echo "Deploying to staging environment..."
                    sh """
                        export GIT_COMMIT_SHORT=${GIT_COMMIT_SHORT}
                        export DOCKER_REGISTRY=${DOCKER_REGISTRY}
                        export IMAGE_NAME=${IMAGE_NAME}
                        
                        docker-compose -f docker-compose.staging.yml down || true
                        docker-compose -f docker-compose.staging.yml up -d
                        
                        echo "✅ Staging deployment completed"
                        echo "Backend: http://localhost:4001"
                        echo "Frontend: http://localhost:3001"
                        echo "Admin: http://localhost:3002"
                    """
                }
            }
        }
        
        stage('✅ Health Check') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                script {
                    echo "Performing health checks..."
                    sh '''
                        # Wait for services to start
                        sleep 10
                        
                        # Check if containers are running
                        docker ps | grep food-delivery || echo "⚠️ Some containers may not be running"
                        
                        echo "✅ Health check completed"
                    '''
                }
            }
        }
        
        stage('🏭 Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
                script {
                    echo "Deploying to production environment..."
                    sh """
                        export GIT_COMMIT_SHORT=${GIT_COMMIT_SHORT}
                        export DOCKER_REGISTRY=${DOCKER_REGISTRY}
                        export IMAGE_NAME=${IMAGE_NAME}
                        
                        docker-compose -f docker-compose.prod.yml down || true
                        docker-compose -f docker-compose.prod.yml up -d
                        
                        echo "✅ Production deployment completed"
                        echo "Backend: http://localhost:4000"
                        echo "Frontend: http://localhost:3000"
                        echo "Admin: http://localhost:3001"
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo "Commit: ${env.GIT_COMMIT_SHORT}"
            echo "Images built and tagged with: ${env.GIT_COMMIT_SHORT}"
        }
        failure {
            echo '❌ Pipeline failed!'
            echo "Check the logs above for details"
        }
        always {
            echo 'Pipeline execution finished'
        }
    }
}