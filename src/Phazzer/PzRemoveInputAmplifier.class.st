Class {
	#name : #PzRemoveInputAmplifier,
	#superclass : #PzAbstractInputAmplifier,
	#category : #Phazzer
}

{ #category : #removing }
PzRemoveInputAmplifier >> amplifyInputs [

	| results |

	results := OrderedCollection new.
	aMethodAST statements size < 2
		ifTrue: [ ^ results ].
	aMethodAST statements
		doWithIndex:
			[ :statement :index | results add: (self applyMessageRemove: index on: aMethodAST) ].
	^ results
]

{ #category : #running }
PzRemoveInputAmplifier >> applyMessageRemove: index on: aMethod [
	| empty mClone theCode |
	empty := RBParser parseExpression: ''.
	mClone := aMethod copy.
	mClone statements at: index put: empty.
	theCode := mClone formattedCode.
	self checkTheCodeIsCorrect: theCode.
	^ theCode
]

{ #category : #'as yet unclassified' }
PzRemoveInputAmplifier >> namingPrefix [
	^ 'R'
]
