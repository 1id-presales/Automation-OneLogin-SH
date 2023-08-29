This Terraform configuration will create a "Minimum Viable" pre authentication smart hook (with context logging enabled) in 
your OneLogin environment. It also creates a smart hook environment variable (in this example representing the user security 
policy id which we would like to switch brand new users into) which is then included in the smart hook configuration so that it 
can be used within the smart hook function itself. In the function a constant called NewUserPol_ID is then declared from this smart hook 
environment variable. The policy ID for this new user policy ID will vary per Onelogin environment so can be set in the .tfvars file as 
appropriate. This minimum viable smart hook does not actually use the Policy ID as it just passes through all requests to the 
statically assigned policy for each user so it is just shown here for illustrative purposes. This example also is configured to use 
the latest context version (which is currently 1.1.0) and with all context options enabled (MFA Devices, Location and Risk). This information 
should be visible in the logs for this smarthook assuming you have all relevant Product SKUs. Finally this example shows how to pull a 
NPM module into your function to be used in your logic. In this case we are pulling in the AXIOS package for illustrative purposes
but its not actually being used in the Smart Hook Function. This hook will be applied to ALL USERS in your environment as it does not
utilize the "Conditions" capability to scope which users the Smart Hook shoud or should not apply to. See other examples in this REPO
for Conditions scoping.
For more information please see https://developers.onelogin.com/api-docs/2/smart-hooks/types/pre-authentication
