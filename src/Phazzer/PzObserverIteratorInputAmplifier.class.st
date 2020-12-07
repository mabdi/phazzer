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
	self flag: #todo.
	
]

{ #category : #'as yet unclassified' }
PzObserverIteratorInputAmplifier >> namingPrefix [
	^ 'I'
]
