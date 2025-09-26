Class {
	#name : 'CMGameHandler',
	#superclass : 'Object',
	#instVars : [
		'ws',
		'files'
	],
	#category : 'Cormas-Gaming',
	#package : 'Cormas-Gaming'
}

{ #category : 'public' }
CMGameHandler >> handleRequest: request [
	| path |
   path := request uri path.
	(path beginsWith: 'ws') ifTrue: [
		^ws handleRequest: request
	].
	^files handleRequest: request
]

{ #category : 'as yet unclassified' }
CMGameHandler >> websocketDelegate: wsDelegate filesDelegate: filesDelegate [
	ws := wsDelegate.
   files := filesDelegate.
   ^self
]
