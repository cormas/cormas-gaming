Class {
	#name : 'CMGameServer',
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
CMGameServer class >> instance [
	instance ifNil: [ instance := CMGameServer new. ].
	^ instance
]

{ #category : 'accessing' }
CMGameServer >> clients [

	^ clients
]

{ #category : 'accessing' }
CMGameServer >> clients: anObject [

	clients := anObject
]

{ #category : 'initialization' }
CMGameServer >> initialize [
	clients := OrderedCollection new.
	server := ZnWebSocket new.
	game := CMGame new.
	super initialize.
]

{ #category : 'as yet unclassified' }
CMGameServer >> joinGame: aClient data: aData [

	| player cleanedPlayers json |
	player := Dictionary new.
	player at: 'role' put: (aData at: 'role').
	player at: 'socket' put: aClient.
	game addPlayer: (aData at: 'name') data: player.
	
	cleanedPlayers := Dictionary new.
	game players keysAndValuesDo: [ :key :value |
		cleanedPlayers at: key put: (value at: 'role')	
	].

	json := Dictionary new.
	json at: 'type' put: 'game:join'.
	json at: 'data' put: cleanedPlayers.
	
	clients do: [ :client |
		client sendMessage: (NeoJSONWriter toString: json)
	]
]

{ #category : 'as yet unclassified' }
CMGameServer >> reload: port [
	self stop.
	self start: port
]

{ #category : 'accessing' }
CMGameServer >> server [

	^ server
]

{ #category : 'accessing' }
CMGameServer >> start: port [
	game := CMGame new.
	clients := OrderedCollection new.
	server := ZnServer on: port.
	server delegate: (CMGameHandler new websocketDelegate: (self wsHandler));
		logToTranscript;
		start.
	
]

{ #category : 'accessing' }
CMGameServer >> stop [
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

{ #category : 'as yet unclassified' }
CMGameServer >> wsHandler [
	| wsDelegate |
	wsDelegate := (ZnWebSocketDelegate handler: [ :client |
			clients add: client.
			Transcript cr; show: 'New client connected'; cr.
			[
            client runWith: [ :data | self wsRouter: client data: data].
        ] on: ConnectionClosed do: [ :ex |
            Transcript 
                cr; show: 'Client disconnected '; cr.
				clients remove: client ifAbsent: [  ].
        ]
	]).
	^ wsDelegate
]

{ #category : 'as yet unclassified' }
CMGameServer >> wsRouter: aClient data: aData [
	| message type data |
	message := NeoJSONReader fromString: aData.
	type := message at: 'type'.
	data := message at: 'data'.
	Transcript show: data.
	type = 'game:join' ifTrue: [ self joinGame: aClient data: data ].
	type = 'game:state' ifTrue: [  ]
]
