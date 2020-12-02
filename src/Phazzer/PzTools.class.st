Class {
	#name : #PzTools,
	#superclass : #Object,
	#classInstVars : [
		'instanceId'
	],
	#category : #Phazzer
}

{ #category : #accessing }
PzTools class >> instanceId [
	instanceId ifNil: [ instanceId := 0 ].
	instanceId := instanceId + 1.
	^ instanceId
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
	tempClass class
		pzCompile:
			'defaultTimeLimit
	^ 3 seconds '.
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
PzTools >> parsedMethodFrom: aSourceCode [
	^ RBParser parseMethod: aSourceCode
]

{ #category : #removing }
PzTools >> removeSelector: selector inClass: className [
	(self class environment at: className) removeSelector: selector 
]
