Class {
	#name : #PzTools,
	#superclass : #Object,
	#classInstVars : [
		'instanceId'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
PzTools class >> finishedTag [
	^ 'finished'
]

{ #category : #accessing }
PzTools class >> instanceId [
	instanceId ifNil: [ instanceId := 0 ].
	instanceId := instanceId + 1.
	^ instanceId
]

{ #category : #'as yet unclassified' }
PzTools class >> startedTag [
	^ 'started'
]

{ #category : #'as yet unclassified' }
PzTools >> buildFinalTestClassWith: aCollection using: testClass [
	| finalClass |
	finalClass := testClass
		subclass: (testClass name asString , self getId asString) asSymbol
		instanceVariableNames: ''
		classVariableNames: ''
		package: self defaultFinalPackage.
	aCollection
		do: [ :item | 
			| ast |
			ast := self parsedMethodFrom: item.
			finalClass compile: ast formattedCode ].
	^ finalClass
]

{ #category : #'as yet unclassified' }
PzTools >> buildTestClassWith: aCollection using: testClass [
	| tempClass |
	tempClass := testClass
		subclass: (testClass name asString , self getId asString) asSymbol
		instanceVariableNames: ''
		classVariableNames: ''
		package: self defaultTempPackage.
	"tempClass class
		pzCompile:
			'allTestSelectors
		| answer |
		answer := Set withAll: self testSelectors.
		answer addAll: self superclass allTestSelectors.
		^ answer asSortedCollection asOrderedCollection'."
	(tempClass class allInstVarNames includes: #testEvents)
		ifFalse: [ tempClass class addInstVarNamed: 'testEvents' ].
	"(tempClass class selectors includes: #defaultTimeLimit)
		ifFalse: [ tempClass class
				pzCompile:
					'defaultTimeLimit
	^ 3 seconds ' ]."
	tempClass class
		pzCompile:
			'defaultTimeLimit
	^ 3 seconds '.
	tempClass
		pzCompile:
			'setUp
	super setUp.
	testEvents logTestStart: self '.
	tempClass
		pzCompile:
			'tearDown
	super tearDown.
	testEvents logTestFinished: self'.
	tempClass class
		pzCompile: 'testEvents ^ testEvents'.
	tempClass class
		pzCompile: 'testEvents: aTestEvents testEvents := aTestEvents'.
	aCollection
		do: [ :item | 
			| ast |
			ast := self parsedMethodFrom: item.
			[ tempClass pzCompile: ast formattedCode ]
				on: Error
				do: [ :x | "skip tests with compile error" ] ].
	^ tempClass
]

{ #category : #'as yet unclassified' }
PzTools >> clearFinalClasses [
	(self defaultFinalPackage asPackageIfAbsent: [ ^ true ]) classes
		do: [ :item | item removeFromSystem ]
		displayingProgress: 'Clear final classes.'
]

{ #category : #'as yet unclassified' }
PzTools >> clearTempClasses [ 
	(self defaultTempPackage asPackageIfAbsent: [ ^ true ]) classes
		do: [ :item | item removeFromSystem ]
		displayingProgress: 'Clear temp classes.'

]

{ #category : #'as yet unclassified' }
PzTools >> defaultFinalPackage [ 
	^ 'PhazzerFinalClasses'
]

{ #category : #'as yet unclassified' }
PzTools >> defaultTempPackage [
	^ 'PhazzerTempClasses'
]

{ #category : #'as yet unclassified' }
PzTools >> getId [
	^ self class instanceId
]

{ #category : #'as yet unclassified' }
PzTools >> logTestFinished: x [
	| str |
	str := ','
		join:
			{Time now print24.
			x class name.
			x selector.
			self class finishedTag}.
	x class sandBoxedSharedfileName writeStream
		setToEnd;
		nextPutAll: str;
		cr;
		close
]

{ #category : #'as yet unclassified' }
PzTools >> logTestStart: x [
	| str |
	str := ','
		join:
			{Time now print24.
			x class name.
			x selector.
			self class startedTag}.
	x class sandBoxedSharedfileName writeStream
		setToEnd;
		nextPutAll: str;
		cr;
		close
]

{ #category : #'as yet unclassified' }
PzTools >> moveToFinalSelector: selector inClass: className [
	| tcls mtd cls |
	tcls := nil.
	cls := self class environment at: className asSymbol.
	mtd := (cls lookupSelector: selector asSymbol) sourceCode.
	(self defaultFinalPackage
		asPackageIfAbsent: [ RPackageOrganizer default
				createPackageNamed: self defaultFinalPackage ]) classes
		do: [ :dcls | 
			dcls superclass = cls superclass
				ifTrue: [ tcls := dcls ] ].
	tcls
		ifNil: [ self buildFinalTestClassWith: {mtd} using: cls superclass ]
		ifNotNil: [ tcls compile: mtd ]
]

{ #category : #'as yet unclassified' }
PzTools >> parsedMethodFrom: aSourceCode [
	^ RBParser parseMethod: aSourceCode
]

{ #category : #removing }
PzTools >> removeSelector: selector inClass: className [
	| cls |
	cls := self class environment at: className asSymbol ifAbsent: [^ self ].
	cls removeSelectorSilently: selector asSymbol.
	cls testSelectors ifEmpty: [ cls removeFromSystem ]
]
