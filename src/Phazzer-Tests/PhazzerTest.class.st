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
	^ 1 minute
]

{ #category : #running }
PhazzerTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	| finalP |
	target := PzFakeTest.
	tools := PzTools new.
	PzSqliteDb new purgeDb.
	finalP := tools defaultFinalPackage asPackageIfAbsent: [ nil ].
	finalP
		ifNotNil: [ finalP classes
				do: [ :x | 
					x superclass = target
						ifTrue: [ x removeFromSystem ] ] ].
	PzTools new clearTempClasses
]

{ #category : #running }
PhazzerTest >> tearDown [
	 | finalP |
	finalP := PzTools new defaultFinalPackage asPackage.
	finalP classes
		do: [ :x | 
			x superclass = target
				ifTrue: [ x removeFromSystem ] ] 
]

{ #category : #tests }
PhazzerTest >> testSandboxedCrash [
	| cnf res finalP pz |
	cnf := PzConfig new.
	cnf sandbox: true.
	cnf dbName: 'testDb.db'.
	cnf headless: false.
	cnf
		amps:
			{PzDspotLiteralInputAmplifier.
			PzDuplicateInputAmplifier}.
	"cnf sandboxSharedFile: 'faketest-sandbox-done-tests.txt'."
	(PzSqliteDb named: cnf dbName) 
		purgeDb;
		initDb.
	pz := Phazzer new.
	pz config: cnf.
	pz phazzMethod: target >> #testFakeCrash.
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
	(PzSqliteDb named: cnf dbName) purgeDb
]

{ #category : #tests }
PhazzerTest >> testSandboxedFreeze [
	| cnf res finalP pz |
	cnf := PzConfig new.
	cnf sandbox: true.
	cnf amps: {PzDspotLiteralInputAmplifier}.
	cnf freezeTimeOut: 5.
	cnf dbName: 'testDb.db'.
	cnf headless: false.
	(PzSqliteDb named: cnf dbName) 
		purgeDb;
		initDb.
	pz := Phazzer new.
	pz
		config: cnf;
		phazzMethod: target >> #testFakeFreeze.
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
	(PzSqliteDb named: cnf dbName) purgeDb
]
