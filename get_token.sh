#!/bin/bash

echo
echo
echo "==========================================================================="
echo "Go to this url in your browser and copy the url and return to this screen"
echo "==========================================================================="

echo "https://login.salesforce.com/services/oauth2/authorize?response_type=token+id_token&redirect_uri=https://login.salesforce.com/services/oauth2/success&client_id=3MVG9y7s1kgRAI8b6hp7If35rbx3NpeGACZyziB9Ju7OVE81dZIGj7DPRWcG6kA0O0qWPmWZ8uzm4ESVE.1Ay&nonce=somevalue"
echo
echo


echo
read -e -p "Copy the response url and paste here: " authUrl

echo
echo
echo "================================"
echo "Now we are doing the folowing steps autmatically - "
echo "1. Parse the id_token from this url"
echo "2. Use sts assumeRoleWithWebIdentity to exchange the token for credentials belonging to role 'arn:aws:iam::788825421177:role/testGenieSalesforce'"
echo "3. Use the obtained credentials to call sts:get-caller-identity"
echo "================================"
echo
echo

token=`echo $authUrl | egrep -o "id_token=[^&]*" | cut -d "=" -f 2`

echo $token