# Diuit API Example (Messaging)

This is a basic example to demonstrate how to integrate with Diuit Messaging API framework. For more detail, please check our [API document](http://api2.diuit.com).

## Install

Install the framework via Cocoapods by executing command: `pod install`

## Getting started

* Get a seesion token for your device. If you are not sure about how to do this, please check [here](http://api2.diuit.com/#authenticating-user).
* Login your client with the session token:

```swift
import DUMessaging

DUMessaging.loginWithAuthToken(${SESSION_TOKEN}) { code, result in
	if code != 200 {
		//deal with error
		return
	}
	
	//do something, such as listing chatrooms
}
```
* In this example, there is an ActionSheet to let user choose one account to login. All you have to do is to replace ${SESSION_TOKEN_#} with your tokens.
![alt](http://i.imgur.com/CqLFfS3.png)
* After login, get a chatroom instance (DUChat), then you can send all kinds of message, kick some one out, etc.
* If you don't have any chatroom, create one by:
```swift
DUMessaging.createChatroomWith([${USER_SERIALS}]) { code, chat in
	// do something
}
```
* Or join other chatroom by : (you have to know the chatroom id first)
```swift
DUMessaging.joinChatroomWithId(${CHAT_ID}) {code, chat in
	// do something
}
```
* Sending messages are very very easy:
```swift
chat.sendText("Chimichanga!") { code, message in
	if code != 200 {
	    // handle error
	}
	
}
```
* If you don't want deal with callback, things could be even easier!
```swift
chat.sendText("Hi, this is a message without meta and callback")
```



