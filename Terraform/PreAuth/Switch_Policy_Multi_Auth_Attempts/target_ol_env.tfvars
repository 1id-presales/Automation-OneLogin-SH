########## set ol_client_secret via your environment variables with the command export TF_VAR_ol_client_secret="xxxxxxx". Do not store in text files ########## 

ol_subdomain = ""   # required - e.g if your onelogin environment is ignore.onelogin.com then enter "ignore".
ol_client_id = ""    # required - client ID for the API credential you have set up in your target environment for Terraform to use.
ol_smart_hook_redis_host = ""   # required - Hostname for the Redis Cache server you will use in your solution. 
ol_smart_hook_redis_pw = ""   # required - Password for the Redis Cache server you will use in your solution. 
ol_smart_hook_redis_port = ""   # required - Port for the Redis Cache server you will use in your solution. 
ol_policy_id = "" # required - User Policy ID from your target OneLogin environment where push notifications have been disabled on.
ol_sh_condition_role_id = ""   # required - Role ID in your target OneLogin environent which which will be excluded. i.e users with this role assigned to them will bypass this smarthook.
