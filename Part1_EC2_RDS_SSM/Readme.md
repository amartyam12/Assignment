Contains-
    1. cloudwatch.tf
    2.CPU_Alarm.tf
    3.ec2.tf
    4.Memory_Alarm.tf
    5.provider.tf
    6.rds.tf
    7.sns.tf
    8.ssm.tf
    9.userdata.sh
    10.vpc.tf

Working Procedure - 
                    1. Initialise "aws configure" then input the credentials of your aws account.
                    2. Use "terraform init" 
                    3. Use "terraform validate"
                    4. Use "terraform plan"
                    5. Use "terraform apply"
                    6. After using "terraform Apply" it wil show a dns name to connect to private subnet instance.
                    7. Using the dns name it will show a nginx page.
                    8. Check rds is running in private subnet.
                    9. check ssm is working.
                    10. finally after checking all these use "terraform destroy"
