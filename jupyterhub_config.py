c = get_config()  #noqa

c.Spawner.cmd = ['jupyter-labhub', '--allow-root']
c.JupyterHub.admin_access = True
c.Authenticator.allowed_users = {'root'}
