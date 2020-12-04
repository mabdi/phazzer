Class {
	#name : #PzFake,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #'as yet unclassified' }
PzFake >> fakeCrash: aBoolean [
	| x |
	
	aBoolean
		ifTrue: [ Smalltalk snapshot: false andQuit: true ].
	^ 1
]
