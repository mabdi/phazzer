Class {
	#name : #PzUniqLiteralsInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#category : #Phazzer
}

{ #category : #removing }
PzUniqLiteralsInputAmplifier >> amplifyInputs [
	| aMethodAST results literals |
	aMethodAST :=  testMethod ast.
	literals := self getAllLiterals: aMethodAST.
	results := OrderedCollection new.
	literals
		keysAndValuesDo: [ :type :set | 
			set size > 1
				ifTrue: [ results
						addAll:
							(set
								collect: [ :v | self transform: aMethodAST copy type: type value: v ]) ] ].
	^ results collect: #formattedCode
]

{ #category : #removing }
PzUniqLiteralsInputAmplifier >> getAllLiterals: aMethodAST [
	| nodes result |
	nodes := (aMethodAST body allChildren select: #isLiteralNode)
		reject: #isLiteralArray.
	result := Dictionary new.
	nodes
		do: [ :n | 
			result at: n value class ifAbsentPut: [ Set new ].
			(result at: n value class) add: n value ].
	^ result
]

{ #category : #'as yet unclassified' }
PzUniqLiteralsInputAmplifier >> namingPrefix [
	^ 'U'
]

{ #category : #removing }
PzUniqLiteralsInputAmplifier >> transform: aMethodAST type: type value: value [
	| nodes |
	nodes := ((aMethodAST allChildren select: #isLiteralNode)
		reject: #isLiteralArray) select: [ :n | n value class = type ].
	nodes
		do:
			[ :n | n parent replaceNode: n withNode: (RBLiteralValueNode value: value) ].
	^ aMethodAST
]
