# How To Instructions

This example will create **a Pre Authentication Smart Hook** (and 4 **Smart Hook Environment Variables**) in your target OneLogin environment. <br>
This Smart Hook will allow you to connect to an External Redis Cache to store additional authentication counters in the cache. Each time a Login request is recieved for a user the counter will be incremented in the cache. <br>
The Smart Hook will also check the counter value for that user in the cache and if the value of the counter returned for that user is greater than 3 the Smart Hook will dynamically allocate a User Security policy to the user which has been configured with OneLogin Protect Push notifications to be disabled.<br> 
The counters stored in the cache will be cleared after 60 seconds if no new Login requests are recieved. When the counter has been cleared the Login request will be handled as per the configuration of the User security policy which is statically assigned to the user (i.e Push Notifications allowed once again). This Smart Hook can be rolled out to protect your users in phases by using a OneLogin Role to determine which users will be in scope of this Smart Hook or not. <br>
Any users which have the **OneLogin Role** defined in the **target_ol_env.tfvars** file assigned will **BYPASS** this Smart Hook. <br>
Start the rollout of this Smart Hook to your environment by assigning the **OneLogin Role** defined in the **target_ol_env.tfvars** file to all users (via mappings, manually or via the Admin API) and then gradually remove the Role from users to apply this protection to their accounts.    <br>
**Always test** this Smart Hook in your **Non-Prod** environments before deploying to Production. <br>
Ensure your Redis Cache server is located as close as possible to your OneLogin Envionrment for best results (e.g US AWS/Azure Regions if your OneLogin environment is on our US Shard). This solution has been tested against Redis caches in Azure Cache for Redis and Redis Cloud. Your Redis cache needs to be publically assessible in order for Smart Hooks to be able to connect to it.

Populate the required configuration for your Smart Hook into the relevant variables in the **target_ol_env.tfvars** file.<br>
For more details on Pre Authentication Smart Hooks please see **https://developers.onelogin.com/api-docs/2/smart-hooks/types/pre-authentication**

Create an API credential for Terraform to use in your target OneLogin environment with **"Manage All" permissions**. For detail see **https://developers.onelogin.com/api-docs/2/getting-started/working-with-api-credentials** 

**START**
- From a system with Terraform and Git installed create a new folder and run 
<br></pre>`git clone https://github.com/1id-presales/Automation-OneLogin-SH.git`</pre>
- Navigate into the Switch_Policy_Multi_Auth_Attempts folder with 
<br></pre>`cd Automation-OneLogin-SH/Terraform/PreAuth/Switch_Policy_Multi_Auth_Attempts`</pre>
- Modify the contents of the file `target_ol_env.tfvars` with your favourite text editor as required.
- Set the ol_client_secret variable in your system level environment variables with `export TF_VAR_ol_client_secret=xxxxxxxxx` replacing `xxxx` with the client secret from the API credential you have already created for running Terraform against your target OneLogin Environement. Also set the password for your target Redis cache with `export TF_VAR_ol_smart_hook_redis_pw="XXXXXX"`
<br><pre>`export TF_VAR_ol_client_secret=xxxxx`</pre>
- Initialize your terraform environment by running the command 
<br><pre>`terraform init`</pre>
- Run a terraform plan operation to see what changes will be applied to your environment. Run the command 
<br></pre>`terraform plan -var-file "target_ol_env.tfvars"`</pre>
- If you are happy with the output of the plan from the previous step proceed to apply the planned changes. Apply the planned changes with the below command and enter yes at the prompt.
<br></pre>`terraform apply -var-file "target_ol_env.tfvars"`</pre> 
- Navigate to the Admin console of your target OneLogin environment and go to the events page and validate the Smart Hook has been created successfully by looking for the "Smart Hook created" event.
- To run a cleanup to remove this **Pre Authentication Smart Hook** from your target OneLogin environment run the command 
<br></pre>`terraform destroy -var-file "target_ol_env.tfvars"`</pre>
_Please note you may need to run this command twice to fully clean up the created resources._
- Navigate to the Admin console of your target OneLogin environment and go to the events page and validate the smart hook has been removed successfully by looking for the "Smart Hook deleted" event.
**END**
