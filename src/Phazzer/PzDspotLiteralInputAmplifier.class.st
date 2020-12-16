Class {
	#name : #PzDspotLiteralInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#instVars : [
		'mappings'
	],
	#category : #Phazzer
}

{ #category : #removing }
PzDspotLiteralInputAmplifier >> addARandomCharacterTo: aString [
	| x |
	x := aString size atRandom.
	^ (aString copyFrom: 1 to: x) , self characterSet atRandom asString
		, (aString copyFrom: x + 1 to: aString size)
]

{ #category : #'as yet unclassified' }
PzDspotLiteralInputAmplifier >> ampNumbersLiteralArray: n [
	| half res |
	res := OrderedCollection new.
	n parent isForByteArray
		ifTrue: [ "3 bit integers"
			res add: n -> (RBLiteralValueNode value: 0).
			res add: n -> (RBLiteralValueNode value: 255).
			res add: n -> (RBLiteralValueNode value: 256 atRandom - 1).
			^ res ].
	half := n value isInteger
		ifTrue: [ (n value / 2) asInteger ]
		ifFalse: [ n value / 2 ].
	res
		addAll:
			{(n -> (RBLiteralValueNode value: n value - 1)).
			(n -> (RBLiteralValueNode value: n value + 1)).
			(n -> (RBLiteralValueNode value: n value * -1)).
			(n -> (RBLiteralValueNode value: n value * 2)).
			(n -> (RBLiteralValueNode value: half))}.
	n value isFloat
		ifTrue: [ res
				addAll:
					{(n -> (RBLiteralValueNode value: 0.0)).
					(n -> (RBLiteralValueNode value: -0.0))} ].
	n value isInteger
		ifTrue: [ res addAll: {(n -> (RBLiteralValueNode value: 0))} ].
	^ res
]

{ #category : #'as yet unclassified' }
PzDspotLiteralInputAmplifier >> ampNumbersNormal: n from: nodes [
	| sameTypeNodes half res |
	sameTypeNodes := nodes reject: [ :n2 | n2 == n ].
	half := n value isInteger
		ifTrue: [ (n value / 2) asInteger ]
		ifFalse: [ n value / 2 ].
	res := OrderedCollection new.
	sameTypeNodes
		ifNotEmpty: [ res
				add: n -> (RBLiteralValueNode value: sameTypeNodes atRandom value) ].
	res
		addAll:
			{(n -> (RBLiteralValueNode value: n value - 1)).
			(n -> (RBLiteralValueNode value: n value + 1)).
			(n -> (RBLiteralValueNode value: n value * 2)).
			(n -> (RBLiteralValueNode value: half))}.
	n value isFloat
				ifTrue: [ res
						addAll:
							{(n
								->
									(RBMessageNode receiver: (RBVariableNode named: #Float) selector: #nan)).
							(n -> (RBLiteralValueNode value: 0.0)).
							(n -> (RBLiteralValueNode value: -0.0)).
							(n -> (RBLiteralValueNode value: n value * -1)).
							(n
								->
									(RBMessageNode
										receiver: (RBVariableNode named: #Float)
										selector: #infinity)).
							(n
								->
									(RBMessageNode
										receiver: (RBVariableNode named: #Float)
										selector: #negativeInfinity))} ].
			n value isInteger
				ifTrue: [ res
						addAll:
							{(n -> (RBLiteralValueNode value: 0)).
							(n -> (RBLiteralValueNode value: n value * -1)).
							(n
								->
									(RBMessageNode
										receiver: (RBVariableNode named: #SmallInteger)
										selector: #minVal)).
							(n
								->
									(RBMessageNode
										receiver: (RBVariableNode named: #SmallInteger)
										selector: #maxVal))} ].
	^ res
]

{ #category : #removing }
PzDspotLiteralInputAmplifier >> amplifyBooleans [
	| nodes |
	nodes := aMethodAST body allChildren
		select: [ :n | 
			n isLiteralNode
				and: [ True = n value class | (False = n value class) ] ].
	mappings
		addAll:
			(nodes collect: [ :n | n -> (RBLiteralValueNode value: n value not) ])
]

{ #category : #removing }
PzDspotLiteralInputAmplifier >> amplifyFloat: aValue [ 
	| nodes |
	nodes := {(aValue + 1).
	(aValue - 1).
	(aValue * -1).
	(aValue * 2).
	(aValue / 2).
	0.0.
	-0.0
	"Float nan.
	Float infinity.
	Float negativeInfinity"}
		asOrderedCollection.
	nodes := (nodes reject: [ :x | x = aValue ])
		collect: [ :q | RBLiteralValueNode value: q ]
]

{ #category : #removing }
PzDspotLiteralInputAmplifier >> amplifyInputs [
	| results |
	mappings := OrderedCollection new.
	self amplifyNumbers.
	self amplifyStrings.
	self amplifyBooleans.
	results := OrderedCollection new.
	mappings
		do: [ :map | results addAll: (self replaceMappings: map on: aMethodAST) ].
	^ results
	"
| nodes sameTypeNodes |
	nodes := mutator mutateNode: aLiteralNode.
	aLiteralNode value isNumber
		ifTrue: [ sameTypeNodes := aMethodAST allChildren
				select:
					[ :n | n isLiteralNode and: [ n value class = aLiteralNode value class ] ].
			sameTypeNodes reject: [ :x | x value = aLiteralNode value ].
			sameTypeNodes ifNotEmpty: [ nodes add: sameTypeNodes atRandom ] ].
	^ nodes"
]

{ #category : #removing }
PzDspotLiteralInputAmplifier >> amplifyNumbers [
	| nodes |
	nodes := aMethodAST body allChildren
		select: [ :n | n isLiteralNode and: [ n value isNumber ] ].
	mappings
		addAll:
			(nodes
				flatCollect: [ :n | 
					n parent isLiteralArray
						ifTrue: [ self ampNumbersLiteralArray: n ]
						ifFalse: [ self ampNumbersNormal: n from: nodes ] ]).
	mappings := mappings reject: #isNil
]

{ #category : #removing }
PzDspotLiteralInputAmplifier >> amplifyStrings [
	| nodes |
	nodes := aMethodAST body allChildren
		select:
			[ :n | n isLiteralNode and: [ n value isKindOf: ByteString ] ].
	mappings
		addAll:
			(nodes
				flatCollect: [ :n | 
					{(n
						-> (RBLiteralValueNode value: (self addARandomCharacterTo: n value))).
					(n
						-> (RBLiteralValueNode value: (self removeARandomCharacterFrom: n value))).
					(n
						->
							(RBLiteralValueNode value: (self replaceARandomCharacterFrom: n value))).
					(n
						-> (RBLiteralValueNode value: (self newRandomStringSameSize: n value)))} ]).
	mappings := mappings reject: #isNil
]

{ #category : #'recursive descent' }
PzDspotLiteralInputAmplifier >> characterSet [
	^ String
		streamContents: [ :stream | 
			Character alphabet putOn: stream.
			Character alphabet asUppercase putOn: stream.
			'0123456789' putOn: stream.
			'!@#$%^&*(){}\|''";:?/.>,<`~§±' putOn: stream.
			Character space putOn: stream.
			Character cr putOn: stream.
			Character tab putOn: stream ]
]

{ #category : #'as yet unclassified' }
PzDspotLiteralInputAmplifier >> namingPrefix [
	^ 'L'
]

{ #category : #removing }
PzDspotLiteralInputAmplifier >> newRandomStringSameSize: aString [
	^ (String new: aString size) collect: [ :each | self characterSet atRandom ]
]

{ #category : #removing }
PzDspotLiteralInputAmplifier >> removeARandomCharacterFrom: aString [
	aString ifEmpty: [ ^ aString ].
	^ aString copyWithoutIndex: aString size atRandom
]

{ #category : #removing }
PzDspotLiteralInputAmplifier >> replaceARandomCharacterFrom: aString [
	aString ifEmpty: [ ^ aString ].
	^ aString copy
		at: aString size atRandom put: self characterSet atRandom;
		yourself
]

{ #category : #'as yet unclassified' }
PzDspotLiteralInputAmplifier >> replaceMappings: map on: aMethod [
	| result |
	result := OrderedCollection new.
	map value
		do: [ :change | 
			| rewriter mClone theCode |
			mClone := aMethod copy.
			rewriter := RBParseTreeRewriter new.
			rewriter
				replaceTree: map key
				withTree: change
				when: [ :n | n start = map key start ].
			rewriter executeTree: mClone.
			theCode := mClone formattedCode.
			self checkTheCodeIsCorrect: theCode.
			result add: theCode ].
	^ result
]
