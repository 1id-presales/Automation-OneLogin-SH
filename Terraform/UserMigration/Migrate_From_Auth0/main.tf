/* This Terraform configuration will create a user migration smart hook in your OneLogin enviornment. This Smart Hook can be used to migrate
users from an Auth0 environment to OneLogin.
For more information please see https://developers.onelogin.com/api-docs/2/smart-hooks/types/user-migration */


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
  description = "Name of the Smart Hooks Env Var to be used in user-migration smart hook"
  default = "test"
}

variable "ol_smart_hook_env_var2" {
  type = string
  description = "Name of the Smart Hooks Env Var to be used in user-migration smart hook
  default = "test"
}

variable "ol_smart_hook_env_var3" {
  type = string
  description = "Name of the Smart Hooks Env Var to be used in user-migration smart hook"
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

## example of how to create some env vars for Smart Hooks to use
resource "restapi_object" "oneloginsmarthook_vars2" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"${var.ol_smart_hook_env_var2}\", \"value\": \"${var.ol_policy_id_new_user}\"}"
}

## example of how to create some env vars for Smart Hooks to use
resource "restapi_object" "oneloginsmarthook_vars3" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"${var.ol_smart_hook_env_var3}\", \"value\": \"${var.ol_policy_id_new_user}\"}"
}

############ Smart Hook ################

## example of how to create a new pre auth smarthook in your OneLogin environment
resource "restapi_object" "oneloginsmarthook_pa" {
  path = "/api/2/hooks"
  depends_on = [restapi_object.oneloginsmarthook_vars]
  data = "{ \"type\": \"user-migration\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"context_version\":\"1.1.0\", \"retries\":0, \"timeout\":10, \"options\":{}, \"env_vars\":[\"${var.ol_smart_hook_env_var1}\",\"${var.ol_smart_hook_env_var2}\",\"${var.ol_smart_hook_env_var3}\"], \"packages\": {\"axios\": \"1.1.3\", \"jwks-rsa\":\"2.0.1\", \"jsonwebtoken\":\"8.5.1\"} , \"function\":\"${base64encode(var.ol_smart_hook_function)}\"}"
}
