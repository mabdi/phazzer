Class {
	#name : #PzMongoDbTest,
	#superclass : #TestCase,
	#instVars : [
		'db'
	],
	#category : #'Phazzer-Tests'
}

{ #category : #'as yet unclassified' }
PzMongoDbTest >> buildFakeTest: fakeTest [
	^ PzTools new buildTestClassWith: {fakeTest} using: PzFakeTest
]

{ #category : #'as yet unclassified' }
PzMongoDbTest >> getRow: testMethod [
	| tests row |
	tests := db getTests.
	row := tests select: {(#testMethod -> testMethod)} asDictionary.
	^ row 
]

{ #category : #running }
PzMongoDbTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	db := PzMongoDb named:self class name.
	db purgeDb.
	db initDb
]

{ #category : #running }
PzMongoDbTest >> tearDown [
	db purgeDb.
	db  close.
	PzTools new clearTempClasses
]

{ #category : #test }
PzMongoDbTest >> testFlagAllInstalledAsCreated [
	| fakeTest c t row |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	row := db getNotFinished.
	self assertEmpty: row.
	db flagAllInstalledAsCreated.
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForCreated
]

{ #category : #test }
PzMongoDbTest >> testFlagAsProcessed [
	| fakeTest c t row |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	row := db getNotFinished.
	db flagAsProcessed: (row first at: db idColumn).
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForProcessed
]

{ #category : #test }
PzMongoDbTest >> testLastUpdate [
	self assert: db lastUpdate asInteger equals: 0.
	db logAnUpdate.
	self deny: db lastUpdate asInteger equals: 0.
]

{ #category : #tests }
PzMongoDbTest >> testMethodAdd [
	| row fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForCreated
]

{ #category : #tests }
PzMongoDbTest >> testMethodFinished [
	| row c t fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
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
PzMongoDbTest >> testMethodInstall [
	| row fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForInstalled
]

{ #category : #tests }
PzMongoDbTest >> testMethodNotFinished [
	| row c t fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
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
PzMongoDbTest >> testMethodStart [
	| row c t fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	row := self getRow: fakeTest.
	self
		assert: (row first at: #status) asInteger
		equals: PzSqliteDb stateForStarted
]
