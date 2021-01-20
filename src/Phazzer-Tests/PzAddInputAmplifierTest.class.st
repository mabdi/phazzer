"
A PzAddInputAmplifierTest is a test class for testing the behavior of PzAddInputAmplifier
"
Class {
	#name : #PzAddInputAmplifierTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #tests }
PzAddInputAmplifierTest >> testN1 [
	| src m profile res |
	m := PzFakeTest >> #testFakeCrash.
	src := m sourceCode.
	profile := PzTypeProfiler new runOn: m.
	res := (PzAddInputAmplifier initializeWith: PzConfig new)
		profile: profile;
		inputAmplify: src.
	res inspect
]
