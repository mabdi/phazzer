Class {
	#name : #PzRotateLiteralsInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#category : #Phazzer
}

{ #category : #removing }
PzRotateLiteralsInputAmplifier >> amplifyInputs [
	| results literals |
	literals := self getAllLiterals.
	results := OrderedCollection new.
	literals
		keysAndValuesDo: [ :type :vals | 
			vals size > 1
				ifTrue: [ 1 to: vals size - 1 do: [ :offset | 
						results
							add:
								(self
									transformType: type
									values: vals
									startFrom: offset) ] ] ].
	^ results collect: #formattedCode
]

{ #category : #removing }
PzRotateLiteralsInputAmplifier >> getAllLiterals [
	| nodes result |
	nodes := aMethodAST body allChildren select: #isLiteralNode.
	nodes := nodes reject: #isLiteralArray.
	nodes := nodes reject: [:n | n parent isLiteralArray].
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
PzRotateLiteralsInputAmplifier >> transformType: type values: vals startFrom: index [
	| nodes newMethodAST |
	newMethodAST := aMethodAST copy.
	nodes := (((newMethodAST body allChildren select: #isLiteralNode)
		reject: #isLiteralArray) reject: [ :n | n parent isLiteralArray ])
		select: [ :n | n value class = type ].
	nodes
		doWithIndex: [ :n :i | 
			n parent
				replaceNode: n
				withNode:
					(RBLiteralValueNode
						value: (vals at: 1 + ((i - 1 + index) % vals size))) ].
	^ newMethodAST
]
