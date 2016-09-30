#!/usr/bin/python

# Args:
# arg1 - env variables json file path

import sys
import json
import shutil
import os
import traceback
import base64

CONFIG_MAP_NAME = "env.vars.config"
SECRET_NAME = "secret.vars.config"

secrets_file_template = """
apiVersion: v1
kind: Secret
metadata:
  name: {secret_name}
type: Opaque
data:
"""

configmap_file_template = """
kind: ConfigMap
apiVersion: v1
metadata:
  name: {config_map_name}
  namespace: default
data:
"""

vars_file_name = sys.argv[1]
print 'Extracting vars and secrets from %s' % vars_file_name

try:
    with open(vars_file_name, 'rU') as f:
        file_json = json.load(f)
        secrets = file_json['secrets']
        vars = file_json['vars']

        with open('secrets.yaml', 'wb') as f:
            f.write(secrets_file_template.format(**dict(secret_name=SECRET_NAME)))

            for key in secrets:
                f.write('  %s: %s\n' % (key, base64.b64encode(secrets[key])))

        with open('config-map.yaml', 'wb') as f:
            f.write(configmap_file_template.format(**dict(config_map_name=CONFIG_MAP_NAME)))

            for key in vars:
                f.write('  %s: %s\n' % (key, vars[key]))

except Exception, e:
    print traceback.format_exc()
