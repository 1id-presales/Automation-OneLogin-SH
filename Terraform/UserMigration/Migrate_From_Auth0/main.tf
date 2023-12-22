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
  description = "subdomain name of the target Auth0 env"
  default = "test"
}

variable "ol_smart_hook_env_var2" {
  type = string
  description = "Client ID for the OIDC app created in target Auth0 env for the password grant flow"
  default = "test"
}

variable "ol_smart_hook_env_var3" {
  type = string
  description = "Client secret for the OIDC app created in target Auth0 env for the password grant flow"
  default = "test"
}

############ Var for Smart Hook function ################

variable "ol_smart_hook_function" {
  type = string
  description = "function for the pre-auth smart hook"
  default = <<EOF
const axios = require("axios");
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
 
function getKey(header, callback){
  var client = jwksClient({
    jwksUri: "https://dev-1pj8qain83akz0dv.us.auth0.com/.well-known/jwks.json"
  });
 
  client.getSigningKey(header.kid, function(err, key) {
    var signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}
 
async function verifyJWT(token) {
  return new Promise(
    (resolve, reject) => {
      jwt.verify(token, getKey, {}, function(err, decoded) {
        resolve(decoded)
      });     
    }
  );
}
 
exports.handler = async (context) => {
    // Its not considered good practice to log the user context on
    // this hook as it contains a password. Only enable this for debugging
    console.log(context);
 
    let user;
 
    try {
      // Do a password grant request to validate the password
      const response = await axios.post("https://dev-1pj8qain83akz0dv.us.auth0.com/oauth/token", {
          grant_type: "password",
          username: context.user_identifier,
          password: context.password,
          scope: "openid",
          client_id: process.env.AUTH0_CLIENT_ID_v2,
          client_secret: process.env.AUTH0_CLIENT_SECRET_v2
      }, {
          headers: {
              "Content-Type": "application/json"
          }
      });
      console.log(response);
 
      if (response.data) {
        let decodedToken = await verifyJWT(response.data.id_token);
        console.log(decodedToken);
 
        let name = decodedToken.name.split(" ");
 
        return {
          success: true,
          user: {
            username: context.user_identifier,
            password: context.password,
            firstname: name.shift(),
            lastname: name.join(" "),
            department: "Migration Hook User",
            email: decodedToken.email
          }
        };         
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
  data = "{ \"name\": \"AUTH0_SUBDOMAIN\", \"value\": \"${var.ol_smart_hook_env_var1}\"}"
}

## example of how to create some env vars for Smart Hooks to use
resource "restapi_object" "oneloginsmarthook_vars2" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"AUTH0_CLIENT_ID\", \"value\": \"${var.ol_smart_hook_env_var2}\"}"
}

## example of how to create some env vars for Smart Hooks to use
resource "restapi_object" "oneloginsmarthook_vars3" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"AUTH0_CLIENT_SECRET\", \"value\": \"${var.ol_smart_hook_env_var3}\"}"
}

############ Smart Hook ################

## example of how to create a new pre auth smarthook in your OneLogin environment
resource "restapi_object" "oneloginsmarthook_pa" {
  path = "/api/2/hooks"
  depends_on = [restapi_object.oneloginsmarthook_vars]
  data = "{ \"type\": \"user-migration\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"retries\":0, \"timeout\":10, \"options\":{}, \"env_vars\":[\"AUTH0_SUBDOMAIN\",\"AUTH0_CLIENT_ID\",\"AUTH0_CLIENT_SECRET\"], \"packages\": {\"axios\": \"1.1.3\", \"jwks-rsa\":\"2.0.1\", \"jsonwebtoken\":\"8.5.1\"} , \"function\":\"${base64encode(var.ol_smart_hook_function)}\"}"
}
