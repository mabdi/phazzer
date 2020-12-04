Class {
	#name : #PhazzerTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #tests }
PhazzerTest >> testSandboxedCrash [
	| cnf |
	PzTools new clearTempClasses.
	cnf := PzConfig new.
	cnf sandbox: true.
	"cnf sandboxSharedFile: 'faketest-sandbox-done-tests.txt'."
	Phazzer new
		config: cnf;
		phazzClass: PzFakeTest
]
