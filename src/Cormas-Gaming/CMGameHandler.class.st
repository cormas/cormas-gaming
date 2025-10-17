Class {
	#name : 'CMGameHandler',
	#superclass : 'Object',
	#instVars : [
		'ws'
	],
	#category : 'Cormas-Gaming',
	#package : 'Cormas-Gaming'
}

{ #category : 'public' }
CMGameHandler >> handleRequest: request [
		^ws handleRequest: request
]

{ #category : 'as yet unclassified' }
CMGameHandler >> websocketDelegate: wsDelegate [
	ws := wsDelegate.
   ^self
]
