# How To Instructions

This example will create **a Pre Authentication Smart Hook** in your target OneLogin environment. <br>
Populate the required configuration for your Smart Hook into the relevant variables in the **target_ol_env.tfvars** file.<br>
For more details on Pre Authentication Smart Hooks please see **https://developers.onelogin.com/api-docs/2/smart-hooks/types/pre-authentication**

Create an API credential for Terraform to use in your target OneLogin environment with **"Manage All" permissions**. For detail see **https://developers.onelogin.com/api-docs/2/getting-started/working-with-api-credentials** 

- **START**
- From a system with Terraform and Git installed create a new folder and run **git clone https://github.com/1id-presales/Automation-OneLogin.git**
- Navigate into the Switch_Policy_Multi_Auth_Attempts folder with **cd Automation-OneLogin-SH/Terraform/PreAuth/Switch_Policy_Multi_Auth_Attempts**
- Modify the contents of the file **target_ol_env.tfvars** with your favourite text editor as required..
- Set the ol_client_secret variable in your system level environment variables with **export TF_VAR_ol_client_secret=xxxxxxxxx** replacing xxxx with the client secret from the API credential you have already created for running Terraform against your target OneLogin Environement.
- Initialize your terraform environment by running the command **terraform init**
- Run a terraform plan operation to see what changes will be applied to your environment. Run the command **terraform plan -var-file "target_ol_env.tfvars"**
- If you are happy with the output of the plan from the previous step proceed to apply the planned changes. Apply the planned changes with the command **terraform apply -var-file "target_ol_env.tfvars"** and enter yes at the prompt.
- Navigate to the Admin console of your target OneLogin environment and go to the events page and validate the smart hook has been created successfully by looking for the "Smart Hook created" event.
- To run a cleanup to remove this **Pre Authentication Smart Hook** from your target OneLogin environment run the command **terraform destroy -var-file "target_ol_env.tfvars"**. Please note you may need to run this command twice to fully clean up the created resources.
- Navigate to the Admin console of your target OneLogin environment and go to the events page and validate the smart hook has been removed successfully by looking for the "Smart Hook deleted" event.
- **END**
