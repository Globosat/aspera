#!/bin/bash
set -e -x

DATE=$(date "+%Y%m%d%H%m")
BACKUP_DIR=/tmp/bkp-config
NODE_USER=xfer2
NODE_PASS=$(curl http://169.254.169.254/latest/meta-data/instance-id)

S3_STORAGE="S3_Storage"
S3_SHARE_NAME="S3_Share"
S3_SHARE_DIRECTORY="/"

SERVER_NAME=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
SHARE_USER1="user1"
SHARE_ADMIN_GROUP="admins"
SHARE_USER_GROUP="users"


#Register SHOD
/opt/aspera/bin/alee-admin register ${CUSTOMER_ID} ${ENTITLEMENT_ID}


# Backup config
mkdir -p ${BACKUP_DIR}
cp /opt/aspera/etc/aspera.conf ${BACKUP_DIR}/aspera.conf.${DATE}

# Set Server Name
asconfigurator -F "set_server_data;server_name,${SERVER_NAME}" 


# Add Node User
#useradd ${NODE_USER}
#mkdir /home/${NODE_USER}/.ssh
#cp /opt/aspera/var/aspera_id_dsa.pub /home/${NODE_USER}/.ssh/authorized_keys
#chown -R ${NODE_USER}:${NODE_USER}  /home/${NODE_USER}/.ssh
#chmod 700 /home/${NODE_USER}/.ssh
#chmod 600 /home/${NODE_USER}/.ssh/authorized_keys
asconfigurator -F "set_user_data;user_name,${NODE_USER};absolute,${S3_BUCKET};authorization_transfer_in_value,token;authorization_transfer_out_value,token"
#/opt/aspera/bin/asnodeadmin -a -u  ${NODE_USER} -p ${NODE_PASS} -x  ${NODE_USER}


# Check documentation: https://support.asperasoft.com/entries/105778426-Shares-API-How-to-create-users-groups-and-shares-using-rake-tasks
#Create Default Groups
/opt/aspera/shares/u/shares/bin/run rake data:group:create -- --group_name ${SHARE_ADMIN_GROUP}
/opt/aspera/shares/u/shares/bin/run rake data:group:create -- --group_name ${SHARE_USER_GROUP}

#Create Default Users
/opt/aspera/shares/u/shares/bin/run rake data:user:create -- --username ${SHARE_USER1} --email ${SHARE_USER1}@globosat.com.br


# Add user to Group
/opt/aspera/shares/u/shares/bin/run rake data:group:user:add  -- --username ${SHARE_USER1} --group_name ${SHARE_ADMIN_GROUP}

# Create Node
/opt/aspera/shares/u/shares/bin/run rake data:node:create -- --name ${S3_STORAGE} --host localhost --api_username ${NODE_USER} --api_password ${NODE_PASS} --ssl true

# Create Share
/opt/aspera/shares/u/shares/bin/run rake data:share:create -- --node_name ${S3_STORAGE} --share_name ${S3_SHARE_NAME} --directory ${S3_SHARE_DIRECTORY}

service asperacentral restart
service asperanoded restart 
