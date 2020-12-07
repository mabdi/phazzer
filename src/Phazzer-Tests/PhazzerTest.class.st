Class {
	#name : #PhazzerTest,
	#superclass : #TestCase,
	#category : #'Phazzer-Tests'
}

{ #category : #accessing }
PhazzerTest class >> defaultTimeLimit [
	^ 1 minute
]

{ #category : #tests }
PhazzerTest >> testSandboxedCrash [
	| tools cnf t res finalP |
	t := PzFakeTest.
	tools := PzTools new.
	finalP := tools defaultFinalPackage asPackageIfAbsent: [ nil ].
	finalP
		ifNotNil: [ finalP classes
				do: [ :x | 
					x superclass = t
						ifTrue: [ x removeFromSystem ] ] ].
	PzTools new clearTempClasses.
	cnf := PzConfig new.
	cnf sandbox: true.
	"cnf sandboxSharedFile: 'faketest-sandbox-done-tests.txt'."
	Phazzer new
		config: cnf;
		phazzClass: t.
	self assertEmpty: tools defaultTempPackage asPackage classes.
	finalP := tools defaultFinalPackage
		asPackageIfAbsent: [ self deny: true ].
	res := finalP classes select: [ :x | x superclass = t ].
	self assert: res isNotEmpty
]
