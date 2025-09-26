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

{ #category : 'as yet unclassified' }
CMGameServer >> filesHandler [
	| workingDirectory filesDelegate |
	workingDirectory := (FileSystem workingDirectory / 'cormas-gaming') asFileReference.
	filesDelegate := ZnStaticFileServerDelegate new directory: workingDirectory.
	^filesDelegate
	
]

{ #category : 'initialization' }
CMGameServer >> initialize [
	clients := OrderedCollection new.
	server := ZnWebSocket new.
	game := CMGame new.
	super initialize.
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
	server delegate: (CMGameHandler new websocketDelegate: (self wsHandler) filesDelegate: (self filesHandler));
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
			clients do: [ :c |
				| data |
				data := Dictionary new.
				data at: 'type' put: 'new'.
				data at: 'data' put: 'New client connected'.
				c sendMessage: (NeoJSONWriter toString: data)
			].
			clients add: client.
			Transcript cr; show: 'New client connected'; cr.
			[
            client runWith: [ :data |
                Transcript cr; show: 'Received: ', data asString; cr.
                clients do: [ :c | c sendMessage: data ].
            ].
        ] on: ConnectionClosed do: [ :ex |
            Transcript 
                cr; show: 'Client disconnected '; cr.
            clients remove: client ifAbsent: [].
				clients do: [ :c |
					| data |
					data := Dictionary new.
					data at: 'type' put: 'close'.
					data at: 'data' put: 'Client disconnected'.
					c sendMessage: (NeoJSONWriter toString: data)
				]
        ]
	]).
	^ wsDelegate
]
