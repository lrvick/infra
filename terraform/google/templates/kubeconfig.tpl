apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${certificate_authority_data}
    server: ${server}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: ${username}
  name: default-context
current-context: default-context
kind: Config
preferences: {}
users:
- name: ${username}
  user:
    password: ${password}
    username: ${username}

