Class {
	#name : #PzDuplicateInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#category : #Phazzer
}

{ #category : #removing }
PzDuplicateInputAmplifier >> amplifyInputs [
	| results aMethodAST |
	aMethodAST := testMethod ast.
	results := OrderedCollection new.
	aMethodAST statements
		doWithIndex:
			[ :statement :index | results add: (self applyMessageDuplicate: index on: aMethodAST) ].
	^ results
]

{ #category : #removing }
PzDuplicateInputAmplifier >> applyMessageDuplicate: index on: aMethod [
	| statement mClone theCode |
	mClone := aMethod copy.
	statement := mClone statements at: index.
	statement isAssignment ifTrue: [ statement := statement value ].
	mClone statements add: statement afterIndex: index.
	theCode := mClone formattedCode.
	(theCode includesSubstring: '<an unprintable nonliteral value>')
		ifTrue: [ self error: 'sth is wrong. you shouldnt be here!' ].
	^ theCode
]

{ #category : #'as yet unclassified' }
PzDuplicateInputAmplifier >> namingPrefix [
	^ 'D'
]
