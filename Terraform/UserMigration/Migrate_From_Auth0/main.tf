/* This Terraform configuration will create a "Minimum Viable" pre authentication smart hook (with context logging enabled) in 
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
For more information please see https://developers.onelogin.com/api-docs/2/smart-hooks/types/pre-authentication */


terraform {
  required_providers {
    restapi = {
      source = "Mastercard/restapi"
      version = "1.18.0"
    }
  }
} 

provider "restapi" {
  # Configuration options
   uri                  = "https://${var.ol_subdomain}.onelogin.com/"
   write_returns_object = true
   oauth_client_credentials {
      oauth_client_id = var.ol_client_id
      oauth_client_secret = var.ol_client_secret
      oauth_token_endpoint = "https://${var.ol_subdomain}.onelogin.com/auth/oauth2/v2/token"
  }
}

########## Terraform VARS ###########

variable "ol_subdomain" {
  type = string
  description = "Subdomain name for target OneLogin env"
}

variable "ol_client_id" {
  type = string
  description = "Client ID for API Credential created in target OneLogin env"
}

variable "ol_client_secret" {
  type = string
  description = "Client Secret for API Credential created in target OneLogin env"
}

variable "ol_smart_hook_env_var1" {
  type = string
  description = "Name of the Smart Hooks Env Var for the New user first time login policy- used in user-migration smart hook"
  default = "test"
}


############ Var for Smart Hook function ################

variable "ol_smart_hook_function" {
}

############ Smart Hook env vars ################

## example of how to create some env vars for Smart Hooks to use
resource "restapi_object" "oneloginsmarthook_vars" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"${var.ol_smart_hook_env_var1}\", \"value\": \"${var.ol_policy_id_new_user}\"}"
}

############ Smart Hook ################

## example of how to create a new pre auth smarthook in your OneLogin environment
resource "restapi_object" "oneloginsmarthook_pa" {
  path = "/api/2/hooks"
  depends_on = [restapi_object.oneloginsmarthook_vars]
  data = "{ \"type\": \"user-migration\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"context_version\":\"1.1.0\", \"retries\":0, \"timeout\":10, \"options\":{}, \"env_vars\":[\"${var.ol_smart_hook_env_var1}\"], \"packages\": {\"axios\": \"1.1.3\"} , \"function\":\"${base64encode(var.ol_smart_hook_function)}\"}"
}
