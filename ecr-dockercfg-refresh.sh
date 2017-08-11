#!/bin/sh
refresh_secret()
{
  if [ "x$REFRESH_NAMESPACES" == "x"]; then
    REFRESH_NAMESPACES=default
  fi
  REFRESH_NAMESPACES=${REFRESH_NAMESPACES//,/$'\n'}
  if [ "x$AWS_ACCOUNT" == "x" ]; then
    AWS_ACCOUNT=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep accountId | awk -F\" '{print $4}'`
  fi
  if [ "x$AWS_REGION" == "x" ]; then
    AWS_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}'`
  fi
  if [ "x$SECRET_NAME" == "x" ]; then
    SECRET_NAME=aws-ecr-${AWS_REGION};
  fi
  TOKEN=`aws ecr --region=${AWS_REGION} get-authorization-token --output text --query "authorizationData[].authorizationToken" | base64 -d | cut -f2 -d:`
  DOCKER_CFG_SECRET=`printf '{"%s":{"username":"AWS","password":"%s"}}' "https://${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com.cn" "${TOKEN}" | base64 | tr -d '\n'`

  for NS in $REFRESH_NAMESPACES; do
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
data:
  .dockercfg: ${DOCKER_CFG_SECRET}
metadata:
  name: ${SECRET_NAME}
  namespace: ${NS}
type: kubernetes.io/dockercfg
EOF
  done
}

if [ "x$REFRESH_INTERVAL" == "x" ]; then REFRESH_INTERVAL=21600; fi

refresh_secret
if [ $REFRESH_INTERVAL -ne 0 ]
then
  while sleep $REFRESH_INTERVAL
  do
    refresh_secret
  done
fi
