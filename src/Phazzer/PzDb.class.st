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
PzDb >> anyUnFinishedLeft [ 
	^ self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
PzDb >> checkClassIsProcessed: aTestClass [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> dbName: aName [
	dbName := aName
]

{ #category : #'as yet unclassified' }
PzDb >> fetchTests: aNumber [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> flagAllInstalledAsCreated [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> flagAsCreated: rowId [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> flagAsProcessed: rowId [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> getNotFinished [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> idColumn [
	^ self subclassResponsibility 
]

{ #category : #state }
PzDb >> initDb [
]

{ #category : #'as yet unclassified' }
PzDb >> insertTestmethod: sourceCode selector: selector base: class [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> lastUpdate [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> logAnUpdate [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> logTestFinished: aTestCase [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> logTestStart: aTestCase [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> purgeDb [
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
PzDb >> resetLastUpdate [
	^ self subclassResponsibility
]
