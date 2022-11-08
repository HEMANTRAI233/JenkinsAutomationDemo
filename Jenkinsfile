pipeline{
	agent any
	stages{
		stage('version'){
			steps{
				bat 'pwsh --version'
			}
		}
		stage('hello'){
			steps{
				bat 'pwsh hello.ps1'
			}
		}
	}
}
