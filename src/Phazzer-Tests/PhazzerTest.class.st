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
	Phazzer new
		config: cnf;
		phazzClass: PzFake
]
