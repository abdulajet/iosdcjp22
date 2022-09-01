# iOSDC Japan 2022 Demo Project

This demo project allows the user to log into the application then make a call to a phone number. The demo consists of two parts, the backend server and the iOS application.


## Server

The backend server allows the iOS application to create a Conversation API User using the `/createuser` endpoint. Then once that user is create, the backend can vendor a JWT for that user using the `/jwt` endpoint.


## iOS Application

The iOS application using the Vonage Client SDK for iOS to log in with a JWT, then call a phone number. 