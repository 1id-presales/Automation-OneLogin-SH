########## set ol_client_secret via your environment variables with the command export TF_VAR_ol_client_secret="xxxxxxx". Do not store in text files ########## 

ol_subdomain = ""            # required - OneLogin subdomain name
ol_client_id = ""            # required - API credential Client ID from your OneLogin env
ol_smart_hook_env_var1 = ""  # required - Auth0 subdomain token endpoint e.g https://xxxxxxxxx.us.auth0.com/oauth/token
ol_smart_hook_env_var2 = ""  # required - Auth0 subddomain jwks e.g https://xxxxxxxxx.us.auth0.com/.well-known/jwks.json
ol_smart_hook_env_var3 = ""  # required - Auth0 OIDC App Client ID
ol_smart_hook_env_var4 = ""  # required - Auth0 OIDC App Client Secret
