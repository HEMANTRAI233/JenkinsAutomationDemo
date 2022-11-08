pipeline{
	agent any
	stages{
		stage('version'){
			steps{
				bat 'pwsh.exe --version'
			}
		}
		stage('hello'){
			steps{
				bat 'pwsh.exe hello.ps1'
			}
		}
	}
}
