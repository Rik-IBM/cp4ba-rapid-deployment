##
## Licensed Materials - Property of IBM
## 5737-I23
## Copyright IBM Corp. 2018 - 2022. All Rights Reserved.
## U.S. Government Users Restricted Rights:
## Use, duplication or disclosure restricted by GSA ADP Schedule
## Contract with IBM Corp.
##

# Sample script for running the DB2 scripts non-interactively by providing the needed env vars
# To use:  Make a copy and name it "common_for_DB2.sh", update the needed variables.


# --- For Base BACA DB:
# update these variables for the BACA Base database
base_db_name=BASECA
base_db_user=db2inst1


# To skip creating base database user and skip asking for pwd, use these vars below.  
# Prereq is that the DB2 user (from var "base_db_user") must already be created.
base_valid_user=1
base_user_already_defined=1
base_pwdconfirmed=1

# --- For adding tenant:
# update these variables
tenant_type=0   # Allowed values: 0 for Enterprise, 1 for Trial, 2 for Internal
# baca_database_server_ip=
# baca_database_port=

## JDR: In our scripts we setup the tenant_id before calling the script 
## so that we can modify this value at runtime  
#tenant_id=
#tenant_db_name=$tenant_id
#tenant_dsn_name=$tenant_id
tenant_db_user=db2inst1

# To skip creating tenant database user and skip asking for pwd, use these vars below.  
# Prereq is that the DB2 user (from var "tenant_db_user") must already be created.
user_already_defined=1
pwdconfirmed=1

# update these variables
tenant_db_pwd=Cp4badm1n
# tenant_db_pwd_b64_encoded=0  # set to 1 if "tenant_db_pwd" is base64 encoded
tenant_ontology=default

# tenant_company=
# tenant_first_name=
# tenant_last_name=
# tenant_email=m
# tenant_user_name=

# --- For adding ontology to existing tenant
# uncomment this below to add ontology, and comment out "tenant_ontology" line above in this file
#use_existing_tenant=1
#tenant_ontology=ONT2

# skip confirmation prompts:
confirmation=y

#DB2 ssl Yes/No
ssl=No
