#!/bin/bash

# 1 - task id
# 2 - app display name
# 3 - build type (debug / release)
# 4 - flavor name

PROJECT_ID=$1;
PROJECT_NAME=$2;
BUILD_TYPE=$3;
FLAVOR_NAME=$4;

if [ -z $PROJECT_ID ]
then
    echo "PROJECT_ID empty!"
    exit 1;
fi

if [ -z $PROJECT_NAME ]
then
  echo "PROJECT_NAME empty!"
  exit 1;
fi

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

#Upload APK

buildNumber=$(git rev-list --count ${COMMIT})
branchName=${BRANCH}
commitSHA=${COMMIT}
commitSubj=${COMMIT_MESSAGE}

if [ -z $FLAVOR_NAME ]
then
    buildDescription="Branch: ${branchName}\n Commit hash: ${commitSHA}\n Commit title: ${commitSubj}"
else
    buildDescription="Branch: ${branchName}\n Flavor: ${FLAVOR_NAME}\n Commit hash: ${commitSHA}\n Commit title: ${commitSubj}"
fi

echo "$buildDescription"

#flavor version name
if [ -z $FLAVOR_NAME ]
then
	gradleVersionName=$(./gradlew printVersionName)
else
	flavorName=`perl -e 'my ($fn) = @ARGV; $fn =~ s/-([a-z])/\u$1/g; print "$fn\n";' ${FLAVOR_NAME}`
	gradleVersionName=$(./gradlew printVersionName -PflavorNameProp=$flavorName)
fi

versionName=$(echo $gradleVersionName | sed -n 's/.*versionName "\(.*\)".*/\1/p')

versionCode=$(git rev-list --count ${COMMIT})

echo "versionName ${versionName}"
echo "versionCode ${versionCode}"

apkPath="app/build/outputs/apk"

GRADLE_MAJOR_VERSION=$(sed -n 's/.*gradle-\([0-9]*\)\..*/\1/p' gradle/wrapper/gradle-wrapper.properties)

if [ $GRADLE_MAJOR_VERSION -gt 2 ]
then
    if [ -z $FLAVOR_NAME ]
    then
        apkPath="app/build/outputs/apk/${BUILD_TYPE}/app-${BUILD_TYPE}.apk"
    else
        flavorDir=`perl -e 'my ($fn) = @ARGV; $fn =~ s/-([a-z])/\u$1/g; print "$fn\n";' ${FLAVOR_NAME}`
        apkPath="app/build/outputs/apk/${flavorDir}/$BUILD_TYPE/app-${FLAVOR_NAME}-$BUILD_TYPE.apk"
    fi
fi

uuidKey=$(uuidgen)
uuidName="${uuidKey}.apk"

echo "todo: Upload APK. Build number ${buildNumber}. APK name ${uuidName}"

exit $?
