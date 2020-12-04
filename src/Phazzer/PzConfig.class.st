Class {
	#name : #PzConfig,
	#superclass : #Object,
	#instVars : [
		'amps',
		'debug',
		'freezeTimeOut',
		'sandbox'
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
	^ {(#amps -> PzAbstractInputAmplifier subclasses).
	(#freezeTimeOut -> 5).
	(#sandbox -> true).
	(#debug -> true)} asDictionary at: key
]

{ #category : #accessing }
PzConfig >> freezeTimeOut [
	^ freezeTimeOut ifNil: [ self defaultValues: #freezeTimeOut ]
]

{ #category : #accessing }
PzConfig >> freezeTimeOut: anObject [
	freezeTimeOut := anObject
]

{ #category : #'as yet unclassified' }
PzConfig >> sandBoxedSharedfileName [
	^ 'sandbox-done-tests.txt'
]

{ #category : #accessing }
PzConfig >> sandbox [
	^ sandbox ifNil: [ self defaultValues: #sandbox ]
]

{ #category : #accessing }
PzConfig >> sandbox: anObject [
	sandbox := anObject
]
