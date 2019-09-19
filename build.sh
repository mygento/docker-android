#!/bin/bash

# 1 - build type (debug / release)
# 2 - flavor name
BUILD_TYPE=$1;
FLAVOR_NAME=$2;

if [ -z $BUILD_TYPE ]
then
    echo "BUILD_TYPE empty!"
    exit 1;
else
    if [[ "$BUILD_TYPE" != "debug" && "$BUILD_TYPE" != "release" ]]
    then
        echo "Only debug / release build type supported!"
        exit 1;
    fi
fi

if [ -z $ANDROID_HOME ]
then
    echo "ANDROID_HOME empty!"
    exit 2;
fi

echo "Android Home is $ANDROID_HOME"

buildNumber=$(git rev-list --count ${COMMIT})

echo "buildNumber ${buildNumber}"

flavorName=""

GRADLE_MAJOR_VERSION=$(sed -n 's/.*gradle-\([0-9]*\)\..*/\1/p' gradle/wrapper/gradle-wrapper.properties)

if [ $GRADLE_MAJOR_VERSION -gt 2 ]
then
    flavorName=`perl -e 'my ($fn) = @ARGV; $fn =~ s/^([a-z])/\u$1/g; print "$fn\n";' ${FLAVOR_NAME}`
    flavorName=`perl -e 'my ($fn) = @ARGV; $fn =~ s/-([a-z])/\u$1/g; print "$fn\n";' ${flavorName}`
fi

echo "Build $BUILD_TYPE APK"

if [[ "$BUILD_TYPE" == "release" ]]
then
    BUILD_NUMBER=${buildNumber} ./gradlew assemble${flavorName}Release
else
    BUILD_NUMBER=${buildNumber} ./gradlew assemble${flavorName}Debug
fi

exit $?
