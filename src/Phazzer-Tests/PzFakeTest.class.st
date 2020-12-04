Class {
	#name : #PzFakeTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #test }
PzFakeTest >> testFakeCrash [
	| x v |
	x := PzFake new.
	v := 2 + 3.
	x fakeCrash: false.
	self assert: v equals: 5
]
