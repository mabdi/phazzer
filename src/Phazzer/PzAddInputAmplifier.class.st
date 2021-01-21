Class {
	#name : #PzAddInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#category : #Phazzer
}

{ #category : #removing }
PzAddInputAmplifier >> amplifyInputs [
	| results |
	results := OrderedCollection new.
	results addAll: self applySetupMessage.
	aMethodAST statements
		doWithIndex:
			[ :statement :index | results addAll: (self applyMessageAdd: index) ].
	^ results
]

{ #category : #removing }
PzAddInputAmplifier >> applyMessageAdd: index [
	| newStatements statement mClone theCode results |
	results := OrderedCollection new.
	statement := aMethodAST statements at: index.
	(self checkSafeToAddAfter: statement)
		ifFalse: [ ^ results ].
	newStatements := self generateNewStatementsAfter: statement.
	results := newStatements
		collect: [ :stmt | 
			mClone := aMethodAST copy.
			mClone statements add: stmt afterIndex: index.
			theCode := mClone formattedCode.
			(theCode includesSubstring: '<an unprintable nonliteral value>')
				ifTrue: [ self error: 'sth is wrong. you shouldnt be here!' ].
			theCode
			"results add: theCode" ].
	^ results
]

{ #category : #removing }
PzAddInputAmplifier >> applySetupMessage [
	| nodes mClone theCode results |
	nodes := OrderedCollection new.
	(profile variablesTypes at: PzTypeProfiler instanceVariablesKey)
		do: [ :pair | 
			| methods |
			methods := pair value methods
				reject: [ :m | self isNotSafeToSelect: m ].
			nodes
				addAll:
					(methods
						collect:
							[ :m | self createMessageNodeFor: m type: pair value reveiver: pair key ]) ].
	nodes := nodes reject: #isNil.
	results := nodes
		collect: [ :stmt | 
			mClone := aMethodAST copy.
			mClone statements addFirst: stmt.
			theCode := mClone formattedCode.
			(theCode includesSubstring: '<an unprintable nonliteral value>')
				ifTrue: [ self error: 'sth is wrong. you shouldnt be here!' ].
			theCode ].
	^ results
]

{ #category : #removing }
PzAddInputAmplifier >> checkSafeToAddAfter: statement [
	| msg key |
	msg := statement.
	statement isAssignment
		ifTrue: [ msg := statement value ].
	msg isMessage
		ifFalse: [ ^ false ].
	msg receiver isVariable
		ifFalse: [ ^ false ].
	(self isVariableGlobal: msg receiver name)
		ifTrue: [ ^ true ].
	key := aMethodAST selector , ':' , msg receiver name.
	^ profile variablesTypes includesKey: key
]

{ #category : #removing }
PzAddInputAmplifier >> createMessageNodeFor: method type: class reveiver: aName [
	
	^ RBMessageNode
		receiver: (RBVariableNode named: aName)
		selector: method selector
		arguments: OrderedCollection new
]

{ #category : #removing }
PzAddInputAmplifier >> generateNewStatementsAfter: statement [ 
	| msg nodes returnVal |
	statement isAssignment
		ifTrue: [ msg := statement value.
			returnVal := statement variable ].
	statement isMessage
		ifTrue: [ msg := statement ].
	nodes := OrderedCollection new. 
	nodes addAll: (self nodesFor: msg receiver name).
	returnVal  ifNotNil: [nodes addAll: (self nodesFor: returnVal name)].
	nodes := nodes reject: #isNil.
	^ nodes
]

{ #category : #testing }
PzAddInputAmplifier >> isNotSafeToSelect: method [
	({#private . #deprecated . #initialization} includes: method protocol)
		ifTrue: [ ^ true ].
	(method selector includesSubstring: ':')
		ifTrue: [ ^ true ].
	method isBinarySelector ifTrue: [ ^ true ].	
	^ false
]

{ #category : #testing }
PzAddInputAmplifier >> isVariableGlobal: aName [ 
	aName first isLowercase
		ifTrue: [ ^ false ].
	self class environment at: aName ifPresent: [^ true] ifAbsent: [ ^ false ]
]

{ #category : #'as yet unclassified' }
PzAddInputAmplifier >> namingPrefix [
	^ 'A'
]

{ #category : #removing }
PzAddInputAmplifier >> nodesFor: variableName [
	| theType methods |
	theType := profile variablesTypes
		at: aMethodAST selector , ':' , variableName
		ifAbsent: [ nil class ].
	theType isMeta
		ifTrue: [ ^ {} ].
	theType = nil class
		ifTrue: [ ^ {} ].
	methods := theType methods reject: [ :m | self isNotSafeToSelect: m ].
	^ methods
		collect:
			[ :m | self createMessageNodeFor: m type: theType reveiver: variableName ]
]
