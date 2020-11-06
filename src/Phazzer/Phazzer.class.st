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
Phazzer >> fuzzMethod: aTestMethod [
	| ts tc |
	ts := self inputAmplify: aTestMethod.
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
Phazzer >> run: testClasses [
	| tr |
	tr := testClasses collect: [ :cls | cls buildSuite run defects ].
	"move to final package"
	self halt.
]

{ #category : #accessing }
Phazzer >> tools [
	^ PzTools new
]
