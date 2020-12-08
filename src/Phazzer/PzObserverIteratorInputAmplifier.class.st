Class {
	#name : #PzObserverIteratorInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#category : #Phazzer
}

{ #category : #removing }
PzObserverIteratorInputAmplifier >> amplifyInputs [
	"1. finding all tarrgets
		1.1 find all objects that are a receiver
		1.2 find all left hand sides
		
	2. add a call to a helper method, the target variable is the argument
	
	3. In the helper method, list all public methods lacking a parameter. (allSelector below Object?)
	4. 	bingo
		"

	| results |
	results := OrderedCollection new.
	self createParameterizedTestMethod.
	aMethodAST statements
		doWithIndex: [ :statement :index | results add: (self applyIteratorAdding: index) ].
	^ results
]

{ #category : #removing }
PzObserverIteratorInputAmplifier >> applyIteratorAdding: index [
	| statement mClone theCode |
	mClone := aMethodAST copy.
	statement := mClone statements at: index.
	statement isAssignment
		ifTrue: [ statement := statement value ].
	
	mClone statements add: statement afterIndex: index.
	theCode := mClone formattedCode.
	(theCode includesSubstring: '<an unprintable nonliteral value>')
		ifTrue: [ self error: 'sth is wrong. you shouldnt be here!' ].
	^ theCode
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> createObserverIteratorMethod [
	helperMethods add: (self class >> #pzIterateObservers:number:) sourceCode
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> createParameterizedTestMethod [
	| mClone theCode newStatement offset positionNumber |
	mClone := aMethodAST copy.
	offset := 0.
	positionNumber := 1.
	mClone
		selector: (mClone selector asString , 'ParametrizedI:J:') asSymbol;
		arguments:
			{(RBArgumentNode named: #put_i).
			(RBArgumentNode named: #put_j)}.
	aMethodAST statements
		doWithIndex: [ :statement :index | 
			| theObject |
			newStatement := nil.
			theObject := self getTheObject: statement.
			theObject
				ifNotNil: [ newStatement := self
						statementForVariable: theObject
						index: positionNumber.
					positionNumber := positionNumber + 1.
					mClone statements add: newStatement afterIndex: index + offset.
					offset := offset + 1 ].
			statement isAssignment
				ifTrue: [ newStatement := self
						statementForVariable: statement variable
						index: positionNumber.
					positionNumber := positionNumber + 1.
					mClone statements add: newStatement afterIndex: index + offset.
					offset := offset + 1 ] ].
	mClone statements addLast: (self lastStatementIndex: positionNumber) .
	theCode := mClone formattedCode.
	(theCode includesSubstring: '<an unprintable nonliteral value>')
		ifTrue: [ self error: 'sth is wrong. you shouldnt be here!' ].
	helperMethods add: theCode
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> getTheObject: statement [
	| theObject |
	theObject := statement.
	theObject isAssignment
		ifTrue: [ theObject := statement value ].
	theObject isCascade
		ifTrue: [ theObject := theObject receiver ].
	[ theObject isMessage ]
		whileTrue: [ theObject := theObject receiver ].
	theObject isVariable
		ifFalse: [ ^ nil ].
	({'self' . 'super'} includes: theObject name)
		ifTrue: [ ^ nil ].
	(theObject name at: 1) isUppercase ifTrue: [ ^ nil ] .
	^ theObject
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> lastStatementIndex: positionNumber [
	^ RBMessageNode
		receiver:
			(RBMessageNode
				receiver: (RBVariableNode named: #put_i)
				selector: #>=
				arguments: {(RBLiteralValueNode value: positionNumber)})
		selector: #ifTrue:
		arguments:
			{(RBBlockNode
				body:
					(RBSequenceNode
						statements:
							{(RBMessageNode
								receiver: (RBSelfNode named: #self)
								selector: #error:
								arguments: {(RBLiteralValueNode value: 'no more injection position')})}))}
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> namingPrefix [
	^ 'I'
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> pzIterateObservers: anObject number: anInteger [
	| iterator |
	iterator := 0.
	(((anObject allSelectorsBelow: Object)
		collect: [ :selector | anObject lookupSelector: selector ])
		reject: [ :method | method ast arguments isNotNil ])
		do: [ :method | 
			iterator := iterator + 1.
			iterator == anInteger
				ifTrue: [ ^ anObject perform: method selector ] ].
	self error: 'noMore Selector'
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> statementForVariable: theObject index: index [
	^ RBMessageNode
		receiver:
			(RBMessageNode
				receiver: (RBVariableNode named: #put_i)
				selector: #=
				arguments: {(RBLiteralValueNode value: index)})
		selector: #ifTrue:
		arguments:
			{(RBBlockNode
				body:
					(RBSequenceNode
						statements:
							{(RBMessageNode
								receiver: (RBSelfNode named: #self)
								selector: #pzIterateObservers:number:
								arguments:
									{(RBVariableNode named: theObject name).
									(RBVariableNode named: #put_j)})}))}
]
