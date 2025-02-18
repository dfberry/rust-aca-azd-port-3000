# Deploy Rust app to Azure Container Apps

## Don't change anything yet

Follow the steps in the next section. If you can't complete all the steps successfully, log an issue with the following:

* What host operating system did you use such as Windows, Mac, or Linux. Include version and flavor -- as much information as possible.
* What type of Azure subscription you are deploying to. 
* Which step didn't complete and what error you got in the process.
* What debug/fix steps you took. 
* If you made any changes to one of the following directories, explain why you needed to make that change to try out the sample in order to deploy it:
  * ./src
  * ./infra
  * ./devcontainer
  * ./github/workflows

## azd up

1. Have .env file with port and PG_DATABASE_URL
2. Run `azd login`
3. Run `bash ./scripts/azd-up-with-environment.sh`
4. Run `bash ./scripts/create-github-azure-credentials.sh` and put value in GitHub repo secret as AZURE_CREDENTIALS
5. Create 3 more secrets for: 
    - AZURE_CONTAINER_REGISTRY_LOGIN_SERVER
    - AZURE_CONTAINER_REGISTRY_USERNAME
    - AZURE_CONTAINER_REGISTRY_PASSWORD
6. Create github workflow for deployment. Set the following variables at the top:

    ```yaml
    env:
        AZURE_CONTAINER_APP_NAME: rustserver
        AZURE_RESOURCE_GROUP: rg-dfb-api-pg-stage
        AZURE_CONTAINER_REGISTRY: cr7yqxmkwjz6ay2
        IMAGE_NAME: api-pg-rust
    ```