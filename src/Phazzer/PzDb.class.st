Class {
	#name : #PzDb,
	#superclass : #Object,
	#instVars : [
		'dbName'
	],
	#category : #Phazzer
}

{ #category : #accessing }
PzDb class >> named: aName [
	^ self new
		dbName: aName;
		initDb;
		yourself
]

{ #category : #'as yet unclassified' }
PzDb class >> stateForCreated [
	^ 0
]

{ #category : #'as yet unclassified' }
PzDb class >> stateForFinished [
	^ 3
]

{ #category : #'as yet unclassified' }
PzDb class >> stateForInstalled [
	" in the future, if you use multiple sandboxes, you flag it to not be installed in multiple vms"

	"^ 1"
	"At the moment, I just have create = installed, because I hava a single vm"
	^ self stateForCreated
]

{ #category : #'as yet unclassified' }
PzDb class >> stateForProcessed [
	^ 4
]

{ #category : #'as yet unclassified' }
PzDb class >> stateForStarted [
	^ 2
]

{ #category : #'as yet unclassified' }
PzDb >> dbName: aName [
	dbName := aName
]

{ #category : #'as yet unclassified' }
PzDb >> idColumn [
	^ self subclassResponsibility 
]

{ #category : #state }
PzDb >> initDb [
]
