# This image provides tools for OCD. 
# The following packages are installed as latest available on centos7:
#  - git https://jwiegley.github.io/git-from-the-bottom-up/
#  - cowsay https://en.wikipedia.org/wiki/Cowsay
#  - jq  https://stedolan.github.io/jq/
#  - yq https://github.com/kislyuk/yq
# The following packages are downloaded and installed using an explict version number:
#  - hub 2.4.0 https://hub.github.com 
#  - oc 3.9.0 https://docs.openshift.org/latest/cli_reference/index.html
#  - git-secret 0.2.4 http://git-secret.io
#  - gpg 2.2.9 https://www.gnupg.org)
#  - helm 2.9.0 
#  - webhook 2.6.9

FROM simonmassey/ocd-tools

LABEL maintainer "Simon Massey <simbo1905@60hertz.com>"

RUN mkdir /opt/app-root/src/.kube && chmod -R a+w /opt/app-root/src/.kube

RUN mkdir /opt/app-root/src/hooks && chgrp 0 /opt/app-root/src/hooks && chmod g+w /opt/app-root/src/hooks

COPY hooks.json /opt/app-root/src/hooks

COPY ./bin/* /usr/local/bin/

USER 1001

EXPOSE 9000

WORKDIR "/opt/app-root/src/hooks"

CMD  ["/usr/local/bin/webhook", "-verbose", "-hotreload", "-template"]
