## How to run the project

Run `bash provision_servers.sh`

## Prerequisites

1. You should be on a linux system. Script is not tested on unix / mac systems.
2. You should have the following packages installed: wget, tar
3. You will be prompted for input for AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

### For aws access and secret key

It should be okay to add keys with full permissions. The scripts will create a new IAM role with access to work only on resources with tag "app" = "web_server_management". Terraform for creating / deleting resources will work assuming role to this role.

The minimal permissions needed for the input AWS_ACCESS_KEY_ID is the following

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:CreatePolicy",
                "iam:CreatePolicyVersion",
                "iam:CreateRole",
                "iam:DeletePolicy",
                "iam:DeletePolicyVersion",
                "iam:DeleteRole",
                "iam:DetachRolePolicy",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:ListPolicyVersions",
                "iam:TagRole",
                "iam:UpdateAssumeRolePolicy",
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutBucketTagging",
                "s3:PutObject",
                "s3:PutObjectTagging",
                "s3:PutObjectVersionTagging"
            ],
            "Resource": [
                "arn:aws:s3:::web-server-management-terraform",
                "arn:aws:s3:::web-server-management-terraform/*",
                "arn:aws:iam::*:role/web_server_management",
                "arn:aws:iam::*:policy/web_server_management"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::*:role/web_server_management"
        }
    ]
}
```
