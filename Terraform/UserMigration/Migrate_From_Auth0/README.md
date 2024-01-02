# How To Instructions

This example will create 4 **Smart Hook Environment Variables** and **a User Migration Smart Hook** in your target OneLogin environment. <br>
This example will deploy a **migrate users from Auth0** Smart Hook to your environment that will make an API call to the specified Auth0 environment to validate any credentials entered into the OneLogin Hosted Login page (Where the user does not already exist in the OneLogin environment) and if valiated successfully will create a new user record in OneLogin using claims in the ID Token recieved from the Auth0 environment. <br>
This example Smart Hook will execute anytime login attempts are made to your OneLogin environment where the specified username/email does not already exist. <br>
Please ensure to **delete any existing User Migration Smart Hooks** that may have been **manually** applied to your target OneLogin environment **before** you try to run this example otherwise you will get an error <br>

For more details on Smart Hooks **https://developers.onelogin.com/api-docs/2/smart-hooks/overview** <br>

Create an API credential for Terraform to use in your target OneLogin environment with **"Manage All" permissions**. For detail see **https://developers.onelogin.com/api-docs/2/getting-started/working-with-api-credentials** 

- **START**
- From a system with Terraform and Git installed create a new folder and run **git clone https://github.com/1id-presales/Automation-OneLogin-SH.git**
- Navigate into the Smart Hooks base example folder with **cd Automation-OneLogin/Terraform/UserMigration/Migrate_From_Auth0**
- Modify the contents of the file **target_ol_env.tfvars** with your favourite text editor as required
- Set the ol_client_secret variable in your system level environment variables with **export TF_VAR_ol_client_secret=xxxxxxxxx** replacing xxxx with the client secret from the API credential you have already created for running Terraform against your target OneLogin Environement
- Initialize your terraform environment by running the command **terraform init**
- Run a terraform plan operation to see what changes will be applied to your environment. Run the command **terraform plan -var-file "target_ol_env.tfvars"**
- If you are happy with the output of the plan from the previous step proceed to apply the planned changes. Apply the planned changes with the command **terraform apply -var-file "target_ol_env.tfvars"** and enter yes at the prompt.
- Navigate to the Admin console of your target OneLogin environment and validate that a Smart Hook has been successfully created by viewing the events section of admin console.
- Validate the Smart Hook is executing ok by performing a user migration test to your environment and check the events section of admin console to see some new "Smart Hook executed Successfully" events.
- To run a cleanup to remove the Smart Hook and Smart Hook environment variable from your target OneLogin environment run the command **terraform destroy -var-file "target_ol_env.tfvars"**. Please note you may need to run this command two times to successfully complete the cleanup.
- Navigate to the Admin console of your target OneLogin environment and validate both items have been deleted by viewing the events section of admin console.
- **END**
