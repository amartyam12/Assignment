This File Contains - 
                    1. cloudwatch.tf
                    2. CPU_Alarm.tf
                    3. main_flask.tf
                    4. Memory_Alarm.tf
                    5. provider_flask.tf
                    6. sns.tf
Working Procedure of the file - 
                    1. Initialise "aws configure" then input the credentials of your aws account.
                    2. use command "terraform init"
                    3. use command "terraform validate"
                    4. use command "terraform plan"
                    5. use command "terraform apply" it will show the access ip in the terminal for easy access.
                    6. by using this ip check flask app is running fine
                    7. Make some changes in the main.py file and push it to github
                    8. check the changes take effect in the web page.
                    9. After checking the CI/CD connection use "terraform destroy".
        
        Note := -- The cicd pipeline script is in ".github/workflows/deploy.yaml