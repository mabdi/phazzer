Class {
	#name : #PzLinuxFileSystemDb,
	#superclass : #PzDb,
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb class >> stateForCreated [ 
	^ 'created'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb class >> stateForFinished [
	^ 'finished'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb class >> stateForInstalled [
	^ 'installed'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb class >> stateForProcessed [
	^ 'processed'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb class >> stateForStarted [ 
	^ 'started'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> anyUnFinishedLeft [
	| ls |
	ls := (self
		system: 'ls ' , dbName , '/tests/' , self class stateForCreated)
		.
	ls ifNotEmpty: [ ^ true ].
	ls := (self
		system: 'ls ' , dbName , '/tests/' , self class stateForStarted)
		.
	ls ifNotEmpty: [ ^ true ].
	ls := (self
		system: 'ls ' , dbName , '/tests/' , self class stateForInstalled)
		.
	ls ifNotEmpty: [ ^ true ].
	^ false
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> checkClassIsProcessed: aTestClass [
	| ls |
	ls := self
		system:
			'ls ' , dbName , '/tests/' , self class stateForCreated , '/'
				, aTestClass name , '*'.
	ls ifNotEmpty: [ ^ true ].
	ls := self
		system:
			'ls ' , dbName , '/tests/' , self class stateForFinished , '/'
				, aTestClass name , '*'.
	ls ifNotEmpty: [ ^ true ].
	ls := self
		system:
			'ls ' , dbName , '/tests/' , self class stateForProcessed , '/'
				, aTestClass name , '*'.
	ls ifNotEmpty: [ ^ true ].
	
	^ false
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> fetchTests: aNumber [
	| ls results |
	ls := (self
		system:
			'ls ' , dbName , '/tests/' , self class stateForCreated , ' | head -'
				, aNumber asString) lines.
	results := ls collect: [ :line | self lineAsObjectFile: line state: self class stateForCreated  ].
	^ results
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> flagAllInstalledAsCreated [
	self system: 'mv ' , dbName , '/tests/' , self class stateForInstalled  , '/* ' , dbName , '/tests/' , self class stateForCreated, '/' 
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> flagAsCreated: rowId [
	self
		system:
			'mv ' , dbName , '/tests/' , rowId , ' ' , dbName , '/tests/'
				, self class stateForCreated , '/'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> flagAsProcessed: rowId [

	self
		system:
			'mv ' , dbName , '/tests/' , rowId , ' ' , dbName
				, '/tests/' , self class stateForProcessed  , '/'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> getAllState: state [
	| ls results |
	ls := (self
		system: 'ls ' , dbName , '/tests/' , state)
		lines.
	results := ls
		collect:
			[ :line | self lineAsObjectFile: line state: state ].
	^ results
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> getNotFinished [
	^ self getAllState: self class stateForStarted
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> idColumn [
	^ #_fileId
]

{ #category : #state }
PzLinuxFileSystemDb >> initDb [
	self system: 'mkdir ' , dbName.
	self system: 'mkdir ' , dbName , '/tests'.
	self
		system: 'mkdir ' , dbName , '/tests/' , self class stateForCreated.
	self
		system: 'mkdir ' , dbName , '/tests/' , self class stateForFinished.
	self
		system: 'mkdir ' , dbName , '/tests/' , self class stateForInstalled.
	self
		system: 'mkdir ' , dbName , '/tests/' , self class stateForProcessed.
	self
		system: 'mkdir ' , dbName , '/tests/' , self class stateForStarted.
	self system: 'mkdir ' , dbName , '/globals'
]

{ #category : #'private - uffi' }
PzLinuxFileSystemDb >> insertTestmethod: sourceCode selector: selector base: class [
	self
		writeFile:
			(self nameForBase: class name  selector:  selector )
		content: sourceCode
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> lastUpdate [
	| s file |
	file := (FileLocator imageDirectory / dbName / 'globals' / 'lastUpdate.conf').
	file exists ifFalse: [ ^ 0 ].
	s := file asFileReference contents.
	s ifEmpty: [ ^ 0 ].
	^ s asInteger 
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> lineAsObjectFile: name state: state [
	| res |
	res := Dictionary new.
	res at: #content put: (self readFile: name state: state).
	res at: #status put: state.
	res at: #baseClass put: ((name splitOn: '.') at: 1).
	res at: #testMethod put: ((name splitOn: '.') at: 2).
	res at: self idColumn put: (state , '/', name).
	^ res
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> logAnUpdate [
	(FileLocator imageDirectory / dbName / 'globals' / 'lastUpdate.conf')
		writeStream
		nextPutAll: DateAndTime now asUnixTime asString;
		close
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> logTestFinished: aTestCase [
	self
		system:
			'mv ' , dbName , '/tests/' , self class stateForStarted , '/'
				,
					(self
						nameForBase: aTestCase class superclass name
						selector: aTestCase selector asString) , ' ' , dbName
				, '/tests/' , self class stateForFinished , '/'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> logTestStart: aTestCase [
	(aTestCase selector asString includesSubstring: '27')
		ifTrue: [ self halt ].
	self
		system:
			'mv ' , dbName , '/tests/' , self class stateForCreated , '/'
				,
					(self
						nameForBase: aTestCase class superclass name
						selector: aTestCase selector asString) , ' ' , dbName
				, '/tests/' , self class stateForStarted , '/'
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> nameForBase: basename selector: selector [
	^ ''
				join:
					{basename.
					'.'.
					selector asString.
					'.st'}
]

{ #category : #state }
PzLinuxFileSystemDb >> purgeDb [
	self system: 'rm -rf ' , dbName.
	
]

{ #category : #'private - uffi' }
PzLinuxFileSystemDb >> readFile: name [
	^ (FileLocator imageDirectory / dbName / 'tests'
		/ self class stateForCreated / name) asFileReference contents
]

{ #category : #'private - uffi' }
PzLinuxFileSystemDb >> readFile: name state: state [
	^ (FileLocator imageDirectory / dbName / 'tests' / state / name)
		asFileReference contents
]

{ #category : #'as yet unclassified' }
PzLinuxFileSystemDb >> resetLastUpdate [
	
	(FileLocator imageDirectory / dbName / 'globals' / 'lastUpdate.conf')
		writeStream
		nextPutAll: '0';
		close
]

{ #category : #'private - uffi' }
PzLinuxFileSystemDb >> system: aString [
	^ OSPlatform current
		resultOfCommand:
			(''
				join:
					{'cd '.
					(FileLocator imageDirectory) fullName . '; ' . aString})
]

{ #category : #'private - uffi' }
PzLinuxFileSystemDb >> writeFile: name content: aString [
	(FileLocator imageDirectory / dbName / 'tests' / self class stateForCreated  / name) writeStream
		nextPutAll: aString;
		close
]
