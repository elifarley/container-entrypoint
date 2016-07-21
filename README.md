# Usage Example


```
# Automatically create symlinks for log files below.
# See https://github.com/jwilder/dockerize
ENV CEP_LOG_FILES=/var/log/nginx/access.log:out,/var/log/nginx/error.log:err

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint"]
# 'entrypoint' will run $HOME/app.sh by default
```

## See also
https://github.com/elifarley/docker-cep
