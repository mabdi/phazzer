"
A PzDspotLiteralInputAmplifierTest is a test class for testing the behavior of PzDspotLiteralInputAmplifier
"
Class {
	#name : #PzDspotLiteralInputAmplifierTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #tests }
PzDspotLiteralInputAmplifierTest >> testN1 [
	| src |
	src := 'testExternalStructWithArray
	| structWithArrays structureSize |
	structureSize := FFITestArrayStructure structureSize.
	structWithArrays := FFITestArrayStructure externalNew autoRelease.
	self assert: structWithArrays getHandle isExternalAddress.
	structWithArrays getHandle
		replaceFrom: 1
		to: structureSize
		with: (ByteArray new: structureSize).
	structWithArrays
		char5: (FFITypeArray fromHandle: ''ABCDE'' asByteArray).
	structWithArrays
		byte10: (FFITypeArray fromHandle: #[1 2 3 4 5 6 7 8 9 0]).
	self
		assert: structWithArrays char5 asArray
		equals: {$A . $B . $C . $D . $E}.
	self
		assert: structWithArrays byte10 asArray
		equals: #(1 2 3 4 5 6 7 8 9 0)'.
	(PzDspotLiteralInputAmplifier initializeWith: PzConfig new) inputAmplify: src
]

{ #category : #tests }
PzDspotLiteralInputAmplifierTest >> testN2 [
	| src |
	src := 'testExternalStructWithArray
	| structWithArrays structureSize |
	structureSize := FFITestArrayStructure structureSize.
	structWithArrays := FFITestArrayStructure externalNew autoRelease.
	self assert: structWithArrays getHandle isExternalAddress.
	structWithArrays getHandle
		replaceFrom: 1
		to: structureSize
		with: (ByteArray new: structureSize).
	structWithArrays
		char5: (FFITypeArray fromHandle: ''ABCDE'' asByteArray).
	structWithArrays
		byte10: (FFITypeArray fromHandle: #(1 2 3 4 5 6 -7 8.9 9 0)).
	self
		assert: structWithArrays char5 asArray
		equals: {$A . $B . $C . $D . $E}.
	self
		assert: structWithArrays byte10 asArray
		equals: #(1 2 3 4 5 6 7 8 9 0)'.
	(PzDspotLiteralInputAmplifier initializeWith: PzConfig new)
		inputAmplify: src
]

{ #category : #tests }
PzDspotLiteralInputAmplifierTest >> testN3 [
	| src |
	src := 'testUDPBroadcastError
	"Test that we get a specific error when failure is due to sending to a broadcast address without SO_BROADCAST set"

	"Use 255.255.255.255 for testing, which in RFC 919 is defined as ''denoting a broadcast on a local hardware network, which must not be forwarded. 
	This address may be used, for example, by hosts that do not know their network number and are asking some server for it.''"

	self
		should: [ Socket newUDP
				setOption: ''SO_BROADCAST'' value: false;
				sendUDPData: #[] toHost: #[255 255 255 255] port: 1950 ]
		raise: NoBroadcastAllowed.
	self
		shouldnt: [ Socket newUDP
				setOption: ''SO_BROADCAST'' value: true;
				sendUDPData: #[] toHost: #[255 255 255 255] port: 1 ]
		raise: NoBroadcastAllowed'.
	PzConfig new amps do: [ :amp | (amp initializeWith: PzConfig new)
		inputAmplify: src]
	
]
