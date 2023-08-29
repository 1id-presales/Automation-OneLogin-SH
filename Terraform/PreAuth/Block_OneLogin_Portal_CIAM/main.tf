/* This Terraform configuration will create a Pre Auth smart Hook which shows an example of how to block traffic based on some context and is also
leveraging the conditions capability to limit which group of users this hook will impact. This Smart Hook will block any login requests trying to login 
to the OneLogin Portal directly and will only allow login requests where the request originated at an Service Provider / CIAM Application. This Smart Hook 
will only perform the blocking behaviour for any users which have the role id which is defined in the terraform variable "ol_sh_condition_role_id" assigned 
to their account in the target OneLogin environment. Users without this role will not be in scope of the logic contained in this smart hook. Create a Role
in your target OneLogin environment and note the ID of the Role and populate it into your .tfvars file along with other required variables  before you run 
this configuration.
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

variable "ol_sh_condition_role_id" {
  type = string
  description = "Role ID for the role which the Smart Hook condition capability is using"
}

############ Var for Smart Hook function ################

variable "ol_smart_hook_function" {
  type = string
  description = "function for the pre-auth smart hook"
  default = <<EOF
    exports.handler = async (context) => {
let user = context.user;
console.log("Context: ", context);
if (!context.app.id) return { success: false, user: null };
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

############ Smart Hook ################

## example of how to create a new pre auth smarthook in your OneLogin environment
resource "restapi_object" "oneloginsmarthook_pa" {
  path = "/api/2/hooks"
  data = "{ \"type\": \"pre-authentication\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"context_version\":\"1.1.0\", \"retries\":0, \"timeout\":1, \"options\":{\"location_enabled\":true, \"risk_enabled\":true, \"mfa_device_info_enabled\":true}, \"env_vars\":[], \"packages\": {} , \"conditions\":[{\"source\":\"roles\", \"operator\":\"~\",\"value\":\"${var.ol_sh_condition_role_id}\"}] , \"function\":\"${base64encode(var.ol_smart_hook_function)}\"}"
}
