FROM openjdk:8-jdk

RUN apt-get -q update && \
    apt-get -qqy install curl wget tar unzip lib32stdc++6 lib32z1 uuid-runtime

# make the "en_US.UTF-8" locale so gradle will be utf-8 enabled by default
RUN apt-get -q update && apt-get install -qqy locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

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
