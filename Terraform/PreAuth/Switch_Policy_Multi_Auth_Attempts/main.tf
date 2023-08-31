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

variable "ol_smart_hook_redis_host" {
  type = string
  description = "hostname for your redis host this smart hook will connect to"
}

variable "ol_smart_hook_redis_pw" {
  type = string
  description = "password for your redis host this smart hook will connect to"
}

variable "ol_smart_hook_env_var1" {
  type = string
  description = "Name of the Smart Hooks Env Var for User Security policy to be switched into- used in pre-auth smart hook"
  default = "test"
}

variable "ol_policy_id" {
  type = string
  description = "User Security Policy ID for Policy to be switched into- used in pre-auth smart hook"
  default = "1234"
}

############ Var for Smart Hook function ################

variable "ol_smart_hook_function" {
  type = string
  description = "function for the pre-auth smart hook"
  default = <<EOF
    exports.handler = async (context) => {
console.log("Context: ", context);
// Connect to the Redis cache
  const redis = require("redis");
  const redis_host = process.env.redis_host;
  const redis_pw = process.env.redis_pw;
  const client = redis.createClient({
  port: 6379,
  host: redis_host,
  password: redis_pw
  });

  const user = context.user.username;
  const Pol_ID_STRING = process.env.attacked_user_pol;
  const Pol_ID = Number(Pol_ID_STRING);
  const key = "authAttempts:" + user;
  const authCount = await new Promise((resolve, reject) => {
    client.get(key, (err, res) => {
      if (err) {
        reject(err);
      } else {
        resolve(parseInt(res || "0"));
      }
    });
  });

if (authCount >= 3) {
    context.user.policy_id = Pol_ID;
    console.log(" This user is under attack so switching User Policy ID to " + context.user.policy_id);
  }

  client.multi()
    .incr(key)
    .expire(key, 60)
    .exec();

  // Store the authentication count in the cache
  client.set(key + "_count", authCount);

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
  data = "{ \"name\": \"${var.ol_smart_hook_env_var1}\", \"value\": \"${var.ol_policy_id}\"}"
}

resource "restapi_object" "oneloginsmarthook_vars2" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"redis_host\", \"value\": \"${var.ol_smart_hook_redis_host}\"}"
}

resource "restapi_object" "oneloginsmarthook_vars3" {
  path = "/api/2/hooks/envs"
  data = "{ \"name\": \"redis_pw\", \"value\": \"${var.ol_smart_hook_redis_pw}\"}"
}
############ Smart Hook ################

## example of how to create a new pre auth smarthook in your OneLogin environment
resource "restapi_object" "oneloginsmarthook_pa" {
  path = "/api/2/hooks"
  depends_on = [restapi_object.oneloginsmarthook_vars]
  data = "{ \"type\": \"pre-authentication\", \"disabled\":false, \"runtime\":\"nodejs18.x\", \"context_version\":\"1.1.0\", \"retries\":0, \"timeout\":1, \"options\":{\"location_enabled\":true, \"risk_enabled\":true, \"mfa_device_info_enabled\":true}, \"env_vars\":[\"${var.ol_smart_hook_env_var1}\",\"redis_host\",\"redis_pw\"], \"packages\": {\"redis\": \"3.1.2\"} , \"function\":\"${base64encode(var.ol_smart_hook_function)}\"}"
}
