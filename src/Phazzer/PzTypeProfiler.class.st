Class {
	#name : #PzTypeProfiler,
	#superclass : #Object,
	#instVars : [
		'varTypes',
		'links'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
PzTypeProfiler class >> instanceVariablesKey [
	^ #instanceVariables
]

{ #category : #accessing }
PzTypeProfiler >> at: key [ 
	^ self variablesTypes at: key 
]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> buildMetalink [
	| l |
	l := MetaLink new
		metaObject: self;
		control: #after;
		selector: #executeAfterNode:context:object:;
		arguments: #(node context object);
		yourself.
	links add: l.
	^ l


]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> executeAfterNode: node context: theContext object: theObject [ 
	| type |
	self variablesTypes
		at: self class instanceVariablesKey
		ifAbsent: [ self profileInstanceVariables: theObject ].
	node isVariable ifFalse: [ ^ self ].
	node isGlobal
		ifTrue: [ "type := self class environment at: node name" ^ self ].	"don't waist resources by keeping Globals"
	node isTemp
		ifTrue: [ type := (theContext tempNamed: node name) class ].
	node isInstance
		ifTrue: [ type := (theObject instVarNamed: node name) class ].
	type
		ifNotNil: [ self variablesTypes
				at: node methodNode selector , ':' , node name
				put: type ]

]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> initialize [ 
	links := OrderedCollection new

]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> installMetaLinksOnMethod: method [ 
	"method ast body link: self buildMetalinkStartMethod."

	method ast allChildren
		select: #isVariable
		thenDo:
			[ :node | "(node links anySatisfy: [ :any | any metaObject isKindOf: self class ])
				ifTrue: [ self error: 'Sth is wrong' ]." node link: self buildMetalink ].

]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> profileInstanceVariables: theObject [ 
	| allInstances allSupers types |
	allSupers := theObject class allSuperclassesIncluding: TestCase.
	allSupers remove: TestCase.
	allInstances := allSupers flatCollect: #instVarNames.
	types := allInstances
		collect: [ :instVar | instVar -> (theObject instVarNamed: instVar) class ].
	self variablesTypes at: self class instanceVariablesKey put: types

]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> runOn: aCompiledMethod [
	[ self installMetaLinksOnMethod: aCompiledMethod.
	self runTestClass: aCompiledMethod ]
		ensure: [ self uninstallMetaLinksOnMethod: aCompiledMethod ]
]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> runTestClass: aCompiledMethod [
	| suite |
	[suite := aCompiledMethod methodClass
		buildSuiteFromMethods: {aCompiledMethod selector}.
	suite run] valueWithin: 3 seconds onTimeout: [ ^ self ]
]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> uninstallMetaLinksOnMethod: method [
	"links do: #uninstall."

	"genPushLiteralVar: index index 258 is out of range 0 to 255"
	links removeAll.
	method recompile
	"method ast allChildren
		select: #isVariable
		thenDo: [ :node | 
			(node links select: [ :metalink | metalink metaObject == self ])
				do: [ :metalink | node removeLink: metalink ] ]."
	"(self values do: [ :x | (x ast links select: #isNotNil)do: #uninstall ])
		"
	"self assert: (method ast allChildren flatCollect: #links) isEmpty"
]

{ #category : #'as yet unclassified' }
PzTypeProfiler >> variablesTypes [ 
	^ varTypes ifNil: [ varTypes := Dictionary new ]
]
