"
A PzDuplicateInputAmplifierTest is a test class for testing the behavior of PzDuplicateInputAmplifier
"
Class {
	#name : #PzDuplicateInputAmplifierTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #tests }
PzDuplicateInputAmplifierTest >> testN3 [
	| src |
	src := 'testNotLitteral
	| expr source |
	expr := RBLiteralValueNode value: Transcript.
	configurationSelector := #basicConfiguration.
	source := self formatter format: expr.
	self assert: source equals: ''''''<an unprintable nonliteral value>'''''''.
	(PzDuplicateInputAmplifier initializeWith: PzConfig new)
		inputAmplify: src
]
