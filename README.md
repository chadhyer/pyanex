# PYANEX Python-Ansible-Executor

## Encrypt String
`ansible-vault encrypt_string --vault-password-file <file> 'string' --name 'string_name'`

## Docker

### Entrypoint
`python3 -m pyanex.exe <args>`
`python3 -m pyanex.exe -p <playbook> -i <inventory> -v <vault-key>`

## ssh key
`eval "$(ssh-agent -s)"`
`ssh-add <path-to-key>`