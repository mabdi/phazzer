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

{ #category : #structure }
Phazzer class >> hackThePlanet [
| pz |
	pz := self new.
	RPackage organizer packages
		do: [ :p | pz phazzPackage: p ]
		displayingProgress: [ :p | 'Phazzing all image: ' , p name ]
]

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

{ #category : #initialization }
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

{ #category : #'as yet unclassified' }
Phazzer >> phazzClass: class [
	self processTestClass: class.
	self run
]

{ #category : #'as yet unclassified' }
Phazzer >> phazzMethod: method [
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
	| lines started |
	lines := ((self sandBoxedSharedfileName contents splitOn: String cr)
		reject: #isEmpty) collect: [ :x | x splitOn: ',' ].
	started := (lines select: [ :l | (l at: 4) = PzTools startedTag ])
		collect: [ :l | 
			{(l at: 2).
			(l at: 3)} ].
	(lines select: [ :l | (l at: 4) = PzTools finishedTag ])
		do: [ :l | 
			started
				remove:
					{(l at: 2).
					(l at: 3)}.
			self tools removeSelector: (l at: 3) inClass: (l at: 2) ].
	started
		do: [ :l | 
			self tools moveToFinalSelector: (l at: 2) inClass: (l at: 1).
			self tools removeSelector: (l at: 2) inClass: (l at: 1) ]
]

{ #category : #'as yet unclassified' }
Phazzer >> requiresToStopSandbox [
	| fileContent lines lastLine time noUpdates |
	self sandBoxedSharedfileName exists
		ifFalse: [ ^ false ].
	fileContent := self sandBoxedSharedfileName.
	fileContent ifNil: [ ^ false ].
	lines := fileContent contents splitOn: String cr.
	lines ifNil: [ ^ false ].
	lines size < 2
		ifTrue: [ ^ false ].
	lastLine := lines at: lines size - 1.
	time := Time fromString: ((lastLine splitOn: ',') at: 1).
	noUpdates := (Time now subtractTime: time) asSeconds.
	('noUpdates: ' , noUpdates asString , '') traceCr.
	^ noUpdates > config freezeTimeOut
]

{ #category : #'as yet unclassified' }
Phazzer >> run [
	| tempPackage |
	tempPackage := self tools defaultTempPackage
		asPackageIfAbsent: [ ^ self ].
	tempPackage classes ifEmpty: [^ self].
	config sandbox
		ifTrue: [ self runSandboxedNotUIThread ]
		ifFalse: [ self runAllInstalled ]
]

{ #category : #'as yet unclassified' }
Phazzer >> runAllInstalled [
	| testClasses ts |
	testClasses := (self tools defaultTempPackage
		asPackageIfAbsent: [ self error: 'No test in queue' ]) classes.
	testClasses
		do: [ :cls | 
			cls sandBoxedSharedfileName: self sandBoxedSharedfileName.
			ts := cls buildSuite.
			"ts when: TestAnnouncement do: self eventForTestAnnouncement."
			[ ts := ts run ]
				on: Exception
				do: [ :x | 
					x isResumable
						ifTrue: [ x resume ].
					nil ] ]
		displayingProgress: 'Test classes'.
	
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
	| master_image |
	master_image := FileLocator image pathString.
	self sandboxInit.
	FileLocator image pathString = master_image
		ifTrue: [ self
				startSandboxAndWatchPriority: priority
				OnFinish: self sandboxOnFinishOrCrash ].
	self flag: #todo. "we need to kill the rest of the process in the forked process (sandbox)"
]

{ #category : #'as yet unclassified' }
Phazzer >> sandBoxedSharedfileName [
	^ (FileLocator imageDirectory / config sandboxSharedFile)
		asFileReference
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxInit [
	sandbox_image := FileLocator imageDirectory pathString , '/sandbox'.
	self sandBoxedSharedfileName exists
		ifTrue: [ self sandBoxedSharedfileName delete ].
	self sandBoxedSharedfileName writeStream close.
	Smalltalk backupTo: sandbox_image
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxOnFinishOrCrash [
	| testClasses |
	^ [ self removeFinishedTests.
	testClasses := (self tools defaultTempPackage
		asPackageIfAbsent: [ self error: 'No test in queue' ]) classes.
	(testClasses anySatisfy: [ :cls | cls testSelectors isNotEmpty ])
		ifTrue: [ self run ] ]
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
			'--run'}.
	process runAndWait
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxStopCommand [
	('killing pid: ' , process pid asString) traceCr.
	process sigterm
]

{ #category : #'as yet unclassified' }
Phazzer >> startSandboxAndWatchPriority: priority OnFinish: aBlock [
	| delay semaphorExecutor executor watcher |
	delay := 1 seconds asDelay.
	semaphorExecutor := Semaphore new.
	executor := [ [ [ self sandboxStartCommand ]
		ensure: [ executor := nil.
			delay delaySemaphore signal.
			semaphorExecutor signal ] ]
		on: Error
		do: [ :ex | 
			'killing executor' traceCr.
			self sandboxStopCommand.
			semaphorExecutor signal ] ] newProcess.
	executor priority: priority.
	watcher := [ | goOn |
	goOn := true.
	[ goOn ]
		whileTrue: [ self requiresToStopSandbox
				ifTrue: [ executor ifNotNil: [ executor signalException: Error new ].
					goOn := false ]
				ifFalse: [ delay := 1 seconds asDelay.
					delay wait ] ] ] newProcess.
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
