Class {
	#name : #PzMongoDb,
	#superclass : #PzDb,
	#instVars : [
		'openInstance',
		'mongo'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
PzMongoDb >> anyUnFinishedLeft [
	| db |
	db := self getTests.
	^ db
		sizeForQuery:
			{(#'$or'
				->
					{{(#status -> self class stateForFinished)} asDictionary.
					{(#status -> self class stateForProcessed)} asDictionary})}
				asDictionary
]

{ #category : #'as yet unclassified' }
PzMongoDb >> checkClassIsProcessed: aTestClass [
	| db |
	db := self getTests.
	^ (db sizeForQuery: {(#baseClass -> aTestClass name)} asDictionary)
		= 0
]

{ #category : #'initialize-release' }
PzMongoDb >> close [ 
	mongo close
]

{ #category : #'as yet unclassified' }
PzMongoDb >> fetchTests: aNumber [
	| db |
	db := self getTests.
	^ db
		select: {(#status -> self class stateForCreated)} asDictionary
		limit: aNumber
		offset: 0
]

{ #category : #'as yet unclassified' }
PzMongoDb >> flagAllInstalledAsCreated [
	| db |
	db := self getTests.
	db
		update: {(#status -> self class stateForInstalled)} asDictionary
		with:
			{(#'$set' -> {(#status -> self class stateForCreated)} asDictionary)}
				asDictionary
]

{ #category : #'as yet unclassified' }
PzMongoDb >> flagAsCreated: rowId [
	| db |
	db := self getTests.
	db
		update: {(#_id -> rowId)} asDictionary
		with:
			{(#'$set' -> {(#status -> self class stateForCreated)} asDictionary)}
				asDictionary
]

{ #category : #'as yet unclassified' }
PzMongoDb >> flagAsProcessed: rowId [
	| db |
	db := self getTests .
	db
		update: {(#_id -> rowId)} asDictionary
		with:
			{(#'$set' -> {(#status -> self class stateForProcessed)} asDictionary)}
				asDictionary
]

{ #category : #'as yet unclassified' }
PzMongoDb >> getDb [
	mongo ifNil: [ mongo := Mongo default ].
	mongo isOpen
		ifFalse: [ mongo open ].
	^ mongo databaseNamed: dbName
]

{ #category : #'as yet unclassified' }
PzMongoDb >> getGlobals [
	^ self getDb getCollection: 'globals'
]

{ #category : #'as yet unclassified' }
PzMongoDb >> getNotFinished [
	| db |
	db := self getTests.
	^ db select: {(#status -> self class stateForStarted)} asDictionary
]

{ #category : #'as yet unclassified' }
PzMongoDb >> getTests [
	^ self getDb getCollection: 'tests'
]

{ #category : #'as yet unclassified' }
PzMongoDb >> idColumn [
	^ #_id
]

{ #category : #state }
PzMongoDb >> initDb [

]

{ #category : #'as yet unclassified' }
PzMongoDb >> insertTestmethod: sourceCode selector: selector base: class [
	| db |
	db := self getTests.
	db
		add:
			{(#baseClass -> class name).
			(#selector -> selector).
			(#testMethod -> sourceCode).
			(#status -> self class stateForCreated)} asDictionary
]

{ #category : #'as yet unclassified' }
PzMongoDb >> lastUpdate [
	| db rows |
	db := self getGlobals.
	rows := (db select: {(#key -> 'lastUpdate')} asDictionary).
	rows ifEmpty: [^ 0 ].
	^ (rows first at: #value) asInteger
]

{ #category : #'as yet unclassified' }
PzMongoDb >> logAnUpdate [
	| db rows |
	db := self getGlobals.
	rows := db
		update: {(#key -> 'lastUpdate')} asDictionary
		with:
			{(#key -> 'lastUpdate').
			(#value -> DateAndTime now asUnixTime)} asDictionary
		flags: UpdateOperation flagUpsert
]

{ #category : #'as yet unclassified' }
PzMongoDb >> logTestFinished: aTestCase [
	| db |
	db := self getTests.
	db
		update:
			{(#status -> self class stateForStarted).
			(#baseClass -> aTestCase class superclass name).
			(#selector -> aTestCase selector asString)} asDictionary
		with:
			{(#'$set' -> {(#status -> self class stateForFinished)} asDictionary)}
				asDictionary
]

{ #category : #'as yet unclassified' }
PzMongoDb >> logTestStart: aTestCase [
	| db |
	db := self getTests.
	db
		update:
			{(#status -> self class stateForCreated).
			(#baseClass -> aTestCase class superclass name).
			(#selector -> aTestCase selector asString)} asDictionary
		with:
			{(#'$set' -> {(#status -> self class stateForStarted)} asDictionary)}
				asDictionary
]

{ #category : #'as yet unclassified' }
PzMongoDb >> purgeDb [
	self getTests drop.
	self getGlobals drop
]

{ #category : #'as yet unclassified' }
PzMongoDb >> resetLastUpdate [
	| db rows |
	db := self getGlobals.
	rows := db
		update: {(#key -> 'lastUpdate')} asDictionary
		with: {(#'$set' -> {(#value -> 0)} asDictionary)} asDictionary
]
