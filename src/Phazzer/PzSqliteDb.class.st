Class {
	#name : #PzSqliteDb,
	#superclass : #Object,
	#instVars : [
		'dbName'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
PzSqliteDb class >> stateForCreated [
	^ 0
]

{ #category : #'as yet unclassified' }
PzSqliteDb class >> stateForFinished [
	^ 3
]

{ #category : #'as yet unclassified' }
PzSqliteDb class >> stateForInstalled [
	^ 1
]

{ #category : #'as yet unclassified' }
PzSqliteDb class >> stateForProcessed [
	^ 4
]

{ #category : #'as yet unclassified' }
PzSqliteDb class >> stateForStarted [
	^ 2
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> checkClassIsProcessed: aTestClass [
	| db cursor |
	db := self getDb.
	db open.
	^ [ cursor := db
		execute: 'select count(*) as count from tests where baseClass = ?'
		value: aTestClass name.
	(cursor next at: #count) = 0 ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> createTableGlobals [
	| db |
	db := self getDb.
	db open.
	[ db
		execute:
			'CREATE TABLE IF NOT EXISTS globals (
	key TEXT NOT NULL UNIQUE,
	value TEXT NOT NULL
);'.
	db
		execute: 'INSERT OR IGNORE  INTO globals(key,value) VALUES ("lastUpdate", 0);' ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> createTableTests [
	| db |
	db := self getDb.
	db open.
	[ db
		execute:
			'CREATE TABLE IF NOT EXISTS tests (
	baseClass TEXT NOT NULL,
	selector TEXT NOT NULL,
	testMethod TEXT NOT NULL,
	status INTEGER NOT NULL,
	extra TEXT
);' ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> dbName: aName [
	dbName := aName
]

{ #category : #accessing }
PzSqliteDb >> fetchTests: aNumber [
	| db c data |
	db := self getDb.
	db open.
	data := nil.
	[ c := db
		execute:
			'SELECT rowid, baseClass, testMethod 
                   FROM tests
                   WHERE status = ? 
                   ORDER BY rowid LIMIT ' , aNumber asString
		value: self class stateForCreated.
	data := c rows.
	data
		ifNotEmpty: [ db
				execute:
					'UPDATE tests
SET status = ?
WHERE status = ? and rowid <= ?'
				value: self class stateForInstalled
				value: self class stateForCreated
				value: (data last at: #rowid) ] ]
		ensure: [ db close ].
	^ data
]

{ #category : #accessing }
PzSqliteDb >> flagAllInstalledAsCreated [
	| db |
	db := self getDb.
	db open.
	[ db
		execute: 'UPDATE tests SET status = ? WHERE status = ?'
		value: self class stateForCreated
		value: self class stateForInstalled ]
		ensure: [ db close ]
]

{ #category : #accessing }
PzSqliteDb >> flagAsCreated: rowId [
	| db |
	db := self getDb.
	db open.
	[ db
		execute: 'UPDATE tests SET status = ? WHERE rowid = ?'
		value: self class stateForCreated
		value: rowId ]
		ensure: [ db close ]
]

{ #category : #accessing }
PzSqliteDb >> flagAsProcessed: rowId [
	| db |
	db := self getDb.
	db open.
	[  
			db
				execute: 'UPDATE tests SET status = ? WHERE rowid = ?'
				value: self class stateForProcessed
				value: rowId ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> getDb [
	^ SQLite3Connection
		on: (Smalltalk imageDirectory / dbName) fullName
]

{ #category : #accessing }
PzSqliteDb >> getNotFinished [
	| db c |
	db := self getDb.
	db open.
	^ [ c := db
		execute:
			'SELECT rowid, baseClass, testMethod, selector, status
                   FROM tests
                   WHERE status = ?'
		value: self class stateForStarted.
	c rows ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> initDb [
	self createTableTests .
	self createTableGlobals 
]

{ #category : #initialization }
PzSqliteDb >> initialize [ 	
	dbName := 'phazzer.db' 
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> lastUpdate [
	| db c data |
	db := self getDb.
	db open.
	data :=  [ c := db
		execute:
			'select value from globals
WHERE key = "lastUpdate"'.
	c rows ]
		ensure: [ db close ].
	data ifEmpty: [ ^ 0 ].
	^ (data at: 1) at: #value
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> logAnUpdate [
	| db |
	db := self getDb.
	db open.
	[ db
		execute:
			'UPDATE globals
SET value = ?
WHERE key = "lastUpdate"'
		value: DateAndTime now asUnixTime asString ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> logTestFinished: aTestCase [
	| db |
	db := self getDb.
	db open.
	[ db
		execute:
			'UPDATE tests SET status = ?
WHERE status = ? and baseClass = ? and selector = ?'
		with:
			{self class stateForFinished.
			self class stateForStarted.
			aTestCase class superclass name.
			aTestCase selector asString} ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> logTestStart: aTestCase [
	| db |
	db := self getDb.
	db open.
	[ db
		execute:
			'UPDATE tests
SET status = ?
WHERE status = ? and baseClass = ? and selector = ?'
		with:
			{self class stateForStarted.
			self class stateForInstalled.
			aTestCase class superclass name.
			aTestCase selector asString} ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> purgeDb [
	| db |
	db := self getDb.
	db open.
	[ db execute: 'DROP TABLE IF EXISTS tests;'.
	db execute: 'DROP TABLE IF EXISTS globals;' ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> stashTestmethod: sourceCodes base: class [
	| db selector |
	db := self getDb.
	db open.
	[ sourceCodes
		do: [ :sourceCode | 
			selector := (PzTools new parsedMethodFrom: sourceCode) selector.
			db
				execute:
					'INSERT INTO tests(baseClass,selector,testMethod,status) VALUES (:baseClass,:selector,:method,:status);'
				with:
					{(':baseClass' -> class name).
					(':selector' -> selector).
					(':method' -> sourceCode).
					(':status' -> self class stateForCreated)} asDictionary ] ]
		ensure: [ db close ]
]
