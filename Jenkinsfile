pipeline{
	agent any
	stages{
		stage('hello'){
			steps{
				bat 'PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& './hello.ps1'"'

			}
		}
	}
}
