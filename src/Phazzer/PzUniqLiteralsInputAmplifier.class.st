Class {
	#name : #PzUniqLiteralsInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#category : #Phazzer
}

{ #category : #removing }
PzUniqLiteralsInputAmplifier >> amplifyInputs [
	| results literals |
	literals := self getAllLiterals.
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
PzUniqLiteralsInputAmplifier >> getAllLiterals [
	| nodes result |
	nodes := ((aMethodAST body allChildren select: #isLiteralNode)
		reject: #isLiteralArray)reject: [ :n | n parent isLiteralArray ].
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
PzUniqLiteralsInputAmplifier >> transform: newMethodAST type: type value: value [
	| nodes |
	nodes := (((newMethodAST allChildren select: #isLiteralNode)
		reject: #isLiteralArray) reject: [ :n | n parent isLiteralArray ] ) select: [ :n | n value class = type ].
	nodes
		do:
			[ :n | n parent replaceNode: n withNode: (RBLiteralValueNode value: value) ].
	^ newMethodAST
]
