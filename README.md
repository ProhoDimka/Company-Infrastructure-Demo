# Introduction
The main purpose of this demo is to demonstrate the capabilities of deploying an organization's infrastructure using a cloud-based approach.
Once you complete the installation process, you will have:
1. Gitlab instance
2. Gitlab Runner Shell instance
3. Kubernetes self-managed cluster
4. PostgreSQL in k8s
5. Vault in k8s

# Prerequisites
You should have:
* an [AWS Account Credentials](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html)
* a registered domain name, because AWS hosted domain zone will be created

Applications:
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [TERRAFORM](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [Hashicorp Vault](https://developer.hashicorp.com/vault/install?product_intent=vault)
* [Hashicorp Packer](https://developer.hashicorp.com/packer/install?product_intent=packer)

# Installation process
1. Generate your ~/.ssh/k8s-nodes key pair, it will be used for ssh connection between your k8s nodes and gitlab instances.
2. File changes:
   * Find-and-Replace in all project:
     * find: example-domain.com
     * replace with: your-domain-name.com
   * Find-and-Replace in all project:
     * find: example-domain-com
     * replace with: your-domain-name-com
   * [Packer File](infra/main/k8s_cluster/packer_ubuntu.pkr.hcl) if need:
     * change your region
     * source_ami (Ubuntu 22.04 Server)
     * provisioner "file" sources to private and public ssh keys
   * Modules values file [variables.tf](infra/main/variables.tf), change values:
     * region
     * vpc_id
     * account_domain_init_name
     * ami_id (we will receive it's value in next steps after Packer build will be finished)
   * Setup remote terraform file properties [terraform.tf](infra/main/terraform.tf)
     * region
     * bucket
     * key
   * Create S3 bucket and DynamoDB table with script commented in [terraform.tf](infra/main/terraform.tf) with the same properties
   * [Gitlab Installation File](infra/main/gitlab-master/scripts/2_gitlab_install.sh)
      * fix EXTERNAL_URL with your domain name
      * delete if you have not Identity Provider or change gitlab_rails['omniauth_providers'] property if you have IdP.
   * [Gitlab Instance Module](infra/main/4_ec2_instance_gitlab.tf)
      * Mannualy upload your ssh public key to AWS Console and set "aws_ssh_key_name" property with that name
      * If you will change "additional_volumes" size - fix these values in [Gitlab Install Playbook](infra/main/gitlab-master/playbook_gitlab_apply_restore.yaml)
3. Change dir to our workspace dir:
```shell
cd infra/main
```
4. Packer build image for k8s instances:
```shell
cd k8s_cluster
packer build packer_ubuntu.pkr.hcl
```
5. After build will finished successfully set ami_id value in [TF Values File](infra/main/variables.tf)
6. Initialize common infrastructure and gitlab standalone instance:
```shell
cd ..
./infra_launch_1st_1_main_init_local.sh
```
7. In case it was you first time launch and gitlab was never backuped before:
   * you should login gitlab with your admin credentials and take a runner join token.
   * Insert this token to [runner install file](infra/main/gitlab-master-runner/scripts/3_link_runner_with_gitlab.sh) 
set RUNNER_JOIN_TOKEN environment variable
8. Initialize gitlab shell runner:
```shell
./infra_launch_1st_2_gitlab_runner.sh
```
9. Next infrastructure deploying stages were implimented with gitlab pipline.
10. In case it was your first time deploy and gitlab was never backuped before:
    * Setup new project
    * upload your personal ssh public key
    * add remotes in your local to push this project to gitlab
    * change [.gitlab-ci.yml](.gitlab-ci.yml) to setup your own include.*.project paths.
11. Push your project to gitlab.
12. Login gitlab and create project trigger token - Project Settings->CI/CD->Pipeline trigger tokens
13. Insert your domain name, project ID and trigger Token to this script and execute it:
```shell
TRIGGER_TOKEN=*token*
DOMAIN_NAME=gitlab-master.example-domain.com
PROJECT_ID=1
GITLAB_PROJECT_URL="https://${DOMAIN_NAME}/api/v4/projects/${PROJECT_ID}/trigger/pipeline"
curl --request POST \
    --form token="${TRIGGER_TOKEN}" \
    --form ref=master \
    --form "variables[TEST_CI]=true" \
    "${GITLAB_PROJECT_URL}"
```
14. Follow pipeline logs in Gitlab
15. To download and install kubeconfig execute:
```shell
# Attention! That execution will overwrite your original kubeconfig file
./infra_k8s_get_kubeconfig.sh true
cp k8s_cluster/from_main_master/.kube/admin_config.conf ~/.kube/config
```
