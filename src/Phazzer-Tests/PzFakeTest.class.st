Class {
	#name : #PzFakeTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #accessing }
PzFakeTest >> defaultTimeLimit [
	^ 15 seconds
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
	x fakeFreeze: true.
	self assert: v equals: 5
]
