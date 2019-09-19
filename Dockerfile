FROM openjdk:8-jdk

RUN apt-get -q update && \
    apt-get -qqy install curl wget tar unzip lib32stdc++6 lib32z1 wget uuid-runtime

ENV ANDROID_HOME /usr/local/android/sdk

# Volumes for gradle and sdk
VOLUME $ANDROID_HOME
VOLUME /root/.gradle

# Install SDK and accept licenses
RUN cd $ANDROID_HOME && \
    wget --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip android-sdk.zip && \
    tools/bin/sdkmanager --list && \
    echo y | tools/bin/sdkmanager "platforms;android-28" && \
    echo y | tools/bin/sdkmanager "platform-tools" && \
    echo y | tools/bin/sdkmanager "build-tools;28.0.3" && \
    yes | tools/bin/sdkmanager --licenses

ADD build.sh /opt/build.sh
ADD deploy.sh /opt/deploy.sh
