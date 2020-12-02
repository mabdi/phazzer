Class {
	#name : #Phazzer,
	#superclass : #Object,
	#instVars : [
		'config'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
Phazzer class >> defaultConfig [
	^ PzConfig new
]

{ #category : #'as yet unclassified' }
Phazzer class >> onMethod: aTestMethod [
	self flag: #todo.	"check isTestMethod"
	self new
		config: self defaultConfig;
		fuzzMethod: aTestMethod
]

{ #category : #'as yet unclassified' }
Phazzer class >> phazzImage [
	RPackage organizer packages do:  #phazz displayingProgress:  'Phazzing all image'
]

{ #category : #'as yet unclassified' }
Phazzer class >> phazzPackage: packageName [
	(RPackage organizer packageNamed: packageName) phazz
]

{ #category : #'as yet unclassified' }
Phazzer class >> runAllInstalled [
	self new
		config: self defaultConfig;
		runAllInstalled
]

{ #category : #accessing }
Phazzer >> config: aConfig [
	config:= aConfig
]

{ #category : #'as yet unclassified' }
Phazzer >> continueCondition [
	| lastLine time |
	lastLine := ((FileLocator imageDirectory
		/ self sandBoxedSharedfileName) asFileReference contents
		splitOn: String cr) last.
	time := Time fromString: ((lastLine splitOn: ',') at: 1).
  ^ 	(Time now subtractTime: time) asSeconds > config freezeTimeOut
]

{ #category : #'as yet unclassified' }
Phazzer >> eventForTestAnnouncement [
	| str |
	^ [ :x | 
	str := ':'
		join:
			{Time nowUTC print24.
			x test class name.
			x test selector}.
	Stdio stdout
		nextPutAll: str;
		lf;
		flush
		 ]
]

{ #category : #'as yet unclassified' }
Phazzer >> eventForTestAnnouncementSandBoxed [
	| str |
	^ [ :x | 
	str := ','
		join:
			{Time nowUTC print24.
			x test class name.
			x test selector}.
	(FileLocator imageDirectory / self sandBoxedSharedfileName)
		writeStream
		nextPutAll: str;
		cr;
		close ]
]

{ #category : #'as yet unclassified' }
Phazzer >> fuzzMethod: aTestMethod [
	| tr ts tc t |
	t := self removeAssertions: aTestMethod.
	ts := self inputAmplify: t.
	tc := self install: ts base: aTestMethod methodClass.
	tr := self run: tc.
	"self keepFailingTests: tr."
	PzTools new clearTempClasses
]

{ #category : #'as yet unclassified' }
Phazzer >> fuzzMethodSandBoxed: aTestMethod [
	| ts  t |
	t := self removeAssertions: aTestMethod.
	ts := self inputAmplify: t.
	self install: ts base: aTestMethod methodClass.
	self runInsideASandbox
]

{ #category : #'as yet unclassified' }
Phazzer >> inputAmplify: aTestMethod [
	self flag: #todo. "annotate generated test methods to trace how it is build"
	^ config amps
		flatCollect: [ :amp | (amp initializeWith: config) inputAmplify: aTestMethod ]
]

{ #category : #'as yet unclassified' }
Phazzer >> install: testMethods base: aTestClass [
	"installs test methods on fake test classes.
	 returns the list of fake test classes"

	| tc |
	self flag: #todo.	"paging"
	tc := self tools buildTestClassWith: testMethods using: aTestClass.
	^ {tc}
]

{ #category : #'as yet unclassified' }
Phazzer >> keepFailingTests: tr [
	(tr reject: [ :cls | cls value isEmpty ])
		do: [ :cls | 
			self tools
				buildFinalTestClassWith:
					(cls value
						collect: [ :tc | (tc class lookupSelector: tc selector) sourceCode ])
				using: cls key superclass ]
]

{ #category : #'as yet unclassified' }
Phazzer >> removeAssertions: aTestMethod [
	^ (PzAssertTransform transformAllAsserts: aTestMethod ast) formattedCode 
]

{ #category : #'as yet unclassified' }
Phazzer >> removeFinishedTests [
		| line |
	^ [ (FileLocator imageDirectory / self sandBoxedSharedfileName)
				asFileReference contents
				splitOn: String cr
				do: [ :x | 
					line := x splitOn: ','.
					self tools removeSelector: (line at: 3) inClass: (line at: 2) ] ]
]

{ #category : #'as yet unclassified' }
Phazzer >> run: testClasses [
	| ts |
	^ (testClasses
		collect: [ :cls | 
			ts := cls buildSuite.
			ts when: TestAnnouncement do: self eventForTestAnnouncement.
			[ ts := ts run.
			cls -> ts defects ]
				on: Exception
				do: [ :x | x isResumable ifTrue: [ x resume ]. nil ] ]) reject: #isNil
]

{ #category : #'as yet unclassified' }
Phazzer >> runAllInstalled [
	| testClasses ts |
	testClasses := (self tools defaultTempPackage
		asPackageIfAbsent: [ self error: 'No test in queue' ]) classes.
	testClasses
		do: [ :cls | 
			ts := cls buildSuite.
			ts
				when: TestAnnouncement
				do: self eventForTestAnnouncementSandBoxed.
			[ ts := ts run ]
				on: Exception
				do: [ :x | 
					x isResumable
						ifTrue: [ x resume ].
					nil ] ]
]

{ #category : #'as yet unclassified' }
Phazzer >> runCommand [
	| cmd |
	cmd := String
		streamContents: [ :stream | 
			stream
				nextPutAll: FileLocator vmBinary pathString;
				nextPutAll: ' ';
				nextPutAll: FileLocator image pathString;
				nextPutAll: ' ';
				nextPutAll: PzCommandLineHandler commandName;
				nextPutAll: ' ';
				nextPutAll: '--run' ].
	OSPlatform current resultOfCommand: cmd.
	
]

{ #category : #'as yet unclassified' }
Phazzer >> runCommandAndWatchOnFinish: aBlock [
	| delay semaphorExecutor executor watcher |
	delay := config freezeTimeOut seconds asDelay.
	semaphorExecutor := Semaphore new.
	executor := [ [ [ self runCommand.
	semaphorExecutor signal ]
		ensure: [ executor := nil.
			delay delaySemaphore signal ] ]
		on: Error
		do: [ :ex | 
			self stopCommand.
			semaphorExecutor signal ] ] newProcess.
	watcher := [ | goOn |
	goOn := true.
	[ goOn ]
		whileTrue: [ self continueCondition
				ifTrue: [ executor ifNotNil: [ executor signalException: Error new ].
					goOn := false ]
				ifFalse: [ delay wait ] ] ] newProcess.
	watcher priority: executor priority + 1.
	watcher resume.
	executor resume.
	semaphorExecutor wait.
	aBlock value
]

{ #category : #'as yet unclassified' }
Phazzer >> runInsideASandbox [
	(FileLocator imageDirectory / self sandBoxedSharedfileName) exists
		ifTrue: [ (FileLocator imageDirectory / self sandBoxedSharedfileName) delete ].
	[ self runCommandAndWatchOnFinish: self removeFinishedTests ]
		forkAt: Processor activePriority - 1
]

{ #category : #'as yet unclassified' }
Phazzer >> sandBoxedSharedfileName [
	^ 'sandbox-done-tests.txt'
]

{ #category : #'as yet unclassified' }
Phazzer >> stopCommand [
]

{ #category : #accessing }
Phazzer >> tools [
	^ PzTools new
]
