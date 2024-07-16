# Gitlab install script

```shell
cd "${PROJECT_ROOT}/infra/main"
ansible-playbook -i gitlab/hosts gitlab/playbook_gitlab_apply_restore.yaml
ansible-playbook -i gitlab/hosts gitlab/playbook_gitlab_destroy_backup.yaml
```