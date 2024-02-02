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
  description = "Okta subdomain"
  default = "test"
}

variable "ol_smart_hook_env_var2" {
  type = string
  description = "Okta API Key"
  default = "test"
}

############ Var for Smart Hook function ################

variable "ol_smart_hook_function" {
  type = string
  description = "function for the pre-auth smart hook"
  default = <<EOF
const axios = require("axios");

exports.handler = async (context) => {
    // Its not considered good practice to log the user context on 
    // this hook as it contains a password. Only enable this for debugging
    // console.log(context);

    let user;

    try {
      // Do a password grant request to validate the password
      const response = await axios.post("https://" + process.env.OKTA_SUBDOMAIN + "/api/v1/authn", {
          username: context.user_identifier,
          password: context.password,
          options: {
              multiOptionalFactorEnroll: false,
              warnBeforePasswordExpired: false
          } 
      }, {
          headers: { 
              "Content-Type": "application/json",
              "Accept": "application/json"
          }
      });
      console.log(response);

      if (response.data) {

        console.log("Credentials successfully validated. Getting user profile next");
        // Get the user profile 
      const response2 = await axios.get("https://" + process.env.OKTA_SUBDOMAIN + "/api/v1/users/"+response.data._embedded.user.id, {
          headers: { 
              "Content-Type": "application/json",
              "Authorization": "SSWS" + process.env.OKTA_API_KEY
          }
      });
      console.log(response2);
      if (response2.data)
        {
        return {
          success: true,
          user: {
            username: context.user_identifier,
            password: context.password,
            firstname: response2.data.profile.firstName,
            lastname: response2.data.profile.lastName,
            email: response2.data.profile.email,
            external_id: response.data._embedded.user.id,
            department: response2.data.profile.department,
            title: response2.data.profile.title,
            phone: response2.data.profile.primaryPhone,
            company: response2.data.profile.organization,
            custom_attributes: {
                user_locale: response2.data.profile.locale,
                secondEmail: response2.data.profile.secondEmail,
                userType: response2.data.profile.userType,
                employeeNumber: response2.data.profile.employeeNumber,
                costCenter: response2.data.profile.costCenter,
                division: response2.data.profile.division,
                honorificPrefix: response2.data.profile.honorificPrefix,
                honorificSuffix: response2.data.profile.honorificSuffix
             }

          }
        };          
      }
      }
    }
    catch (error) {
        console.log("Error authenticating user ", error);         
    }  
    
    // Fail closed. Dont create the user. Deny access
    return {
        success: false,
        user: {}
    }       
}
    EOF
}

############ Smart Hook env vars ################

## example of how to create some env vars for Smart Hooks to use
resource "restapi_object" "oneloginsmarthook_vars" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"OKTA_SUBDOMAIN\", \"value\": \"${var.ol_smart_hook_env_var1}\"}"
}

## example of how to create some env vars for Smart Hooks to use
resource "restapi_object" "oneloginsmarthook_vars2" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"OKTA_API_KEY\", \"value\": \"${var.ol_smart_hook_env_var2}\"}"
}

############ Smart Hook ################

## example of how to create a new pre auth smarthook in your OneLogin environment
resource "restapi_object" "oneloginsmarthook_pa" {
  path = "/api/2/hooks"
  depends_on = [restapi_object.oneloginsmarthook_vars]
  data = "{ \"type\": \"user-migration\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"retries\":0, \"timeout\":10, \"options\":{}, \"env_vars\":[\"OKTA_SUBDOMAIN\", \"OKTA_API_KEY\"], \"packages\": {\"axios\": \"1.6.7\"} , \"function\":\"${base64encode(var.ol_smart_hook_function)}\"}"
}

