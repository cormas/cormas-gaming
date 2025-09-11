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
			clients add: client.
			client runWith: [ :message |
					clients do: [ :c | c sendMessage: message ]
			]
	]
]

{ #category : 'accessing' }
CMGameSocket >> stop [
	clients := nil
	server ifNotNil: [ server stop ]
]
