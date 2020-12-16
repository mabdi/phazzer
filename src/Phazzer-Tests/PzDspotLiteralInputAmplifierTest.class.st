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
