Class {
	#name : 'CMGameSocket',
	#superclass : 'Object',
	#instVars : [
		'game',
		'server',
		'clients'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Cormas-Gaming',
	#package : 'Cormas-Gaming'
}

{ #category : 'accessing' }
CMGameSocket class >> instance [
	instance ifNil: [ instance := CMGameSocket new. ].
	^ instance
]

{ #category : 'accessing' }
CMGameSocket >> start [
	clients := OrderedCollection new.
	server := ZnWebSocket startServerOn: 9090 do: [ :client |
			Transcript cr; show: 'New client connected'; cr.
			clients add: client.
			client runWith: [ :message |
					Transcript cr; show: 'Received: ', message; cr.
					clients do: [ :c | c sendMessage: message ]
			]
	]
]

{ #category : 'accessing' }
CMGameSocket >> stop [
	clients ifNotNil: [ clients do: [ :c | c ifNotNil: [ c close ] ]].
	clients := nil.
	server ifNotNil: [ server stop ].
	server := nil
]
