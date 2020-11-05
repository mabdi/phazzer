Class {
	#name : #Phazzer,
	#superclass : #Object,
	#instVars : [
		'config'
	],
	#classInstVars : [
		'instanceId'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
Phazzer class >> defaultConfig [
]

{ #category : #accessing }
Phazzer class >> instanceId [
	instanceId ifNil: [ instanceId := 0 ].
	instanceId := instanceId + 1.
	^ instanceId
]

{ #category : #'as yet unclassified' }
Phazzer class >> onMethod: aTestMethod [
	self flag: #todo.	"check isTestMethod"
	self new
		config: self defaultConfig;
		fuzzMethod: aTestMethod
]

{ #category : #'as yet unclassified' }
Phazzer >> buildTestClassWith: aCollection using: testClass [
	| tempClass |
	tempClass := testClass
		subclass: (testClass name asString , self getId asString) asSymbol
		instanceVariableNames: ''
		classVariableNames: ''
		package: self defaultTempPackage.
	tempClass class
		pzCompile:
			'allTestSelectors
		| answer |
		answer := Set withAll: self testSelectors.
		answer addAll: self superclass allTestSelectors.
		^ answer asSortedCollection asOrderedCollection'.
	tempClass class
		pzCompile:
			'defaultTimeLimit
	^ 3 seconds '.
	aCollection
		do: [ :item | 
			| ast |
			ast := self parsedMethodFrom: item.
			tempClass pzCompile: ast formattedCode ].
	^ tempClass
]

{ #category : #accessing }
Phazzer >> config: aConfig [
	config:= aConfig
]

{ #category : #'as yet unclassified' }
Phazzer >> defaultTempPackage [
	^ 'PhazzerTempClasses'
]

{ #category : #'as yet unclassified' }
Phazzer >> fuzzMethod: aTestMethod [
	| ts tc |
	ts := config amps
		flatCollect: [ :amp | amp inputAmplify: aTestMethod ].
	tc := self install: ts base: aTestMethod methodClass.
	self run: tc
]

{ #category : #'as yet unclassified' }
Phazzer >> getId [
	^ self class instanceId
]

{ #category : #'as yet unclassified' }
Phazzer >> install: testMethods base: aTestClass [
	"installs test methods on fake test classes.
	 returns the list of fake test classes"

	| tc |
	self flag: #todo.	"paging"
	tc := self buildTestClassWith: testMethods using: aTestClass.
	^ { tc }
]

{ #category : #'as yet unclassified' }
Phazzer >> parsedMethodFrom: aSourceCode [
	^ RBParser parseMethod: aSourceCode
]

{ #category : #'as yet unclassified' }
Phazzer >> run: testClasses [
	
]
