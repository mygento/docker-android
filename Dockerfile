FROM openjdk:8-jdk

RUN apt-get -qq update && \
    apt-get -qqy install curl wget tar unzip lib32stdc++6 lib32z1 uuid-runtime

# make the "en_US.UTF-8" locale so gradle will be utf-8 enabled by default
RUN apt-get -q update && apt-get install -qqy locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

ENV VAULT_VERSION=1.7.1

ENV ANDROID_HOME=/usr/local/android/sdk ANDROID_VERSION=28 ANDROID_BUILD_TOOLS_VERSION=28.0.3 SDK_URL=https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip

ADD build.sh /opt/build.sh
ADD deploy.sh /opt/deploy.sh

RUN echo "Downloading sdk tools..." && \
    mkdir -p $ANDROID_HOME && \
    cd $ANDROID_HOME && \
    wget --quiet -O sdk-tools.zip $SDK_URL

RUN echo "Extracting sdk tools..." && \
    unzip -q $ANDROID_HOME/sdk-tools.zip -d $ANDROID_HOME && \
    rm $ANDROID_HOME/sdk-tools.zip && \
    mkdir /root/.android/ && \
    touch /root/.android/repositories.cfg

RUN echo "Applying licenses" && \
    mkdir -p $ANDROID_HOME/licenses || true && \
    cd $ANDROID_HOME && \
    echo yes | tools/bin/sdkmanager "platforms;android-${ANDROID_VERSION}" && \
    echo yes | tools/bin/sdkmanager "platform-tools" && \
    echo yes | tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    yes | tools/bin/sdkmanager --licenses

RUN wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
    mv vault /usr/local/bin/vault && \
    chmod +x /usr/local/bin/vault && \
    rm vault_${VAULT_VERSION}_linux_amd64.zip

RUN apt-get -qq update \
  && apt-get -qqy install curl ca-certificates \
  && apt-get -qqy install php7.3-cli php7.3-curl php7.3-intl php7.3-xml php7.3-mbstring php7.3-gd php7.3-zip \
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
