Class {
	#name : #PzSqliteDb,
	#superclass : #Object,
	#instVars : [
		'dbName',
		'openInstance'
	],
	#category : #Phazzer
}

{ #category : #accessing }
PzSqliteDb class >> named: aName [
	^ self new
		dbName: aName;
		initDb;
		yourself
]

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
PzSqliteDb >> anyUnFinishedLeft [
	^ self
		execDb: [ :db | 
			(db
				execute: 'select * from tests where status not in (?, ?)'
				with:
					{self class stateForFinished.
					self class stateForProcessed}) rows isNotEmpty ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> checkClassIsProcessed: aTestClass [
	| cursor |
	^ self
		execDb: [ :db | cursor := db
		execute: 'select count(*) as count from tests where baseClass = ?'
		value: aTestClass name.
	(cursor next at: #count) = 0 ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> createTableGlobals [
	^ self
		execDb: [ :db | db
		execute:
			'CREATE TABLE IF NOT EXISTS globals (
	key TEXT NOT NULL UNIQUE,
	value TEXT NOT NULL
);'.
	db
		execute: 'INSERT OR IGNORE  INTO globals(key,value) VALUES ("lastUpdate", 0);' ]
		
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> createTableTests [
	^ self
		execDb: [ :db | db
		execute:
			'CREATE TABLE IF NOT EXISTS tests (
	baseClass TEXT NOT NULL,
	selector TEXT NOT NULL,
	testMethod TEXT NOT NULL,
	status INTEGER NOT NULL,
	extra TEXT
);' ]

]

{ #category : #'as yet unclassified' }
PzSqliteDb >> dbName: aName [
	dbName := aName
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> execDb: aBlock [
	| db |
	db := self getDb.
	^ [ aBlock value: db ]
	on: Error do: [ openInstance := nil ]
]

{ #category : #accessing }
PzSqliteDb >> fetchTests: aNumber [
	| c data |
	data := nil.
	^ self
		execDb: [ :db | 
			c := db
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
						value: (data last at: #rowid) ].
				data ].
	
]

{ #category : #accessing }
PzSqliteDb >> flagAllInstalledAsCreated [
	^ self
		execDb: [ :db | 
	 db
		execute: 'UPDATE tests SET status = ? WHERE status = ?'
		value: self class stateForCreated
		value: self class stateForInstalled ]
		
]

{ #category : #accessing }
PzSqliteDb >> flagAsCreated: rowId [
^ self
		execDb: [ :db | db
		execute: 'UPDATE tests SET status = ? WHERE rowid = ?'
		value: self class stateForCreated
		value: rowId ]
]

{ #category : #accessing }
PzSqliteDb >> flagAsProcessed: rowId [
	^ self
		execDb: [ :db | db
		execute: 'UPDATE tests SET status = ? WHERE rowid = ?'
		value: self class stateForProcessed
		value: rowId ]
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> forceClose: db [
	| dbHandle library |
	"dbHandle := db handle.
	library := SQLite3Library current.
	dbHandle ifNotNil: [ library close: dbHandle ]"
	
	"do nothing!"
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> getDb [
	openInstance
		ifNil: [ openInstance := SQLite3Connection
				on: (Smalltalk imageDirectory / dbName) fullName. openInstance open. ].
	
	^ openInstance
]

{ #category : #accessing }
PzSqliteDb >> getNotFinished [
	| c |
	^ self
		execDb: [ :db | 
	 c := db
		execute:
			'SELECT rowid, baseClass, testMethod, selector, status
                   FROM tests
                   WHERE status = ?'
		value: self class stateForStarted.
	c rows ]
		
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
PzSqliteDb >> insertTestmethod: sourceCode selector: selector base: class [
	^ self
		execDb: [ :db | 
	 
	db
		execute:
			'INSERT INTO tests(baseClass,selector,testMethod,status) VALUES (:baseClass,:selector,:method,:status);'
		with:
			{(':baseClass' -> class name).
			(':selector' -> selector).
			(':method' -> sourceCode).
			(':status' -> self class stateForCreated)} asDictionary ]
		
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> lastUpdate [
	|  c data |
	^ self
		execDb: [ :db | 
	c := db
		execute:
			'select value from globals
WHERE key = "lastUpdate"'.
	data := c rows.
	data ifEmpty: [ ^ 0 ].
	((data at: 1) at: #value) asInteger ]
		.
	
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> logAnUpdate [
	^ self
		execDb: [ :db |  db
		execute:
			'UPDATE globals
SET value = ?
WHERE key = "lastUpdate"'
		value: DateAndTime now asUnixTime ]
		
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> logTestFinished: aTestCase [
	^ self
		execDb: [ :db | db
		execute:
			'UPDATE tests SET status = ?
WHERE status = ? and baseClass = ? and selector = ?'
		with:
			{self class stateForFinished.
			self class stateForStarted.
			aTestCase class superclass name.
			aTestCase selector asString} ]
		
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> logTestStart: aTestCase [
	^ self
		execDb: [ :db |  db
		execute:
			'UPDATE tests
SET status = ?
WHERE status = ? and baseClass = ? and selector = ?'
		with:
			{self class stateForStarted.
			self class stateForInstalled.
			aTestCase class superclass name.
			aTestCase selector asString} ]
		
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> purgeDb [
	^ self
		execDb: [ :db | 
	 db execute: 'DROP TABLE IF EXISTS tests;'.
	db execute: 'DROP TABLE IF EXISTS globals;' ]
		
]

{ #category : #'as yet unclassified' }
PzSqliteDb >> resetLastUpdate [
	^ self
		execDb: [ :db |  db
		execute:
			'UPDATE globals
SET value = 0
WHERE key = "lastUpdate"' ]

]
