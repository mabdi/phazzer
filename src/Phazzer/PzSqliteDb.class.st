Class {
	#name : #PzSqliteDb,
	#superclass : #Object,
	#category : #Phazzer
}

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
	key TEXT NOT NULL,
	value TEXT NOT NULL
);'.
	db execute: 'INSERT INTO globals(key,value) VALUES ("lastUpdate", 0);' ]
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
	testMethod TEXT NOT NULL,
	status INTEGER NOT NULL,
	extra TEXT
);' ]
		ensure: [ db close ]
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
                   WHERE status = 0
                   ORDER BY rowid LIMIT ' , aNumber asString , ')'.
	data := c rows.
	db
		execute:
			'UPDATE tests
SET status = 1
	extra = ?
WHERE status = 0 and rowid <= ?'
		value: DateAndTime now asUnixTime asString
		value: (data last at: #rowid) ]
		ensure: [ db close ].
	^ data

]

{ #category : #'as yet unclassified' }
PzSqliteDb >> getDb [
	^ SQLite3Connection
				on: (Smalltalk imageDirectory / 'phazzer.db') fullName 
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> initDb [
	self createTableTests .
	self createTableGlobals 
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
			'UPDATE tests
SET status = 3
	extra = nil
WHERE status = 2 and baseClass = ? and testMethod = ?'
		value: aTestCase class superclass name
		value: aTestCase selector asString ]
		ensure: [ db close ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> logTestStart: aTestCase [
	| db  |
	db := self getDb.
	db open.
	[ db
		execute:
			'UPDATE tests
SET status = 2
	extra = nil
WHERE status = 1 and baseClass = ? and testMethod = ?'
		value: aTestCase  class superclass name
		value: aTestCase selector asString]
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
	| db |
	db := self getDb.
	db open.
	[ sourceCodes
		do: [ :sourceCode | 
			
			db
				execute:
					'INSERT INTO tests(baseClass,testMethod,status) VALUES (:baseClass,:method,:status);'
				with:
					{(':baseClass' -> class name).
					(':method' -> sourceCode).
					(':status' -> 0)} asDictionary ] ]
		ensure: [ db close ]
]
