Class {
	#name : #PzFakeTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #test }
PzFakeTest >> testFakeCrash [
	| x |
	x := PzFake new.
	x fakeCrash: false
]
