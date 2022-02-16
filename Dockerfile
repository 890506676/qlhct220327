FROM whyour/qinglong:latest
ADD file:9233f6f2237d79659a9521f7e390df217cec49f1a8aa3a12147bbca1956acdb9 in / 
CMD ["/bin/sh"]
ENV NODE_VERSION=17.5.0
/bin/sh -c addgroup -g 1000 node     && adduser -u 1000 -G node -s /bin/sh -D node     && apk add --no-cache         libstdc++     && apk add --no-cache --virtual .build-deps         curl     && ARCH= && alpineArch="$(apk --print-arch)"       && case "${alpineArch##*-}" in         x86_64)           ARCH='x64'           CHECKSUM="8f4f13abbaf553b102984dc68d2d0c66a12084fbb2a211416e1aaedaaf6eae64"           ;;         *) ;;       esac   && if [ -n "${CHECKSUM}" ]; then     set -eu;     curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz";     echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c -       && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner       && ln -s /usr/local/bin/node /usr/local/bin/nodejs;   else     echo "Building from source"     && apk add --no-cache --virtual .build-deps-full         binutils-gold         g++         gcc         gnupg         libgcc         linux-headers         make         python3     && for key in       4ED778F539E3634C779C87C6D7062848A1AB005C       94AE36675C464D64BAFA68DD7434390BDBE9B9C5       74F12602B6F1C4E913FAA37AD3A89613643B6201       71DCFD284A79C3B38668286BC97EC7A07EDE3FC1       8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600       C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8       C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C       DD8F2338BAE7501E3DD5AC78C273792F7D83545D       A48C2BEE680E841632CD4E44F07496B3EB3C1762       108F52B48DB57BB0CC439B2997B01419BD92F80A       B9E2F5981AA6E0CD28160D9FF13993A75599653C     ; do       gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" ||       gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ;     done     && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz"     && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"     && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc     && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c -     && tar -xf "node-v$NODE_VERSION.tar.xz"     && cd "node-v$NODE_VERSION"     && ./configure     && make -j$(getconf _NPROCESSORS_ONLN) V=     && make install     && apk del .build-deps-full     && cd ..     && rm -Rf "node-v$NODE_VERSION"     && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt;   fi   && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"   && apk del .build-deps   && node --version   && npm --version
ENV YARN_VERSION=1.22.17
/bin/sh -c apk add --no-cache --virtual .build-deps-yarn curl gnupg tar   && for key in     6A010C5166006599AA17F08146C2130DFD2497F5   ; do     gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" ||     gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ;   done   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz"   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc"   && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz   && mkdir -p /opt   && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/   && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn   && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg   && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz   && apk del .build-deps-yarn   && yarn --version
COPY file:4d192565a7220e135cab6c77fbc1c73211b69f3d9fb37e62857b2c6eb9363d51 in /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node"]
ARG QL_MAINTAINER=whyour
LABEL maintainer=whyour
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LANG=zh_CN.UTF-8 SHELL=/bin/bash PS1=\u@\h:\w $
COPY package.json / # buildkit
RUN |1 QL_MAINTAINER=whyour /bin/sh -c set -x     && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories     && apk update -f     && apk upgrade     && apk --no-cache add -f bash                              coreutils                              moreutils                              git                              curl                              wget                              tzdata                              perl                              openssl                              nginx                              python3                              jq                              openssh                              py3-pip                              python2                              g++                              make     && rm -rf /var/cache/apk/*     && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime     && echo "Asia/Shanghai" > /etc/timezone     && touch ~/.bashrc     && git config --global user.email "qinglong@@users.noreply.github.com"     && git config --global user.name "qinglong"     && npm install -g pnpm     && pnpm install -g pm2     && pnpm install -g ts-node typescript tslib     && cd / && pnpm install --prod     && apk --purge del python2 g++ make     && rm -rf /root/.npm     && rm -rf /root/.pnpm-store     && rm -rf /root/.cache     && rm -f /package.json # buildkit
CMD ["node"]
ARG QL_MAINTAINER=whyour
LABEL maintainer=whyour
ARG QL_URL=https://github.com/whyour/qinglong.git
ARG QL_BRANCH=master
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LANG=zh_CN.UTF-8 SHELL=/bin/bash PS1=\u@\h:\w $  QL_DIR=/ql QL_BRANCH=v2.11.3
WORKDIR /ql
RUN |3 QL_MAINTAINER=whyour QL_URL=https://github.com/whyour/qinglong.git QL_BRANCH=v2.11.3 /bin/sh -c git clone -b ${QL_BRANCH} ${QL_URL} ${QL_DIR}     && cd ${QL_DIR}     && cp -f .env.example .env     && chmod 777 ${QL_DIR}/shell/*.sh     && chmod 777 ${QL_DIR}/docker/*.sh     && cp -rf /node_modules ./     && rm -rf /node_modules     && pnpm install --prod     && rm -rf /root/.pnpm-store     && rm -rf /root/.cache     && git clone -b ${QL_BRANCH} https://github.com/${QL_MAINTAINER}/qinglong-static.git /static     && cp -rf /static/* ${QL_DIR}     && rm -rf /static # buildkit
EXPOSE 5700
ENTRYPOINT ["./docker/docker-entrypoint.sh"]
