Class {
	#name : #PzContinueInSandbox,
	#superclass : #Error,
	#category : #Phazzer
}

{ #category : #private }
PzContinueInSandbox >> defaultAction [ 
	^ self
]

{ #category : #private }
PzContinueInSandbox >> isResumable [ 
	^ false
]
