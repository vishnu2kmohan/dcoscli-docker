# dcoscli-docker

[Mesosphere DCOS CLI](https://docs.mesosphere.com/using/cli/) based on [Alpine Linux](http://alpinelinux.org/about/)

Note: You can specify the URL of your DCOS cluster upon startup
- e.g., `docker run -i -t vishnumohan/alpine-dcoscli:nosubcmd https://dcos.elb.amazonaws.com`
- `alpine-dcoscli:latest` contains some of the subcommands for [DCOS Services](https://docs.mesosphere.com/reference/servicestatus/)
- `alpine-dcoscli:nosubcmd` contains none of the DCOS Services subcommands

References:
- [Mesosphere DCOS Documentation](https://docs.mesosphere.com)
- [Alpine Linux Wiki](http://wiki.alpinelinux.org/wiki/Main_Page)
