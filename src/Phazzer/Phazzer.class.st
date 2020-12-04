Class {
	#name : #Phazzer,
	#superclass : #Object,
	#instVars : [
		'config',
		'process',
		'sandbox_image'
	],
	#category : #Phazzer
}

{ #category : #'as yet unclassified' }
Phazzer class >> runAllInstalled [
	^ self new
		runAllInstalled
]

{ #category : #accessing }
Phazzer >> config: aConfig [
	config:= aConfig
]

{ #category : #'as yet unclassified' }
Phazzer >> continueCondition [
	| fileContent lastLine time |
	self sandBoxedSharedfileName exists
		ifFalse: [ ^ false ].
	fileContent := self sandBoxedSharedfileName contents
		splitOn: String cr.
	fileContent size < 2
		ifTrue: [ ^ false ].
	lastLine := fileContent at: fileContent size - 1.
	time := Time fromString: ((lastLine splitOn: ',') at: 1).
	^ (Time now subtractTime: time) asSeconds > config freezeTimeOut
]

{ #category : #'as yet unclassified' }
Phazzer >> eventForTestAnnouncement [
	| str |
	^ [ :x | 
	str := ','
		join:
			{Time nowUTC print24.
			x test class name.
			x test selector}.
	self sandBoxedSharedfileName writeStream
		setToEnd;
		nextPutAll: str;
		cr;
		close ]
]

{ #category : #accessing }
Phazzer >> initialize [
	config := PzConfig new
]

{ #category : #'as yet unclassified' }
Phazzer >> inputAmplify: aTestMethod selector: selector [
	| res |
	res := OrderedCollection new.
	config amps
		do:
			[ :amp | res addAll: ((amp initializeWith: config) inputAmplify: aTestMethod) ]
		displayingProgress: 'Input Amplifying: ' , selector.
	^ res
]

{ #category : #'as yet unclassified' }
Phazzer >> install: testMethods base: aTestClass [
	"installs test methods on fake test classes.
	 returns the list of fake test classes"

	| tc |
	tc := self tools buildTestClassWith: testMethods using: aTestClass.
	^ {tc}
]

{ #category : #accessing }
Phazzer >> intialize [
	config := PzConfig 
]

{ #category : #'as yet unclassified' }
Phazzer >> phazzClass: class [
	self processTestClass: class.
	self run
]

{ #category : #'as yet unclassified' }
Phazzer >> phazzMehtod: method [
	self processTestMethod: method.
	self run
]

{ #category : #'as yet unclassified' }
Phazzer >> phazzPackage: package [
	self processPackage: package.
	self run
]

{ #category : #'as yet unclassified' }
Phazzer >> processPackage: package [
	(package definedClasses select: [ :cls | cls isTestCase ])
		do: [ :cls | self processTestClass: cls ]
		displayingProgress: 'Package ', package name
]

{ #category : #'as yet unclassified' }
Phazzer >> processTestClass: aTestClass [
	aTestClass allTestSelectors
		do:
			[ :selector | self processTestMethod: (aTestClass lookupSelector: selector) ]
				displayingProgress: 'Class ' , aTestClass name
]

{ #category : #'as yet unclassified' }
Phazzer >> processTestMethod: aTestMethod [
	| t ts |
	t := self removeAssertions: aTestMethod.
	ts := self inputAmplify: t selector: aTestMethod selector.
	self install: ts base: aTestMethod methodClass
]

{ #category : #'as yet unclassified' }
Phazzer >> removeAssertions: aTestMethod [
	^ (PzAssertTransform transformAllAsserts: aTestMethod ast) formattedCode 
]

{ #category : #'as yet unclassified' }
Phazzer >> removeFinishedTests [
	| line |
	self sandBoxedSharedfileName contents
		splitOn: String cr
		do: [ :x | 
			line := x splitOn: ','.
			self tools removeSelector: (line at: 3) inClass: (line at: 2) ]
]

{ #category : #'as yet unclassified' }
Phazzer >> run [
	config sandbox
		ifTrue: [ self runSandBoxed ]
		ifFalse: [ self runAllInstalled ]
]

{ #category : #'as yet unclassified' }
Phazzer >> runAllInstalled [
	| testClasses ts |
	testClasses := (self tools defaultTempPackage
		asPackageIfAbsent: [ self error: 'No test in queue' ]) classes.
	testClasses
		do: [ :cls | 
			ts := cls buildSuite.
			ts when: TestAnnouncement do: self eventForTestAnnouncement.
			[ ts := ts run ]
				on: Exception
				do: [ :x | 
					x isResumable
						ifTrue: [ x resume ].
					nil ] ]
		displayingProgress: 'Test classes'
]

{ #category : #'as yet unclassified' }
Phazzer >> runSandBoxed [
	^ self runSandboxedWithPriority: nil
]

{ #category : #'as yet unclassified' }
Phazzer >> runSandboxedNotUIThread [
	^ self runSandboxedWithPriority: Processor activePriority - 1
]

{ #category : #'as yet unclassified' }
Phazzer >> runSandboxedWithPriority: priority [
	| block master_image |
	master_image := FileLocator image pathString.
	sandbox_image := FileLocator imageDirectory pathString , '/sandbox'.
	FileLocator image pathString = sandbox_image
		ifTrue: [ ^ self ].
	self sandBoxedSharedfileName exists
		ifTrue:
			[ self sandBoxedSharedfileName delete ].
	Smalltalk backupTo: sandbox_image.
	block := [ self
		startSandboxAndWatchOnFinish: self sandboxOnFinishOrCrash ].
	FileLocator image pathString = master_image
		ifTrue:
			[ priority ifNil: [ block value ] ifNotNil: [ block forkAt: priority ] ]
]

{ #category : #'as yet unclassified' }
Phazzer >> sandBoxedSharedfileName [
	^ (FileLocator imageDirectory
		/ config sandBoxedSharedfileName) asFileReference
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxOnFinishOrCrash [
	^ [ self removeFinishedTests.
		self flag: #todo.
		"if there is any test left, restart sandbox"
		
		 ]
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxStartCommand [
	[ process := OSSUnixSubprocess new
		command: FileLocator vmBinary pathString;
		arguments:
			{'--headless'.
			(sandbox_image , '.image').
			PzCommandLineHandler commandName.
			'--run'} ].
	process := OSSUnixSubprocess new
		command: FileLocator vmBinary pathString;
		arguments:
			{(sandbox_image , '.image').
			PzCommandLineHandler commandName.
			'--run'};
		runAndWait
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxStopCommand [
	process sigterm 
]

{ #category : #'as yet unclassified' }
Phazzer >> startSandboxAndWatchOnFinish: aBlock [
	| delay semaphorExecutor executor watcher |
	delay := config freezeTimeOut seconds asDelay.
	semaphorExecutor := Semaphore new.
	executor := [ [ [ self sandboxStartCommand.
	semaphorExecutor signal ]
		ensure: [ executor := nil.
			delay delaySemaphore signal ] ]
		on: Error
		do: [ :ex | 
			self sandboxStopCommand.
			semaphorExecutor signal ] ] newProcess.
	watcher := [ | goOn |
	goOn := true.
	[ goOn ]
		whileTrue: [ self continueCondition
				ifTrue: [ executor ifNotNil: [ executor signalException: Error new ].
					goOn := false ]
				ifFalse: [ delay := config freezeTimeOut seconds asDelay..delay wait ] ] ] newProcess.
	watcher priority: executor priority + 1.
	watcher resume.
	executor resume.
	semaphorExecutor wait.
	aBlock value
]

{ #category : #accessing }
Phazzer >> tools [
	^ PzTools new
]
