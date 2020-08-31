#!/bin/bash
# -*-Shell-script-*-
#
#/**
# * Title    : Cloud9 Enviroment Wizard
# * Auther   : Alex, Lee
# * Created  : 2020-08-31
# * Modified : 
# * E-mail   : cine0831@gmail.com
#**/
#
#set -e
#set -x


function usage() {
    echo "
Usage: ${0##*/} [options] <command>
Options:
    -c or -cloud9
    -k or -kubernetes
    -a or -amazon
    -g or -git
    -t or -terraform
    -h or -help
    
Examples:
    ${0##*/} -c9 create or delete
    
Description:
    -c or -cloud9           create or delete | create Cloud9
    -a or -aws              config           | configuration for AWS CLI
    -k or -k8s              config           | configuration for Kubernetes (kube config)
    -g or -git              clone            | clone Terraform source form Git Repository
    -t or -terraform        download         | downloding a Terraform Bindary
    -h or -help
"
exit 1
}

if [ $# -eq 0 ]
then
    usage
fi


# Loading configuration for Cloud9 Enviroment
if [ -f ./c9_env_wizard.conf ]
then
    . ./c9_env_wizard.conf
else 
  usage
fi


# create cloud9 resource
function create_cloud9() {
    cloud9_configure
    
    aws cloud9 create-environment-ec2 \
    --name "${c9_name}" \
    --description "${c9_description}" \
    --instance-type ${c9_instance_type} \
    --subnet-id ${c9_subnet_id} \
    --automatic-stop-time-minutes ${c9_timeout} \
    --connection-type ${c9_connection_type} \
    --owner-arn ${c9_owner_arn} \
    --tags ${c9_tags}
}

# delete cloud9 resource
function delete_cloud9() {
    cloud9_configure
    
    aws cloud9 delete-environment --environment-id ${c9_environment_id}
}

# create configuration for aws credentials
function config_aws() {
	aws_configure
	
	if [ ! -d ${AWS_CLI_HOME} ]
	then
	    mkdir -pv ${AWS_CLI_HOME}
	    
	    touch ${AWS_CLI_CREDENTALS}
        echo -e "[default]" >> ${AWS_CLI_CREDENTALS}
        echo -e "aws_access_key_id = ${AWS_ACCESS_KEY}" >> ${AWS_CLI_CREDENTALS}
        echo -e "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> ${AWS_CLI_CREDENTALS}
        echo -e "" >> ${AWS_CLI_CREDENTALS}
        
        touch ${AWS_CLI_CONFIG}
        echo -e "[default]" >> ${AWS_CLI_CONFIG}
        echo -e "region = ${DEFAULT_REGION}" >> ${AWS_CLI_CONFIG}
        echo -e "output = ${DEFAULT_OUTPUT_FORMAT}" >> ${AWS_CLI_CONFIG}
        echo -e "" >> ${AWS_CLI_CONFIG}
        
        echo -e "has been created a file. [${AWS_CLI_CREDENTALS}, ${AWS_CLI_CONFIG}"
    else
        echo -e "AWS config file is already created."
	fi
}

# create configuration for kubernetes (kube config)
function config_k8s() {
	echo "k8s"
}

# git clone for terraform source (dev, prod, modules)
function git_clone() {
    git_configure
    
    if [ ! -d ${terraform_home} ]
    then
        mkdir -pv ${terraform_modules}
        mkdir -pv ${terraform_home}/${dev_git_repo}
        #mkdir -pv ${terraform_home}/${prod_git_repo}
    fi
	
    git clone ${default_git_repo}${dev_git_repo}.git ./${terraform_home}/${dev_git_repo}
    #git clone ${default_git_repo}${prod_git_repo}.git ./${terraform_home}/${prod_git_repo}
	
    #for i in ${modules_git_repo}
    #do
    #    git clone ${default_git_repo}${i}.git  ./${terraform_modules}/${i}
    #done
}

# downloading a terraform binary
function terraform() {
	terraform_configure

    curl -s -L -O http://${terraform_binary}
    unzip -o ${terraform_archive}
    chmod -v 755 terraform
    sudo chown -v root.root terraform
    sudo mv -fv terraform /usr/local/bin
    unlink ${terraform_archive}
    
    if [ ! -f "$HOME/.terraformrc" ]
    then
        touch $HOME/.terraformrc
        echo -e "plugin_cache_dir = $HOME/.terraform.d/plugin-cache\ndisable_checkpoint = true" >> $HOME/.terraformrc
        echo -e "has been created a file. [$HOME/.terraformrc] "
    fi
}

# output an invalid option
function invalid_opt() {
	local i=$1
    echo >&2 "ERR: Invalid option: ${i}"	
}

# main
while getopts "c:a:k:g:t:h:cloud9:aws:k8s:git:terraform:help" opt
do
    case $opt in
        "c"|"cloud9")
            shift
            if [ "$@" = "create" ]
            then
                create_cloud9
            elif [ "$@" = "delete" ]
            then
                delete_cloud9
            else
                invalid_opt $@
            fi
            ;;
        "a"|"amazon")
            shift
            if [ "$@" = "config" ]
            then
                config_aws
            else
                invalid_opt $@
            fi
            ;;            
        "k"|"k8s")
            shift
            if [ "$@" = "config" ]
            then
                config_k8s
            else
                invalid_opt $@
            fi
            ;;
        "g"|"git")
            shift
            if [ "$@" = "clone" ]
            then
                git_clone
            else
                invalid_opt $@
            fi
            ;;
        "t"|"terraform")
            shift
            if [ "$@" = "download" ]
            then
                terraform
            else
                invalid_opt $@
            fi
            ;;
        "h"|"help")
            usage       
            ;;
        *) 
            usage
            ;;
    esac
done
