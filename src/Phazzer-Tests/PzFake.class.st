Class {
	#name : #PzFake,
	#superclass : #Object,
	#category : #'Phazzer-Tests'
}

{ #category : #'as yet unclassified' }
PzFake >> fakeCrash: aBoolean [
	| x |
	
	aBoolean
		ifTrue: [ Smalltalk snapshot: false andQuit: true ].
	^ 1
]

{ #category : #'as yet unclassified' }
PzFake >> fakeFreeze: aBoolean [
	| x |
	aBoolean
		ifTrue: [ 10 seconds asDelay wait ].
	^ 1
]
