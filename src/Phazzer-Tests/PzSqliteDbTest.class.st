"
A PzSqliteDbTest is a test class for testing the behavior of PzSqliteDb
"
Class {
	#name : #PzSqliteDbTest,
	#superclass : #TestCase,
	#instVars : [
		'db'
	],
	#category : #'Phazzer-Tests'
}

{ #category : #'as yet unclassified' }
PzSqliteDbTest >> buildFakeTest: fakeTest [
	^ PzTools new buildTestClassWith: {fakeTest} using: PzFakeTest
]

{ #category : #'as yet unclassified' }
PzSqliteDbTest >> getRow: testMethod [
	| sqlite row |
	sqlite := db getDb.
	sqlite open.
	row := (sqlite
		execute: 'select * from tests where testMethod = ?'
		value: testMethod) rows.
	sqlite close.
	^ row 
]

{ #category : #running }
PzSqliteDbTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	db := PzSqliteDb new.
	db dbName: 'TestDb.db'.
	db purgeDb.
	db initDb
]

{ #category : #running }
PzSqliteDbTest >> tearDown [
	db purgeDb
	
]

{ #category : #test }
PzSqliteDbTest >> testFlagAllInstalledAsCreated [
		| fakeTest c t row |
	fakeTest := 'test1 1+1'.
	db stashTestmethod: {fakeTest} base: PzFakeTest.
	db fetchTests: 10.
	row := db getNotFinished.
	self
		assertEmpty: row.
	db flagAllInstalledAsCreated.
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForCreated 
]

{ #category : #test }
PzSqliteDbTest >> testFlagAsProcessed [
	| fakeTest c t row |
	fakeTest := 'test1 1+1'.
	db stashTestmethod: {fakeTest} base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	row := db getNotFinished.
	db flagAsProcessed: (row first at: #rowid).
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForProcessed
]

{ #category : #test }
PzSqliteDbTest >> testLastUpdate [
	self assert: db lastUpdate asInteger equals: 0.
	db logAnUpdate.
	self deny: db lastUpdate asInteger equals: 0.
]

{ #category : #tests }
PzSqliteDbTest >> testMethodAdd [
	| row fakeTest |
	fakeTest := 'test1 1+1'.
	db stashTestmethod: {fakeTest} base: self class.
	row := self getRow: fakeTest.
	self assert: (row first at: #status) asInteger equals: PzSqliteDb stateForCreated
]

{ #category : #tests }
PzSqliteDbTest >> testMethodFinished [
	| row c t fakeTest |
	fakeTest := 'test1 1+1'.
	db stashTestmethod: {fakeTest} base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	db logTestFinished: t.
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForFinished 
]

{ #category : #tests }
PzSqliteDbTest >> testMethodInstall [
	| row fakeTest |
	fakeTest := 'test1 1+1'.
	db stashTestmethod: {fakeTest} base: self class.
	db fetchTests: 10.
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForInstalled 
]

{ #category : #tests }
PzSqliteDbTest >> testMethodNotFinished [
	| row c t fakeTest |
	fakeTest := 'test1 1+1'.
	db stashTestmethod: {fakeTest} base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	row := db getNotFinished.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForStarted
]

{ #category : #tests }
PzSqliteDbTest >> testMethodStart [
	| row c t fakeTest |
	fakeTest := 'test1 1+1'.
	db stashTestmethod: {fakeTest} base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForStarted
]
