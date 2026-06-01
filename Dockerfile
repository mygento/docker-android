FROM eclipse-temurin:17-jdk-noble

RUN apt-get -qq update && \
    apt-get -qqy install curl wget tar unzip lib32stdc++6 lib32z1 uuid-runtime

# make the "en_US.UTF-8" locale so gradle will be utf-8 enabled by default
RUN apt-get -q update && apt-get install -qqy locales \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.source https://github.com/mygento/docker-android 

ENV LANG=en_US.utf8
ENV VAULT_VERSION=1.21.4
ENV ANDROID_SDK_TOOLS_VERSION=11076708
ENV ANDROID_PLATFORM_VERSION=34
ENV ANDROID_BUILD_TOOLS_VERSION=34.0.0
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
  && apt-get -qqy install php8.3-cli php8.3-curl php8.3-intl php8.3-xml php8.3-mbstring php8.3-gd php8.3-zip \
  && apt-get clean \
  && curl -L https://getcomposer.org/download/latest-2.2.x/composer.phar -o /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer \
  && composer global config --no-plugins allow-plugins.phpro/grumphp true \
  && composer global require phpro/grumphp \
  && composer global require php-parallel-lint/php-parallel-lint \
  && composer global require jumbojett/openid-connect-php \
  && composer global require symfony/console \
  && composer global require guzzlehttp/guzzle \
  && rm -fR ~/.composer/cache \
  && echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc
