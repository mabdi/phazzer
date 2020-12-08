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
PzObserverIteratorInputAmplifier >> createParameterizedTestMethod [
	| mClone theCode newStatement |
	mClone := aMethodAST copy.
	mClone
		selector: (mClone selector asString, 'ParametrizedI:J:') asSymbol;
		arguments:
			{(RBArgumentNode named: #put_i).
			(RBArgumentNode named: #put_j)}.
	aMethodAST statements
		doWithIndex: [ :statement :index | "
	statement := mClone statements at: index." "statement isAssignment
		ifTrue: [ statement := statement value ].
	statement isMessage .
	" mClone statements add: newStatement afterIndex: index ].
	theCode := mClone formattedCode.
	(theCode includesSubstring: '<an unprintable nonliteral value>')
		ifTrue: [ self error: 'sth is wrong. you shouldnt be here!' ]
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> namingPrefix [
	^ 'I'
]
