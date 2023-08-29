This Terraform configuration will create a Pre Auth smart Hook which shows an example of how to block traffic based on some context and is also
leveraging the conditions capability to limit which group of users this hook will impact. This Smart Hook will block any login requests trying to login 
to the OneLogin Portal directly and will only allow login requests where the request originated at an Service Provider / CIAM Application. This Smart Hook 
will only perform the blocking behaviour for any users which have the role id which is defined in the terraform variable "ol_sh_condition_role_id" assigned 
to their account in the target OneLogin environment. Users without this role will not be in scope of the logic contained in this smart hook. Create a Role
in your target OneLogin environment and note the ID of the Role and populate it into your .tfvars file along with other required variables  before you run 
this configuration.
For more information please see https://developers.onelogin.com/api-docs/2/smart-hooks/types/pre-authentication 
