Class {
	#name : #PzConfig,
	#superclass : #Object,
	#instVars : [
		'amps',
		'debug',
		'freezeTimeOut',
		'sandbox',
		'sandboxSharedFile'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
PzConfig class >> defaultConfigFile [
	^ 'phazzer.conf'
]

{ #category : #'as yet unclassified' }
PzConfig class >> loadFromFile [
	| lines |
	(FileLocator imageDirectory / self defaultConfigFile) exists
		ifFalse: [ self writeDefaultConfing ].
	lines := (FileLocator imageDirectory / self defaultConfigFile)
		contents splitOn: String cr.
	((lines reject: #isEmpty) reject: [ :l | l beginsWith: '#' ])
		collect: [ :line | line splitOn: '=' ]
]

{ #category : #writing }
PzConfig class >> writeDefaultConfing [
	
]

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
	(#sandboxSharedFile -> 'sandbox-done-tests.txt').
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

{ #category : #accessing }
PzConfig >> sandbox [
	^ sandbox ifNil: [ self defaultValues: #sandbox ]
]

{ #category : #accessing }
PzConfig >> sandbox: anObject [
	sandbox := anObject
]

{ #category : #accessing }
PzConfig >> sandboxSharedFile [
	^ sandboxSharedFile ifNil: [ self defaultValues: #sandboxSharedFile ]
]

{ #category : #accessing }
PzConfig >> sandboxSharedFile: anObject [
	sandboxSharedFile := anObject
]