Class {
	#name : #PzAbstractInputAmplifier,
	#superclass : #Object,
	#instVars : [
		'config',
		'testMethod',
		'aMethodAST',
		'helperMethods',
		'profile'
	],
	#category : #Phazzer
}

{ #category : #removing }
PzAbstractInputAmplifier class >> initializeWith: aConfig [
	^ self new
		  with: aConfig
]

{ #category : #removing }
PzAbstractInputAmplifier >> amplifyInputs [
	^ self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
PzAbstractInputAmplifier >> checkTheCodeIsCorrect: theCode [
	| nonLiteralError |
	nonLiteralError:= '<an unprintable nonliteral value>'.
	(testMethod includesSubstring: nonLiteralError) ifFalse:[  
	( theCode includesSubstring: nonLiteralError)
		ifTrue: [ self error: 'sth is wrong. you shouldnt be here!' ]]
]

{ #category : #removing }
PzAbstractInputAmplifier >> helperMethods [
	^ helperMethods
]

{ #category : #removing }
PzAbstractInputAmplifier >> inputAmplify: aTestMethod [
	| result versions |
	result  :=  OrderedCollection new.
	testMethod := aTestMethod.
	helperMethods := OrderedCollection new.
	aMethodAST := self tool parsedMethodFrom: testMethod.
	[ versions := self amplifyInputs.
	result addAll: (self rename: versions).
	result addAll: helperMethods.
	^ result  ]

		on: Error
		do: [ :x | 
			config debug
				ifTrue: [ self halt ].
			^ {} ]
]

{ #category : #'as yet unclassified' }
PzAbstractInputAmplifier >> namingPrefix [
	^ self class name
]

{ #category : #accessing }
PzAbstractInputAmplifier >> profile [
	^ profile
]

{ #category : #accessing }
PzAbstractInputAmplifier >> profile: anObject [
	profile := anObject
]

{ #category : #'change set' }
PzAbstractInputAmplifier >> rename: versions [
	| idx |
	idx := 0.
	^ versions
		collect: [ :mtd | 
			| cp |
			cp := (self
				renameMethodName: (self tool parsedMethodFrom: mtd)
				append: '_' , self namingPrefix , idx asString) formattedCode.
			idx := idx + 1.
			cp ]
]

{ #category : #'change set' }
PzAbstractInputAmplifier >> renameMethodName: anAst append: aText [
	| first |
	first := (anAst selector splitOn: $:) at: 1.
	anAst
		selector: ((anAst selector splitOn: $:) at: 1 put: first , aText).
	^ anAst
]

{ #category : #'change set' }
PzAbstractInputAmplifier >> tool [
	^ PzTools new
]

{ #category : #removing }
PzAbstractInputAmplifier >> with: aConfig [
	config := aConfig
]
