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
CMGameSocket >> clients [

	^ clients
]

{ #category : 'accessing' }
CMGameSocket >> clients: anObject [

	clients := anObject
]

{ #category : 'initialization' }
CMGameSocket >> initialize [
	clients := OrderedCollection new.
	server := ZnWebSocket new.
	game := CMGame new.
	super initialize.
]

{ #category : 'accessing' }
CMGameSocket >> server [

	^ server
]

{ #category : 'accessing' }
CMGameSocket >> start: port [
	game := CMGame new.
	clients := OrderedCollection new.
	server := ZnServer on: port.
	server delegate: (ZnWebSocketDelegate map: '/ws' to: [ :client |
			clients add: client.
			Transcript cr; show: 'New client connected'; cr.
			[
            client runWith: [ :message |
                Transcript cr; show: 'Received: ', message; cr.
                clients do: [ :c | c sendMessage: message ].
            ].
        ] on: ConnectionClosed do: [ :ex |
            Transcript 
                cr; show: 'Client disconnected '; cr.
            clients remove: client ifAbsent: [].
        ]
	]).
	server start.
	
]

{ #category : 'accessing' }
CMGameSocket >> stop [
	game := nil.
	clients ifNotNil: [
        clients do: [ :client |
            [ client close ] on: Error do: [ :ex | "Ignorer les erreurs de fermeture" ].
        ].
        clients := OrderedCollection new.
    ].
    server ifNotNil: [
        server stop.
        server := nil.
    ].
]
