/* This Terraform configuration will create a  
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
  description = "Name of the Smart Hooks Env Var for the New user first time login policy- used in pre-auth smart hook"
  default = "test"
}

variable "ol_policy_id_new_user" {
  type = string
  description = "User Security Policy ID for New user first time login- used in pre-auth smart hook"
  default = "1234"
}

############ Var for Smart Hook function ################

variable "ol_smart_hook_function" {
  type = string
  description = "function for the pre-auth smart hook"
  default = <<EOF
    exports.handler = async (context) => {
const NewUserPol_ID = process.env.NewUserPol;
console.log("Context: ", context);

  return {
    success: true,
    user: {
      policy_id: context.user.policy_id
    }
  }
}
    EOF
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
  data = "{ \"type\": \"pre-authentication\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"context_version\":\"1.1.0\", \"retries\":0, \"timeout\":1, \"options\":{\"location_enabled\":true, \"risk_enabled\":true, \"mfa_device_info_enabled\":true}, \"env_vars\":[\"${var.ol_smart_hook_env_var1}\"], \"packages\": {\"axios\": \"0.21.1\"} , \"function\":\"${base64encode(var.ol_smart_hook_function)}\"}"
}
