pipeline{
	agent any
	stages{
		stage('version'){
			steps{
				sh 'push --version'
			}
		}
		stage('hello'){
			steps{
				sh 'pwsh hello.ps1.txt'
			}
		}
	}
}
