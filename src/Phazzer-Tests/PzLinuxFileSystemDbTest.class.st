Class {
	#name : #PzLinuxFileSystemDbTest,
	#superclass : #TestCase,
	#instVars : [
		'db'
	],
	#category : #'Phazzer-Tests'
}

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDbTest >> buildFakeTest: fakeTest [
	^ PzTools new buildTestClassWith: {fakeTest} using: PzFakeTest
]

{ #category : #running }
PzLinuxFileSystemDbTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	db := PzLinuxFileSystemDb named: self class name.
	db purgeDb.
	db initDb
]

{ #category : #running }
PzLinuxFileSystemDbTest >> tearDown [
	db purgeDb.
	PzTools new clearTempClasses
]

{ #category : #test }
PzLinuxFileSystemDbTest >> testFlagAllInstalledAsCreated [
	| fakeTest c t row |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	row := db getNotFinished.
	self assertEmpty: row.
	db flagAllInstalledAsCreated.
	self
		denyEmpty: (db getAllState: PzLinuxFileSystemDb stateForCreated)
]

{ #category : #test }
PzLinuxFileSystemDbTest >> testFlagAsProcessed [
	| fakeTest c t row |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	row := db getNotFinished.
	db flagAsProcessed: (row first at: db idColumn).
	self denyEmpty: (db getAllState: PzLinuxFileSystemDb stateForProcessed)
	
]

{ #category : #test }
PzLinuxFileSystemDbTest >> testLastUpdate [
	self assert: db lastUpdate asInteger equals: 0.
	db logAnUpdate.
	self deny: db lastUpdate asInteger equals: 0.
]

{ #category : #tests }
PzLinuxFileSystemDbTest >> testMethodAdd [
	| fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	self denyEmpty: (db getAllState: PzLinuxFileSystemDb stateForCreated)
]

{ #category : #tests }
PzLinuxFileSystemDbTest >> testMethodFinished [
	| row c t fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	db logTestFinished: t.
	self
		denyEmpty: (db getAllState: PzLinuxFileSystemDb stateForFinished ) 
]

{ #category : #tests }
PzLinuxFileSystemDbTest >> testMethodInstall [
	| fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	self
		denyEmpty: (db getAllState: PzLinuxFileSystemDb stateForInstalled)
]

{ #category : #tests }
PzLinuxFileSystemDbTest >> testMethodNotFinished [
	| c t fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	self
		denyEmpty: (db getAllState: PzLinuxFileSystemDb stateForStarted)
]

{ #category : #tests }
PzLinuxFileSystemDbTest >> testMethodStart [
	| c t fakeTest |
	fakeTest := 'test1 1+1'.
	db insertTestmethod: fakeTest selector: #test1 base: PzFakeTest.
	db fetchTests: 10.
	c := self buildFakeTest: fakeTest.
	t := c selector: #test1.
	db logTestStart: t.
	self
		denyEmpty: (db getAllState: PzLinuxFileSystemDb stateForStarted)
]
