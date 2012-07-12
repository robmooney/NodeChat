NodeChat
========

An iOS chat client that connects to a simple Node.js chat server. 

The code was adapted from [Pedro Teixeira's chat server](http://nodetuts.com/tutorials/5-a-basic-tcp-chat-server.html#video) at [Node Tuts](http://nodetuts.com/)

Installation
------------

You can install node from the [nodejs website](http://nodejs.org/#download) or use [homebrew](http://mxcl.github.com/homebrew/):

	brew install node

To start the server:

	node chat.js
	
The iOS app is set up to look for the chat server at localhost. To run on a device you will need to change this to the actual address of your server. Edit #define SERVER_HOST in RMChatClient.m to do this.