#!/bin/bash

LAUNCH_TEMPLATE_NAME="test-LT"
AMI_ID="ami-0c02fb55956c7d316"
INSTANCE_TYPE="t2.micro"
KEY_NAME="sila-key-pair"
SECURITY_GROUP_ID="sg-048d6c05bce66d221" 
REGION="us-east-1"

USER_DATA=$(base64 -w 0 <<EOF
#!/bin/bash
yum update -y
yum install -y httpd stress
systemctl enable httpd
systemctl start httpd

echo "Hello from $(hostname -f)" > /var/www/html/index.html
yum install -y epel-release
yum install -y stress
nohup stress --cpu 2 --timeout 300 > /tmp/stress.log 2>&1 &
)

echo "Creating Launch Template: $LAUNCH_TEMPLATE_NAME"
aws ec2 create-launch-template \
  --launch-template-name "$LAUNCH_TEMPLATE_NAME" \
  --version-description "initial-version" \
  --region "$REGION" \
  --launch-template-data "{
    "ImageId": "$AMI_ID",
    "InstanceType": "$INSTANCE_TYPE",
    "KeyName": "$KEY_NAME",
    "SecurityGroupIds": ["$SECURITY_GROUP_ID"],
    "UserData": "$USER_DATA"
  }"
