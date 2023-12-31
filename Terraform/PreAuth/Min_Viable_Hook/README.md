This Terraform configuration will create a "Minimum Viable" pre authentication smart hook (with context logging enabled) in <br>
your OneLogin environment. It also creates a smart hook environment variable (in this example representing the user security <br>
policy id which we would like to switch brand new users into) which is then included in the smart hook configuration so that it  <br>
can be used within the smart hook function itself. In the function a constant called NewUserPol_ID is then declared from this smart hook <br>
environment variable. The policy ID for this new user policy ID will vary per Onelogin environment so can be set in the .tfvars file as <br>
appropriate. This minimum viable smart hook does not actually use the Policy ID as it just passes through all requests to the  <br> 
statically assigned policy for each user so it is just shown here for illustrative purposes. This example also is configured to use <br> 
the latest context version (which is currently 1.1.0) and with all context options enabled (MFA Devices, Location and Risk). This information <br>
should be visible in the logs for this smarthook assuming you have all relevant Product SKUs. Finally this example shows how to pull a <br>
NPM module into your function to be used in your logic. In this case we are pulling in the AXIOS package for illustrative purposes <br>
but its not actually being used in the Smart Hook Function. This hook will be applied to ALL USERS in your environment as it does not <br>
utilize the "Conditions" capability to scope which users the Smart Hook shoud or should not apply to. See other examples in this REPO <br>
for Conditions scoping. <br>
For more information please see https://developers.onelogin.com/api-docs/2/smart-hooks/types/pre-authentication  <br>
