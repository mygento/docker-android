FROM openjdk:11-jdk

RUN apt-get -qq update && \
    apt-get -qqy install curl wget tar unzip lib32stdc++6 lib32z1 uuid-runtime

# make the "en_US.UTF-8" locale so gradle will be utf-8 enabled by default
RUN apt-get -q update && apt-get install -qqy locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

ENV VAULT_VERSION=1.9.3

ENV ANDROID_SDK_TOOLS_VERSION 8092744
ENV ANDROID_PLATFORM_VERSION 29
ENV ANDROID_BUILD_TOOLS_VERSION 30.0.2

ENV ANDROID_HOME=/usr/local/android/sdk

ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin:${ANDROID_HOME}/platform-tools

ADD build.sh /opt/build.sh
ADD deploy.sh /opt/deploy.sh

RUN echo "Downloading sdk tools..." \
  && mkdir -p $ANDROID_HOME \
  && cd $ANDROID_HOME \
  && curl -C - --output android-sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip \
  && mkdir -p ${ANDROID_HOME}/cmdline-tools/ \
  && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/ \
  && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools  ${ANDROID_HOME}/cmdline-tools/tools \
  && rm android-sdk-tools.zip \
  && yes | sdkmanager --licenses \
  && touch $HOME/.android/repositories.cfg \
  && sdkmanager --update \
  && sdkmanager platform-tools \
  && sdkmanager "platforms;android-$ANDROID_PLATFORM_VERSION" "build-tools;$ANDROID_BUILD_TOOLS_VERSION"

RUN wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
    mv vault /usr/local/bin/vault && \
    chmod +x /usr/local/bin/vault && \
    rm vault_${VAULT_VERSION}_linux_amd64.zip

RUN apt-get -qq update \
  && apt-get -qqy install curl ca-certificates \
  && apt-get -qqy install php7.4-cli php7.4-curl php7.4-intl php7.4-xml php7.4-mbstring php7.4-gd php7.4-zip \
  && apt-get clean \
  && curl -L https://getcomposer.org/composer-1.phar -o /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer \
  && composer global require phpro/grumphp \
  && composer global require php-parallel-lint/php-parallel-lint \
  && composer global require jumbojett/openid-connect-php \
  && composer global require symfony/console \
  && composer global require guzzlehttp/guzzle \
  && rm -fR ~/.composer/cache \
  && echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc
