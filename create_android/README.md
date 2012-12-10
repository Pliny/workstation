Android Project Creator
=======================
** Development is in progress.  This is not yet useable **

This script creates a basic Android project with Maven and Robolectric support.
It also kindly sets up a git repository and initial checkin.

Installation
-------------
Just clone this. When you're ready to create a new project, run ```create.sh``` your
Android workspace directory.

Configuration
-------------
```Usage: create.sh --name <App Name> --group <Your Company> -api <Android API> or defaults to ./create.sh --name my-android-application --group your.company --api 10```

All command line options can also be set via a configuration file called `$HOME/.createandroid`. Below shows the equivalent Bash variable names
```bash
    APPNAME="my-android-application"
    GROUP_ID='your.company'
    ANDROID_API=10
```

Dependencies
-------------
* [GIT](http://git-scm.com/)
* [Maven](http://maven.apache.org/)
* [Android SDK](http://developer.android.com/sdk/index.html) ... and associated dependencies

Bugs
-------------
Please let me know or issue a pull request!
