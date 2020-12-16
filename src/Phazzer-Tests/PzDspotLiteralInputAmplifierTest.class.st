"
A PzDspotLiteralInputAmplifierTest is a test class for testing the behavior of PzDspotLiteralInputAmplifier
"
Class {
	#name : #PzDspotLiteralInputAmplifierTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #testing }
PzDspotLiteralInputAmplifierTest >> expectedFailures [
	^ super expectedFailures , #(testN4 testN5)
]

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

{ #category : #tests }
PzDspotLiteralInputAmplifierTest >> testN4 [
	| src |
	src := 'testTallySends
	| tally thisMethod allProcesses processUsedByTally tallyForPrintString tallyForPrintStringBase |
	allProcesses := Process allInstances.
	tally := MessageTally
		tallySendsTo: nil
		inBlock: [ 3.14159s printString ]
		showTree: true
		closeAfter: false
		openResultWindow: false.

	"tally is for this test method"
	thisMethod := self class >> #testTallySends.
	self assert: tally hash equals: thisMethod hash.
	self assert: tally method identicalTo: thisMethod.
	self assert: tally theClass identicalTo: self class.
	processUsedByTally := tally process.
	self deny: (allProcesses includes: processUsedByTally).

	"Below is specialized for the execution '' 3.14159 printString ''. Any method change in the execution flow of printString will turn this test to yellow"
	self assert: tally tally >= 50.
	"The tally is not close, therefore the tree may be crawled over"
	self assert: tally receivers isArray.
	self assert: tally receivers size equals: 2.

	"--------"
	tallyForPrintString := tally receivers second.
	"Since 3.14159s is a ScaledDecimal"
	self
		assert: (tallyForPrintString theClass includesBehavior: ScaledDecimal).
	"the executed method is Number>>printString"
	self
		assert: tallyForPrintString method
		identicalTo: Number >> #printString.
	self assert: tallyForPrintString tally >= 50.

	"--------"
	tallyForPrintStringBase := tallyForPrintString receivers first.
	"The receiver is still a ScaledDecimal"
	self
		assert: (tallyForPrintString theClass includesBehavior: ScaledDecimal).
	"the executed method is Number>>printStringBase: this time"
	self
		assert: tallyForPrintStringBase method
		identicalTo: Number >> #printStringBase:.
	self assert: tallyForPrintStringBase tally >= 50.

	"The method printStringBase: calls two methods:
	   SequenceableCollection class >> streamContents: and ScaledDecimal >> printOn:base:"
	self assert: tallyForPrintStringBase receivers size equals: 1.
	self assert: tallyForPrintStringBase receivers first tally >= 50.

	"We close to explicitly release reference of the process, the class and methods"
	tally close'.
	PzConfig new amps
		do: [ :amp | (amp initializeWith: PzConfig new) inputAmplify: src ]
]

{ #category : #tests }
PzDspotLiteralInputAmplifierTest >> testN5 [
	| src |
	src := 'testIntervalStoreOn
	"this is a test for http://bugs.squeak.org/view.php?id=4378"

	| interval1 interval2 |
	interval1 := 0 to: 1 by: 0.5s1 squared.
	interval2 := self class compiler evaluate: interval1 storeString.
	self assert: interval1 size equals: interval2 size'.
	PzConfig new amps
		do: [ :amp | (amp initializeWith: PzConfig new) inputAmplify: src ]
]

{ #category : #tests }
PzDspotLiteralInputAmplifierTest >> testN6 [
	| src |
	src := 'testExactNthRoot
	| eight thousandth tenth two |
	eight := 8.0s1.
	two := eight raisedTo: 1 / 3.
	self assert: two equals: 2.
	self
		assert: (two class = eight class and: [ two scale = eight scale ]).
	thousandth := 0.001s3.
	tenth := thousandth raisedTo: 1 / 3.
	self assert: tenth * 10 equals: 1.
	self
		assert:
			(tenth class = thousandth class
				and: [ tenth scale = thousandth scale ])'.
	PzConfig new amps
		do: [ :amp | (amp initializeWith: PzConfig new) inputAmplify: src ]
]

{ #category : #tests }
PzDspotLiteralInputAmplifierTest >> testN7 [
	| src |
	src := 'testBinaryLiteralString
	
	self
		assert:
			2r1.1111111111111111111111111111111111111111111111111111e1023
				binaryLiteralString
		equals: ''2r1.1111111111111111111111111111111111111111111111111111e1023''.
	'.
	PzConfig new amps
		do: [ :amp | (amp initializeWith: PzConfig new) inputAmplify: src ]
]
