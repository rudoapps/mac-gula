#  Authentication

This module provides the screens and functionality for login authentication, registration and password recovery.

## Installation Notes

### Deeplinks

Configure the deep links in `PROJECT > TARGETS > Name_project > Info > URL Types`. The identifier must be that of the project, and you must contact back so that they can enter the same one in their configuration. In URL Schemes, we must enter the name of the project.

If you have social login, you must add the corresponding Google URL Scheme.

We will also need to set the name of the scheme in `Shared > Configuration > Config.swift`.


If in your application you need the social login you have 2 ways:

 1. Set the parameter `isSocialLoginActived` to true in the build so that it will appear on the screen.

 2. Remove the if `isSocialLoginActived` check from the view and leave it fixed.
 
If you don't, you have to remove GoogleSignIn package from packages, and AuthenticationAssets in Resources folder.


If you don't need deeplinks:
- in ContentView you will have to delete deeplinks cases. In .home cases, you must enter the home page.
- you will have to delete too deeplink files in Shared/Resources/DeeplinkManager, and in main screen remove references to DeeplinkManager
