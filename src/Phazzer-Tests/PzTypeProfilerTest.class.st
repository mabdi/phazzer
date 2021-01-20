"
A PzTypeProfilerTest is a test class for testing the behavior of PzTypeProfiler
"
Class {
	#name : #PzTypeProfilerTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #tests }
PzTypeProfilerTest >> testMethod1 [
	| target profile |
	target := PzFakeTest >> #testFakeCrash.
	profile := PzTypeProfiler new runOn: target.
	self assert: (profile variablesTypes at: #'testFakeCrash:v' ) equals: SmallInteger.
		self assert: (profile variablesTypes at: #'testFakeCrash:x' ) equals: PzFake.
			self assert: (profile variablesTypes at: PzTypeProfiler instanceVariablesKey ) equals: OrderedCollection new.
]
