Class {
	#name : #PzRotateLiteralsInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#category : #Phazzer
}

{ #category : #removing }
PzRotateLiteralsInputAmplifier >> amplifyInputs [
	| aMethodAST results literals |
	aMethodAST :=  testMethod ast.
	literals := self getAllLiterals: aMethodAST.
	results := OrderedCollection new.
	literals
		keysAndValuesDo: [ :type :vals | 
			vals size > 1
				ifTrue: [ 1 to: vals size - 1 do: [ :offset | 
						results
							add:
								(self
									transform: aMethodAST copy
									type: type
									values: vals
									startFrom: offset) ] ] ].
	^ results collect: #formattedCode
]

{ #category : #removing }
PzRotateLiteralsInputAmplifier >> getAllLiterals: aMethodAST [
	| nodes result |
	nodes := (aMethodAST body allChildren select: #isLiteralNode)
		reject: #isLiteralArray.
	result := Dictionary new.
	nodes
		do: [ :n | 
			result at: n value class ifAbsentPut: [ OrderedCollection new ].
			(result at: n value class) add: n value ].
	^ result
]

{ #category : #'as yet unclassified' }
PzRotateLiteralsInputAmplifier >> namingPrefix [
	^ 'O'
]

{ #category : #removing }
PzRotateLiteralsInputAmplifier >> transform: aMethodAST type: type value: value [
	| nodes |
	nodes := ((aMethodAST body allChildren select: #isLiteralNode)
		reject: #isLiteralArray) select: [ :n | n value class = type ].
	nodes
		do:
			[ :n | n parent replaceNode: n withNode: (RBLiteralValueNode value: value) ].
	^ aMethodAST
]

{ #category : #removing }
PzRotateLiteralsInputAmplifier >> transform: aMethodAST type: type values: vals startFrom: index [
	| nodes |
	nodes := ((aMethodAST body allChildren select: #isLiteralNode)
		reject: #isLiteralArray) select: [ :n | n value class = type ].
	nodes
		doWithIndex: [ :n :i | 
			n parent
				replaceNode: n
				withNode:
					(RBLiteralValueNode
						value: (vals at: 1 + ((i -1 + index) % vals size))) ].
	^ aMethodAST
]
