#!/bin/bash
S3_BUCKET_APP="myapp/aspera/"
SHARES_CONFIG_FILE="enabled-shares.csv"
SHARES_CONFIG_PATH="s3://${S3_BUCKET_APP}"
S3_BUCKET=mybucket

aws s3 cp ${SHARES_CONFIG_PATH}${SHARES_CONFIG_FILE} ${SHARES_CONFIG_FILE}

for key in $(awk -F';' '{if ($9 == "Y\r" || $9 == "Y") print $8"/"}' ${SHARES_CONFIG_FILE})
do
    aws s3api put-object --bucket ${S3_BUCKET} --key $key
done
