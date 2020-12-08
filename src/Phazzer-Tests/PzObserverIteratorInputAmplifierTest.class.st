"
A PzObserverIteratorInputAmplifierTest is a test class for testing the behavior of PzObserverIteratorInputAmplifier
"
Class {
	#name : #PzObserverIteratorInputAmplifierTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #tests }
PzObserverIteratorInputAmplifierTest >> testNumber1 [
	| src res |
	src := (PzFakeTest >> #testFakeFreeze) sourceCode.
	res := (PzObserverIteratorInputAmplifier initializeWith: PzConfig new)
		inputAmplify: src.
	res inspect 
]
