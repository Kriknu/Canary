# CIU196Project
Group project for the course CIU196 Mobile Interaction, Fall 2018

*** Pre-conditions ***
- macOS Mojave
- Xcode 10.0
- AppleID / Github account (have not tried it, but it should work)

*** SETUP PROJECT ***
1. Open projectfile in Xcode (MobileComputingProject -> MobileComputingProject.xcodeproj)   
2. Add developer account
  # Xcode -> Preferences -> account
3. Go to show the project navigator and the project projectfile
4. Change Team in signing to your profile
5. Change Bundle Identifyer (just add two random numbers after the input field)
6. Press try again

*** RUN PROJECT ***
1. Open MobileComputingProject.xcworkspace
  // This file enables us to use pods e.g. Firebase
*** KNOWN ISSUES ***
- Be part of a development team
- Update bundle identifier in order to install it on a non-developer license,
    it also has to be accepted on the phone

*** ISSUES RUNNING ON PHONE ***
If there is an issue stating "Certificate has either expired or has been revoked"follow these steps:

1. Clean project - Product --> Clean
2. XCode Menu --> Preferences
3. Select account (Left side of window)
4. Manage Certificates
5. Press plus sign in the bottom left corner of the window
6. Done, done, done
7. Run 

*** Database structure ***
I have added a file called database_structure.json. This file is only used as an reference guide for us 
when making queries to the database.
Tutorial for the database: https://www.raywenderlich.com/3-firebase-tutorial-getting-started

*** How to add text to an image ***
Go down to Swift4:
https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
