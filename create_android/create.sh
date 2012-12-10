#!/bin/sh
# TODO: put robolectric dependency in correct place in pom.xml file

DEBUG=true

###### Configurable variables
APPNAME="my-android-application"
GROUP_ID='your.company'
ANDROID_API=10

###### Local variables
ARCHETYPE_VERSION='1.0.8'
SUBMODULES_DIR='submodules'
ROBOLECTRIC_VERSION='1.2-SNAPSHOT'
JUNIT_VERSION='4.8.2'
ROBOLECTRIC_GITHUB='git://github.com/pivotal/robolectric.git'
DEPLOYER='maven-android-sdk-deployer'
DEPLOYER_GITHUB="git://github.com/mosabua/$DEPLOYER.git"

###### Config file
source $HOME/.createandroid

###### Parse CLI
while [ $# -gt 0 ]; do
  case $1 in
    -n | --name)
      shift
      APPNAME=$1
      shift
      ;;
    -g | --group)
      shift
      GROUP_ID=$1
      shift
      ;;
    -a | --api)
      shift
      ANDROID_API=$1
      shift
      ;;
    *)
      echo 1>&2 Usage: $0 "--name <App Name> --group <Your Company> -api <Android API> or defaults to $0 --name $APPNAME --group $GROUP_ID --api $ANDROID_API"
      exit 127
  esac
done

###### Core functions

install_android_dependencies() {
  git clone $DEPLOYER_GITHUB
  pushd .
  cd $DEPLOYER
  mvn clean install || (echo "ERROR: Could not install Android dependencies"; exit 126;)
  popd
}

create_initial_project() {
  local NAME=$1

  # Make sure maven-android-sdk-deployer is installed first
  if [ ! -e "$HOME/.m2/repository/com/simpligility/android/sdk-deployer/" ]; then
    install_android_dependencies
  fi

  mvn archetype:generate \
    -DarchetypeArtifactId=android-quickstart \
    -DarchetypeGroupId=de.akquinet.android.archetypes \
    -DarchetypeVersion=$ARCHETYPE_VERSION \
    -DgroupId=$GROUP_ID \
    -DartifactId=$NAME \
    -Dplatform=$ANDROID_API || \
    (echo "ERROR: Could not create basic archtype"; exit 124;)

  if [ $ANDROID_HOME ]; then
    android update project -p $NAME
  else
    echo "ERROR: You need to have \$ANDROID_HOME point to the Android SDK path"
    exit 127;
  fi

  exit 0;
}

add_basic_test() {
  local TEST_SRC_PATH="src/test/java/${SRC_PATH}/`echo $GROUP_ID | sed 's/\./\//g'`"
  mkdir -p $TEST_SRC_PATH

  cat > $TEST_SRC_PATH/HelloAndroidActivityTest.java << EOF
import $GROUP_ID.HelloAndroidActivity;
import $GROUP_ID.R;
import com.xtremelabs.robolectric.RobolectricTestRunner;
import org.junit.Test;
import org.junit.runner.RunWith;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.junit.Assert.assertThat;

@RunWith(RobolectricTestRunner.class)
  public class HelloAndroidActivityTest {

    @Test
      public void shouldHaveHappySmiles() throws Exception {
        String appName = new HelloAndroidActivity().getResources().getString(R.string.app_name);
        assertThat(appName, equalTo("$APPNAME"));
      }
  }
EOF
}

rdom () { local IFS=\> ; read -d \< E C ;}

setup_test_framework() {

  local next_dep=false;

  cp pom.xml pom.xml.in
  echo "<HACKTACULAR" >> pom.xml.in

  while rdom; do

    if [[ $E = artifactId && $C = android ]]; then
      next_dep=true;
    fi

    [ -n "$E" ] && echo "<$E>\c"
    [ -n "$C" ] && echo "$C\c"

    if [[ $next_dep = true && $E = "/dependency" ]]; then
      cat <<- EOF
      <dependency>
        <groupId>com.pivotallabs</groupId>
        <artifactId>robolectric</artifactId>
        <version>$ROBOLECTRIC_VERSION</version>
        <scope>test</scope>
      </dependency>
      <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>$JUNIT_VERSION</version>
        <scope>test</scope>
      </dependency>
EOF

      unset next_dep
    fi

  done < pom.xml.in > pom.xml

  rm pom.xml.in

  add_basic_test
}

setup_version_control() {
  git init

  cat > .gitignore <<- EOF
  target/
  tmp/
  gen/
  .idea/
  $APPNAME.iml
EOF
}

install_test_framework() {

  if [ ! -e ".git" ]; then
    setup_version_control
  fi

  git submodule add $ROBOLECTRIC_GITHUB $SUBMODULES_DIR/robolectric

  pushd .
  cd $SUBMODULES_DIR/robolectric

  mvn clean install || (echo "ERROR: Could not install Robolectric"; exit 125;)

  popd
  exit 0;
}

commit() {
  git add .
  git commit -am "Initial Checkin"
}

run_test() {
  (mvn clean test) || (echo "ERROR: Final Test Failed"; exit 123)
  exit 0;
}

###### Main Program

(create_initial_project $APPNAME) || exit $?

pushd .
cd $APPNAME

setup_test_framework

setup_version_control

(install_test_framework) || exit $?

(run_test) || exit $?

commit

popd
