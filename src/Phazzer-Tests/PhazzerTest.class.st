Class {
	#name : #PhazzerTest,
	#superclass : #TestCase,
	#instVars : [
		'target',
		'tools'
	],
	#category : #'Phazzer-Tests'
}

{ #category : #accessing }
PhazzerTest class >> defaultTimeLimit [
	^ 10 minute
]

{ #category : #running }
PhazzerTest >> myTearDown [
	" Because I don't like this code to be run in the sandbox"
	| finalP |
	finalP := PzTools new defaultFinalPackage asPackage.
	finalP classes
		do: [ :x | 
			x superclass = target
				ifTrue: [ x removeFromSystem ] ].
	(Phazzer dbClass named: self class name) purgeDb
]

{ #category : #running }
PhazzerTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	| finalP |
	target := PzFakeTest.
	tools := PzTools new.
	(Phazzer dbClass  named: self class name) purgeDb.
	finalP := tools defaultFinalPackage asPackageIfAbsent: [ nil ].
	finalP
		ifNotNil: [ finalP classes
				do: [ :x | 
					x superclass = target
						ifTrue: [ x removeFromSystem ] ] ].
	PzTools new clearTempClasses
]

{ #category : #tests }
PhazzerTest >> testSandboxedCrash [
	| cnf res finalP pz |
	cnf := PzConfig new.
	cnf sandbox: true.
	cnf dbName: self class name.
	cnf headless: false.
	cnf freezeTimeOut: 180.
	cnf iterations: 1.
	cnf
		amps:
			{PzDspotLiteralInputAmplifier.
			PzDuplicateInputAmplifier}.
	"cnf sandboxSharedFile: 'faketest-sandbox-done-tests.txt'."
	pz := Phazzer new.
	pz config: cnf.
	[ pz phazzMethod: target >> #testFakeCrash ]
		on: PzContinueInSandbox
		do: [ ^ self ].
	self assertEmpty: tools defaultTempPackage asPackage classes.
	finalP := tools defaultFinalPackage
		asPackageIfAbsent: [ self deny: true ].
	res := finalP classes select: [ :x | x superclass = target ].
	self assert: res isNotEmpty.
	self
		assert:
			(((res asOrderedCollection at: 1) methods at: 1) sourceCode
				includesSubstring: 'true').
	self deny: pz db anyUnFinishedLeft.
	self myTearDown
]

{ #category : #tests }
PhazzerTest >> testSandboxedFreeze [
	| cnf res finalP pz |
	cnf := PzConfig new.
	cnf sandbox: true.
	cnf
		amps:
			{PzDspotLiteralInputAmplifier.
			PzDuplicateInputAmplifier}.
	cnf freezeTimeOut: 5.
	cnf dbName: self class name.
	cnf headless: false.
	pz := Phazzer new.
	pz config: cnf.
	[ pz phazzMethod: target >> #testFakeFreeze ]
		on: PzContinueInSandbox
		do: [ ^ self ].
	self assertEmpty: tools defaultTempPackage asPackage classes.
	finalP := tools defaultFinalPackage
		asPackageIfAbsent: [ self deny: true ].
	res := finalP classes select: [ :x | x superclass = target ].
	self assert: res isNotEmpty.
	self
		assert:
			(((res asOrderedCollection at: 1) methods at: 1) sourceCode
				includesSubstring: 'true').
	self deny: pz db anyUnFinishedLeft.
	self myTearDown 
]
