/* This Terraform configuration will create a smart hook that will call to an external function to run some custom workflow everytime a user logs into the
OneLogin portal directly but the call to the external function will not be run when users login via SP initiated flow. This example is using
Nodejs 1.8x and fetch api. 
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

variable "external_function_url" {
  type = string
  description = "Url for the External function to be called by smart hooks"
}

############ Var for Smart Hook function ################

variable "ol_smart_hook_function" {
  type = string
  description = "function for the pre-auth smart hook"
  default = <<EOF
    exports.handler = async (context) => {
let user = context.user;
let function_url = process.env.ext_function_url
console.log("Context: ", context);
if (!context.app.id) 
{console.log("User is trying to log into OneLogin Portal directly so making a call to the External Function");
// Execute call to external function
      const response = await fetch(function_url);
      const data = await response.json();
      console.log(data);
}
else {
		console.log("User not trying to login directly to OneLogin Portal. Doing nothing");
	}
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
  data = "{ \"name\": \"ext_function_url\", \"value\": \"${var.external_function_url}\"}"
}

############ Smart Hook ################

## example of how to create a new pre auth smarthook in your OneLogin environment
resource "restapi_object" "oneloginsmarthook_pa" {
  path = "/api/2/hooks"
  depends_on = [restapi_object.oneloginsmarthook_vars]
  data = "{ \"type\": \"pre-authentication\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"context_version\":\"1.1.0\", \"retries\":0, \"timeout\":1, \"options\":{\"location_enabled\":true, \"risk_enabled\":true, \"mfa_device_info_enabled\":true}, \"env_vars\":[\"ext_function_url\"], \"packages\": {} , \"function\":\"${base64encode(var.ol_smart_hook_function)}\"}"
}
