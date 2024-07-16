#!/usr/bin/bash

#set -e

export GITLAB_VERSION=16.11.4-ce.0
export EXTERNAL_URL="https://gitlab-master.example-domain.com"

# Add gitlab repo to apt
sudo apt update
sudo apt install -y curl openssh-server ca-certificates tzdata perl
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

# Install Gitlab
## Check if gitlab volumes have configs
GITLAB_VOLUMES_HAVE_CONFIG=false
if test /etc/gitlab/gitlab.rb; then
  GITLAB_VOLUMES_HAVE_CONFIG=true
fi

# apt-cache madison gitlab-ce
sudo apt update
sudo EXTERNAL_URL=${EXTERNAL_URL} apt install gitlab-ce=${GITLAB_VERSION} -y
#sudo apt install gitlab-ce=${GITLAB_VERSION} -y

# Specifiy version: sudo EXTERNAL_URL="https://gitlab.example.com" apt-get install gitlab-ee=16.2.3-ee.0
# Pin the version to limit auto-updates: sudo apt-mark hold gitlab-ce
# Show what packages are held back: sudo apt-mark showhold

sudo apt-mark hold gitlab-ce
sudo apt-mark showhold

### https://docs.gitlab.com/ee/integration/saml.html

### OmniAuth Settings
###! Docs: https://docs.gitlab.com/ee/integration/omniauth.html

if [ "${GITLAB_VOLUMES_HAVE_CONFIG}" == "true" ]; then
  echo "Gitlab volumes have configs"
  exit 0
fi

echo "Gitlab volumes haven't configs"

cat <<EOF | sudo tee -a /etc/gitlab/gitlab.rb
git_data_dirs({
  "default" => {
    "path" => "/mnt/gitlab_data"
   }
})
gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = true
gitlab_rails['omniauth_providers'] = [
  {
    name: "saml",
    label: "AWS Login", # optional label for login button, defaults to "Saml"
    args: {
      assertion_consumer_service_url: "https://gitlab-master.example-domain.com/users/auth/saml/callback",
      idp_cert_fingerprint: "d8:6e:be:a7:b8:38:1d:5b:1d:15:18:4c:4d:05:dd:be:ba:41:a7:5d",
      idp_sso_target_url: "https://portal.sso.eu-central-1.amazonaws.com/saml/assertion/MTA3NzYzODU3NDE1X2lucy1hZDlmNTM3Y2M2ZjA5YTQ3",
      issuer: "https://gitlab-master.example-domain.com",
      name_identifier_format: "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
      attribute_statements: { nickname: ['username'] }
    }
  }
]

gitlab_rails['backup_path'] = '/mnt/gitlab_data/gitlab_backups'
gitlab_rails['backup_keep_time'] = 2419200
EOF

sudo gitlab-ctl reconfigure

exit 0
