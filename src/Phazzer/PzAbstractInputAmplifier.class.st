Class {
	#name : #PzAbstractInputAmplifier,
	#superclass : #Object,
	#instVars : [
		'config',
		'testMethod'
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

{ #category : #removing }
PzAbstractInputAmplifier >> inputAmplify: aTestMethod [
	| versions |
	testMethod := aTestMethod.
	[ versions := self amplifyInputs.
	^ self rename:versions ]
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

{ #category : #'change set' }
PzAbstractInputAmplifier >> rename: versions [
	| idx |
	idx := 0.
	^ versions
		collect: [ :mtd | 
			| cp |
			cp := 
				
					(self
						renameMethodName: mtd
						append: '_' , self namingPrefix , idx asString)
						formattedCode.
			idx := idx + 1.
			cp ]
]

{ #category : #'change set' }
PzAbstractInputAmplifier >> renameMethodName: ast append: aText [
	| first |
	first := (ast selector splitOn: $:) at: 1.
	ast selector: ((ast selector splitOn: $:) at: 1 put: first , aText).
	^ ast
]

{ #category : #removing }
PzAbstractInputAmplifier >> with: aConfig [
	config := aConfig
]
