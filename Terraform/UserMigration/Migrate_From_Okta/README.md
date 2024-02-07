# How To Instructions

This example will create a **User Migration Smart Hook** (and 2 **Smart Hook Environment Variables**) in your target OneLogin environment. <br>
This Smart Hook will allow you to connect to an existing Okta environment (via the Okta Authentication V1 API) and migrate your Okta users along with their existing Okta passwords into your target OneLogin environment. <br>
This Smart Hook will first call the /api/v1/authn endpoint to attempt to validate the credentials entered into the OneLogin hosted login page. <br>
If the credentials have been successfully validated the Smart Hook will then proceed to call the  /api/v1/users/ endpoint on Okta and extract the full user profile before using this information to create the new user in your OneLogin environment based on the attribute mapping defined in the Smart Hook. <br>
This Smart Hook will execute each time an authentication request is initiated to your OneLogin environment (via the hosted login page) and the specified username does not already exist. If an authentication request is recieved for a user that already exists in your OneLogin environment the Smart Hook will not execute.<br>

This example calls the Okta Admin API using the OKTA API Token approach. **Before** running this example it is required to create an API Token in your Okta environment as this will be needed for the Smart Hook to be able to get the user profile once the credential validation step has completed. Please refer to Okta developer documentation for more detail.<br>

**Before** running this example it is required to **create some custom fields** in your target OneLogin environment to hold all of the attributes from the standard Okta user profile. It is not currently possible to create these custom fields via the OneLogin Admin API and must be done in the Admin Console manually. <br>

The following custom fields should be created in your target OneLogin environment. <br>

**user_locale** <br>
**secondEmail** <br>
**userType** <br>
**employeeNumber** <br>
**costCenter** <br>
**division** <br>
**honorificPrefix** <br>
**honorificSuffix**  <br>

Populate the required configuration for your Smart Hook into the relevant variables in the **target_ol_env.tfvars** file.<br>
For more details on the User Migration Smart Hooks please see **https://developers.onelogin.com/api-docs/2/smart-hooks/types/user-migration**

Create an API credential for Terraform to use in your target OneLogin environment with **"Manage All" permissions**. For detail see **https://developers.onelogin.com/api-docs/2/getting-started/working-with-api-credentials** 

**START**
- From a system with Terraform and Git installed create a new folder and run 
<br><pre>`git clone https://github.com/1id-presales/Automation-OneLogin-SH.git`</pre>
- Navigate into the Migrate_From_Okta folder with 
<br><pre>`cd Automation-OneLogin-SH/Terraform/UserMigration/Migrate_From_Okta/`</pre>
- Modify the contents of the file `target_ol_env.tfvars` with your favourite text editor as required.
- Set the ol_client_secret variable in your system level environment variables with `export TF_VAR_ol_client_secret=xxxxxxxxx` replacing `xxxx` with the client secret from the API credential you have already created for running Terraform against your target OneLogin Environement. Also set the Okta API Key for your target Okta environment with `export TF_VAR_okta_api_key="xxxxxxx"`
<br><pre>`export TF_VAR_ol_client_secret=xxxxx`</pre>
<br><pre>`export TF_VAR_okta_api_key="xxxxxxx"`</pre>
- Initialize your terraform environment by running the command 
<br><pre>`terraform init`</pre>
- Run a terraform plan operation to see what changes will be applied to your environment. Run the command 
<br><pre>`terraform plan -var-file "target_ol_env.tfvars"`</pre>
- If you are happy with the output of the plan from the previous step proceed to apply the planned changes. Apply the planned changes with the below command and enter yes at the prompt.
<br><pre>`terraform apply -var-file "target_ol_env.tfvars"`</pre> 
- Navigate to the Admin console of your target OneLogin environment and go to the events page and validate the Smart Hook has been created successfully by looking for the "Smart Hook created" event. Perform test user migration traffic and validate the Smart Hook is executing successfully 
- To run a cleanup to remove this **User Migration Smart Hook** from your target OneLogin environment run the command 
<br><pre>`terraform destroy -var-file "target_ol_env.tfvars"`</pre>
_Please note you may need to run this command twice to fully clean up the created resources._
- Navigate to the Admin console of your target OneLogin environment and go to the events page and validate the smart hook has been removed successfully by looking for the "Smart Hook deleted" event.<br>

**END**
