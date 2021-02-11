resource "aws_iam_policy" "web_management_policy" {
  name        = "web_server_management"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ec2:AssociateRouteTable",
        "ec2:AttachInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:DeleteKeyPair",
        "ec2:DeleteNetworkInterface",
        "ec2:DeleteRoute",
        "ec2:DeleteRouteTable",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSubnet",
        "ec2:DeleteVpc",
        "ec2:DetachInternetGateway",
        "ec2:DisassociateRouteTable",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:ModifySubnetAttribute",
        "ec2:TerminateInstances"
      ],
      "Resource": [
        "arn:aws:ec2:${local.region}:${local.account_id}:instance/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:internet-gateway/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:ipv6pool-ec2/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:key-pair/${local.key_pair_name}",
        "arn:aws:ec2:${local.region}:${local.account_id}:network-interface/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:route-table/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:security-group/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:subnet/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:volume/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:vpc/*",
        "arn:aws:ec2:${local.region}::image/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/app": "web_server_management"
        }
      }
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateInternetGateway",
        "ec2:CreateNetworkInterface",
        "ec2:CreateRoute",
        "ec2:CreateRouteTable",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSubnet",
        "ec2:CreateTags",
        "ec2:CreateVpc",
        "ec2:ImportKeyPair",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RunInstances"
      ],
      "Resource": [
        "arn:aws:ec2:${local.region}:${local.account_id}:instance/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:internet-gateway/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:ipv6pool-ec2/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:key-pair/${local.key_pair_name}",
        "arn:aws:ec2:${local.region}:${local.account_id}:network-interface/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:route-table/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:security-group/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:subnet/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:volume/*",
        "arn:aws:ec2:${local.region}:${local.account_id}:vpc/*",
        "arn:aws:ec2:${local.region}::image/*"
      ]
    },
    {
      "Sid": "VisualEditor2",
      "Effect": "Allow",
      "Action": [
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
        "arn:aws:s3:::web-server-management-terraform/*"
      ]
    },
    {
      "Sid": "VisualEditor3",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeInstanceCreditSpecifications",
        "ec2:DescribeInstances",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeNetworkAcls",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeVpcClassicLink",
        "ec2:DescribeVpcClassicLinkDnsSupport",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VisualEditor4",
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role" "web_server_management" {
  name = "web_server_management"

  # TODO account id
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:user/steeleye_project"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Use = "web-server-management"
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.web_server_management.name
  policy_arn = aws_iam_policy.web_management_policy.arn
}
