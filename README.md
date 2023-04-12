# sagemaker-genie-1p-project

### Prerequisites

1. S3 bucket with prefix sagemaker to hold project artifacts created
2. Service Catalog portfolio created
3. Secret in Secrets Manager created.
Secret look like:
```
{
"issuerUrl":"https://geniebyom.my.salesforce.com",
"expectedAudience":"3MVG9y7s1kgRAI8b6hp7If35rbx3NpeGACZyziB9Ju7OVE81dZIGj7DPRWcG6kA0O0qWPmWZ8uzm4ESVE.1Ay"
}
```
4. Update roles created during SageMaker domain creation following: https://quip-amazon.com/cqoEAjz6u7zm/Permissions-required-to-add-to-SageMaker-Project-service-roles
5. Grant portfolio access to SageMaker execution role
    Service Catalog -> Portfolios -> <YOUR_PORTFOLIO> -> access -> grant access
    roles -> Select SageMaker execution role - AmazonSageMaker-ExecutionRole-<YOUR_ACCOUNT_NUMNBER> or any custom role for executing SageMaker
    Grant access
6. Till the DW JDBC connector is not available - create glue table - AwsDataCatalog.sagemaker_examples.emailengagement using email_engagement_summary.csv to test DW flow and associated notebook


### Steps

1. Download source code from https://gitlab.aws.dev/karpmar/sagemaker-genie-1p-project/-/tree/main
2. Copy zip files to s3:
    a. DeployCodeCommitRepo.zip -> s3://<YOUR_BUCKET>/<YOUR_SUBFOLDER>/seedcode/DeployCodeCommitRepo.zip
    b. ExampleNotebooksRepo.zip -> s3://<YOUR_BUCKET>/<YOUR_SUBFOLDER>/seedcode/ExampleNotebooksRepo.zip
3. Update `SageMakerProject.yml` to reflect your s3 locations of copied zip files
    a. 
                   Bucket: sm-project-api-gateway-serverless-example-0a441f265f5f
                   Key: api-gateway-serverless/seedcode/DeployCodeCommitRepo.zip

                                            ->
                   Bucket: <YOUR_BUCKET>
                   Key: <YOUR_SUBFOLDER>/seedcode/DeployCodeCommitRepo.zip
    b. 
                   Bucket: sm-project-api-gateway-serverless-example-0a441f265f5f
                   Key: api-gateway-serverless/seedcode/ExampleNotebooksRepo.zip

                                            ->
                   Bucket: <YOUR_BUCKET>
                   Key: <YOUR_SUBFOLDER>/seedcode/ExampleNotebooksRepo.zip
4. Upload `SageMakerProject.yml` template file to S3
    SageMakerProject.yml -> s3://sm-project-api-gateway-serverless-example-0a441f265f5f/api-gateway-serverless/templates/SageMakerProject.yml
5. Using above template, create product with product tag `sagemaker:studio-visibility` set to `true`.
    Service Catalog->Product list->Create product
        Product type -> CloudFormation
        Product name -> Salesforce Data Cloud Custom Template
        Product description -> Salesforce custom project template for deploying endpoint backed by API Gateway and lambda authorizer
        Owner -> <YOUR_NAME>
        Distributor -> <YOUR_NAME>
        Version source -> Use a template file
        Choose File -> SELECT the template file SageMakerProject.yml using file explorer
        Version name -> V-1.0
        Manage tags -> `sagemaker:studio-visibility` : `true`
        Service Catalog -> Product list -> Salesforce Data Cloud Custom Template -> Add product to portfolio -> <YOUR_PORTFOLIO>
6. Create project is Sagemaker
    Studio > HOME -> Deployments > Projects > Create Project > Organization templates > Salesforce Data Cloud Custom Template -> Select Project Template
        Name -> <YOUR_PROJECT_NAME>
        Description -> <optional>
        SourceModelPackageGroupName -> sagemaker-salesforce-<YOUR_GROUP_NAME>
        SecretManagerSecretName -> <YOUR_SECRET_NAME>

### Project outputs
1. APIGW URL, query, schema and aud in artifact bucket under metadata folder
2. SageMaker Model registry points to location of metadata file in customer metadata field `metadata_file_location`

### Testing
1. Register a model to Model Group you specified when creating the project
```
pipeline_model.register( model_package_group_name="perm-mr",content_types=["text/csv"],response_types=["application/json"], inference_instances=[instance_type], customer_metadata_properties={"flow_file_location":"s3://sagemaker-us-east-1-130992530969/salesforce/flow-files/default.flow"})
```
2. Use `get_token.sh` to get JWT token. *Note you need to part of the Connected App and have SF creds to do this!*

3. Using the APIGW URL output in the metadata file (Model Registry will have the location added as customer metadata) you can use postman to send a request to the endpoint. 
Make sure to set all headers required such as `Content-Type` and mandatory `Auth` header which must contain the JWT Token. 

