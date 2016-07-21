# Usage Example


```
# Automatically redirect the log files below to /dev/stdout and /dev/stderr
# See https://github.com/jwilder/dockerize
ENV CEP_LOG_FILES=/var/log/nginx/access.log:out,/var/log/nginx/error.log:err

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint"]
# 'entrypoint' will run ~app/app.sh by default
```

See more complete usage examples at https://github.com/elifarley/docker-cep
