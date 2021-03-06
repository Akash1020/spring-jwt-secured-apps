#!/usr/bin/env bash

currentVersion=`./mvnw -q --non-recursive exec:exec -Dexec.executable=echo -Dexec.args='${project.version}'`

if [[ "$currentVersion" == *"SNAPSHOT"* ]] ; then
  ./mvnw build-helper:parse-version -DgenerateBackupPoms=false versions:set \
    -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}
  developmentVersion=`./mvnw -q --non-recursive exec:exec -Dexec.executable=echo -Dexec.args='${project.version}'`
  ./mvnw build-helper:parse-version -DgenerateBackupPoms=false versions:set -DnewVersion="$currentVersion"

  ./mvnw clean release:prepare release:perform \
      -DreleaseVersion="$currentVersion" -DdevelopmentVersion="$developmentVersion" \
      -B -Dgoals="package" -DgenerateReleasePoms=false -DgenerateBackupPoms=false
else
  git tag "v$currentVersion"

  ./mvnw build-helper:parse-version -DgenerateBackupPoms=false versions:set -DgenerateBackupPoms=false -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}
  nextVersion=`./mvnw -q --non-recursive exec:exec -Dexec.executable=echo -Dexec.args='${project.version}'`

  git add . ; git commit -am "v$currentVersion release." ; git push --tags
fi
