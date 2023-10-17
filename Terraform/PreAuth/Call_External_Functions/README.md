This Terraform configuration will create a smart hook that will call to an external function to run some custom workflow everytime a user logs into the
OneLogin portal directly but the call to the external function will not be run when users login via SP initiated flow. This example is using
Nodejs 1.8x and fetch api. 
For more information please see https://developers.onelogin.com/api-docs/2/smart-hooks/types/pre-authentication
