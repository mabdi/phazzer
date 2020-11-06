Class {
	#name : #Phazzer,
	#superclass : #Object,
	#instVars : [
		'config'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
Phazzer class >> defaultConfig [
	^ PzConfig new
]

{ #category : #'as yet unclassified' }
Phazzer class >> onMethod: aTestMethod [
	self flag: #todo.	"check isTestMethod"
	self new
		config: self defaultConfig;
		fuzzMethod: aTestMethod
]

{ #category : #'as yet unclassified' }
Phazzer class >> phazzPackage: packageName [
	(RPackage organizer packageNamed: packageName) phazz
]

{ #category : #accessing }
Phazzer >> config: aConfig [
	config:= aConfig
]

{ #category : #'as yet unclassified' }
Phazzer >> eventForTestAnnouncement [
	| str |
	^ [ :x | 
	str := ':'
		join:
			{Time nowUTC print24.
			x test class name.
			x test selector}.
	Stdio stdout
		nextPutAll: str;
		lf;
		flush
		 ]
]

{ #category : #'as yet unclassified' }
Phazzer >> fuzzMethod: aTestMethod [
	| ts tc t |
	.
	t := self removeAssertions: aTestMethod.
	ts := self inputAmplify: t.
	tc := self install: ts base: aTestMethod methodClass.
	self run: tc.
	PzTools new clearTempClasses
]

{ #category : #'as yet unclassified' }
Phazzer >> inputAmplify: aTestMethod [
	self flag: #todo. "annotate generated test methods to trace how it is build"
	^ config amps
		flatCollect: [ :amp | (amp initializeWith: config) inputAmplify: aTestMethod ]
]

{ #category : #'as yet unclassified' }
Phazzer >> install: testMethods base: aTestClass [
	"installs test methods on fake test classes.
	 returns the list of fake test classes"

	| tc |
	self flag: #todo.	"paging"
	tc := self tools buildTestClassWith: testMethods using: aTestClass.
	^ {tc}
]

{ #category : #'as yet unclassified' }
Phazzer >> removeAssertions: aTestMethod [
	^ (PzAssertTransform transformAllAsserts: aTestMethod ast) formattedCode 
]

{ #category : #'as yet unclassified' }
Phazzer >> run: testClasses [
	| tr ts |
	tr := testClasses
		collect: [ :cls | 
			ts := cls buildSuite.
			ts when: TestAnnouncement do: self eventForTestAnnouncement.
			ts := ts run.
			cls -> ts defects ].
	(tr reject: [ :cls | cls value isEmpty ])
		do: [ :cls | 
			self tools
				buildFinalTestClassWith:
					(cls value
						collect: [ :tc | (tc class lookupSelector: tc selector) sourceCode ])
				using: cls key superclass ]
]

{ #category : #accessing }
Phazzer >> tools [
	^ PzTools new
]
