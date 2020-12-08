Class {
	#name : #PzFakeTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #accessing }
PzFakeTest class >> defaultTimeLimit [
	^ 10 seconds 
]

{ #category : #test }
PzFakeTest >> testFakeCrash [
	| x v |
	x := PzFake new.
	v := 2 + 3.
	x fakeCrash: false.
	self assert: v equals: 5
]

{ #category : #test }
PzFakeTest >> testFakeFreeze [
	| x v |
	x := PzFake new.
	v := 2 + 3.
	x fakeFreeze: false.
	self assert: v equals: 5
]
