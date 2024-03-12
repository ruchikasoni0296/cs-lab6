# cs-lab6

To disassociate the policy and the role created in the lab:
policy_arn=$(terraform output -raw policy_arn)
role_name=$(terraform output -raw ec2_role_name)
instance_profile_name=$(terraform output -raw ec2_instance_profile_name)
aws iam detach-role-policy --policy-arn $policy_arn --role-name $role_name
aws iam remove-role-from-instance-profile --role-name $role_name --instance-profile-name $instance_profile_name
aws iam delete-instance-profile --instance-profile-name $instance_profile_name

To remove the role:
aws iam delete-role --role-name $role_name
