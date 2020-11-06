Class {
	#name : #PzConfig,
	#superclass : #Object,
	#instVars : [
		'amps',
		'debug'
	],
	#category : #Phazzer
}

{ #category : #accessing }
PzConfig >> amps [
	^ amps ifNil: [ self defaultValues: #amps ]
]

{ #category : #accessing }
PzConfig >> amps: anObject [
	amps := anObject
]

{ #category : #'as yet unclassified' }
PzConfig >> debug [
	^ debug ifNil: [ self defaultValues: #debug ]
]

{ #category : #'as yet unclassified' }
PzConfig >> debug: boolean [
	debug := boolean 
]

{ #category : #accessing }
PzConfig >> defaultValues: key [
	^ { #amps -> (PzAbstractInputAmplifier subclasses).
	(#debug -> true) } asDictionary at: key
]
