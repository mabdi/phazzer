Class {
	#name : #PhazzerTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #tests }
PhazzerTest >> testSandboxedCrash [
	| tools cnf t res |
	t := PzFakeTest.
	tools := PzTools new.
	tools defaultFinalPackage asPackage classes
		do: [ :x | 
			x superclass = t
				ifTrue: [ x removeFromSystem ] ].

	PzTools new clearTempClasses.
	cnf := PzConfig new.
	cnf sandbox: true.
	"cnf sandboxSharedFile: 'faketest-sandbox-done-tests.txt'."
	Phazzer new
		config: cnf;
		phazzClass: t.
	self assertEmpty: tools defaultTempPackage asPackage classes.
	res := tools defaultFinalPackage asPackage classes
		select: [ :x | x superclass = t ].
	self assert: res isNotEmpty.
	
]
