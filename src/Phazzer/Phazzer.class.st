Class {
	#name : #Phazzer,
	#superclass : #Object,
	#instVars : [
		'config',
		'process',
		'sandbox_image',
		'db'
	],
	#category : #Phazzer
}

{ #category : #structure }
Phazzer class >> amplifyAll [
	| pz |
	pz := self new.
	RPackage organizer packages
		do: [ :p | pz processPackage: p ]
		displayingProgress: [ :p | 'Amplification package: ' , p name ]
]

{ #category : #structure }
Phazzer class >> amplifyFile: file [
	| pz lines |
	pz := self new.
	pz tic.
	lines := file asFileReference contents lines.
	(lines collect: #asPackage)
		do: [ :p | pz processPackage: p ]
		displayingProgress: [ :p | 'Amplification package: ' , p name ]
]

{ #category : #'as yet unclassified' }
Phazzer class >> dbClass [
	^ PzLinuxFileSystemDb
]

{ #category : #structure }
Phazzer class >> hackThePlanet [
	self amplifyAll.
	self runAll 
]

{ #category : #structure }
Phazzer class >> hackThePlanetFile: fileName [
	self amplifyFile: fileName.
	self runAll
]

{ #category : #structure }
Phazzer class >> runAll [
	| pz |
	pz := self new.
	pz run.
	pz toc
]

{ #category : #'as yet unclassified' }
Phazzer class >> runAllInstalled [
	^ self new
		runAllInstalled
]

{ #category : #'as yet unclassified' }
Phazzer class >> runInSandbox [
	^ self new runInSandbox
]

{ #category : #'as yet unclassified' }
Phazzer class >> runInSandbox: dbName [
	| cnf |
	cnf := PzConfig new.
	cnf dbName: dbName.
	^ self new
		config: cnf;
		runInSandbox
]

{ #category : #accessing }
Phazzer >> config: aConfig [
	config := aConfig.
	self initDb
]

{ #category : #accessing }
Phazzer >> db [ 
	^ db
]

{ #category : #finalization }
Phazzer >> finalize [
	db close
]

{ #category : #state }
Phazzer >> initDb [
	db := self class dbClass named: config dbName
]

{ #category : #initialization }
Phazzer >> initialize [
	self config: PzConfig new.
]

{ #category : #'as yet unclassified' }
Phazzer >> inputAmplify: aTestMethod profile: profile selector: selector [
	| res tmp theV |
	res := OrderedCollection new.
	theV := OrderedCollection with: aTestMethod.
	(1 to: config iterations)
		do: [ :gen | 
			theV
				do: [ :thisTestMethod | 
					config amps
						do: [ :amp | 
							tmp := (amp initializeWith: config)
								profile: profile;
								inputAmplify: thisTestMethod.
							tmp := (self reduceInputsForAmplifier: tmp).
							theV removeAll.
							theV addAll: tmp.
							res addAll: tmp ] ] ]
		displayingProgress: 'Input Amplifying: ' , selector.
	res := theV.
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
Phazzer >> installCount: aNumber [
	| data classes m |
	data := db fetchTests: aNumber.
	data ifNil: [ ^ 0 ].
	classes := Dictionary new.
	data
		do: [ :row | 
			m := classes
				at: (row at: #baseClass) asSymbol
				ifAbsentPut: [ OrderedCollection new ].
			m add: (row at: #testMethod) ].
	classes
		keysAndValuesDo:
			[ :key :value | self install: value base: (self class environment at: key) ].
	^ data size
]

{ #category : #'as yet unclassified' }
Phazzer >> logTestFinished: aTestCase [
	"self tools logTestFinished: aTestCase"

	db logTestFinished: aTestCase
]

{ #category : #'as yet unclassified' }
Phazzer >> logTestStart: aTestCase [
	"self tools logTestStart: aTestCase"

	db logTestStart: aTestCase.
	db logAnUpdate.
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
	({self class package name.
	#'Phazzer-Tests'.
	self tools defaultTempPackage.
	self tools defaultFinalPackage} includes: package name)
		ifTrue: [ ^ self ].
	(package definedClasses select: [ :cls | cls isTestCase ])
		do: [ :cls | self processTestClass: cls ]
		displayingProgress: 'Package ' , package name
]

{ #category : #'as yet unclassified' }
Phazzer >> processTestClass: aTestClass [
	(db checkClassIsProcessed: aTestClass)
		ifTrue: [ ^ self ].
	aTestClass allTestSelectors
		do:
			[ :selector | self processTestMethod: (aTestClass lookupSelector: selector) ]
		displayingProgress: 'Class ' , aTestClass name
]

{ #category : #'as yet unclassified' }
Phazzer >> processTestMethod: aTestMethod [
	| profile t ts |
	profile := PzTypeProfiler new runOn: aTestMethod.
	t := self removeAssertions: aTestMethod.
	ts := self inputAmplify: t profile: profile selector: aTestMethod selector.
	self stashTestmethod: ts base: aTestMethod methodClass
]

{ #category : #'as yet unclassified' }
Phazzer >> reduceInputsForAmplifier: tmp [
	^ tmp shuffle takeFirst: config maxPerAmplifier
]

{ #category : #'as yet unclassified' }
Phazzer >> removeAssertions: aTestMethod [
	^ (PzAssertTransform transformAllAsserts: aTestMethod ast) formattedCode 
]

{ #category : #'as yet unclassified' }
Phazzer >> removeFinishedTests [
	| unfinished |
	unfinished := db getNotFinished.
	unfinished
		do: [ :l | 
			self tools
				buildFinalTestClassWith: {(l at: #testMethod)}
				using: (self class environment at: (l at: #baseClass) asSymbol).
			db flagAsProcessed: (l at: db idColumn) ].
	"db flagAllInstalledAsCreated."
	self flag: #todo	"dont create new class for each test method. pack it in classes"
]

{ #category : #'as yet unclassified' }
Phazzer >> requiresToStopSandbox [
	| lastUpdate noUpdates |
	lastUpdate := db lastUpdate.
	lastUpdate isZero
		ifTrue: [ ^ false ].
	noUpdates := DateAndTime now asUnixTime - lastUpdate.
	('noUpdates: ' , noUpdates asString , '') traceCr.
	^ noUpdates > config freezeTimeOut
]

{ #category : #'as yet unclassified' }
Phazzer >> run [
	[ config sandbox
		ifTrue: [ self runSandboxedNotUIThread ]
		ifFalse: [ self runAllInstalled ] ]
		on: PzContinueInSandbox
		do: [ :x | x pass ]
]

{ #category : #'as yet unclassified' }
Phazzer >> runAllInstalled [
	| tempPackage testClasses ts |
	tempPackage := self tools defaultTempPackage
		asPackageIfAbsent: [ ^ self ].
	testClasses := tempPackage classes.
	testClasses ifEmpty: [ ^ self ].
	testClasses
		do: [ :cls | 
			cls testEvents: self.
			ts := cls buildSuite.
			"ts when: TestAnnouncement do: self eventForTestAnnouncement."
			[ ts := ts run ]
				on: Exception
				do: [ :x | 
					x isResumable
						ifTrue: [ x resume ].
					nil ] ]
		displayingProgress: 'Test classes: ', testClasses size asString 
]

{ #category : #'as yet unclassified' }
Phazzer >> runIfAnyTestsLeft [
	db anyUnFinishedLeft
		ifTrue: [ self run ]
]

{ #category : #'as yet unclassified' }
Phazzer >> runInSandbox [
	Author fullName: 'PhazzerSandbox'.
	[ (self installCount: 5000) > 0 ] whileTrue: [ self runAllInstalled ]
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
		ifFalse: [ PzContinueInSandbox new signal ].
	"self
				startSandboxAndWatchPriority: priority
				OnFinish: (self sandboxOnFinishOrCrash: priority)"
	self
		sandboxStart: priority
		OnFinish: (self sandboxOnFinishOrCrash: priority)
	"FileLocator image pathString = sandbox_image
		ifTrue: [  ]"
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxInit [
	sandbox_image := FileLocator imageDirectory pathString , '/sandbox'.
	Smalltalk backupTo: sandbox_image
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxOnFinishOrCrash [
	
	^ [ self removeFinishedTests.
	self runIfAnyTestsLeft ]
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxOnFinishOrCrash: priority [
	^ [ self removeFinishedTests.
	db anyUnFinishedLeft
		ifTrue: [ self
				sandboxStart: priority
				OnFinish: (self sandboxOnFinishOrCrash: priority) ] ]
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxStart: priority OnFinish: aBlock [
	| args |
	'Sandbox started' traceCr.
	db resetLastUpdate.
	args := OrderedCollection new.
	args
		addAll:
			{(sandbox_image , '.image').
			PzCommandLineHandler commandName.
			('--run=' , config dbName)}.
	config headless
		ifTrue: [ args addFirst: '--headless' ].
	args asString traceCr.
	process := OSSUnixSubprocess new
		terminateOnShutdown;
		command: FileLocator vmBinary pathString;
		arguments: args.
	process
		runAndWaitPollingEvery: (Delay forMilliseconds: 1000)
		doing: [ :theProcess :outStream :errStream | 
			self requiresToStopSandbox
				ifTrue: [ theProcess isComplete
						ifFalse: [ Stdio stdout
								<< 'Phazzer SIGTERM';
								flush.
							theProcess sigterm ] ] ]
		onExitDo: [ :theProcess :outStream :errStream | 
			Stdio stdout
				<< 'Phazzer OnExit:';
				flush.
			aBlock value ]
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxStartCommand [
	| args |
	"headless := '--headless'."
	'Sandbox started' traceCr.
	args := OrderedCollection new.
	args
		addAll:
			{(sandbox_image , '.image').
			PzCommandLineHandler commandName.
			('--run=' , config dbName)}.
	config headless
		ifTrue: [ args addFirst: '--headless' ].
	args asString traceCr.
	process := OSSUnixSubprocess new
		terminateOnShutdown;
		command: FileLocator vmBinary pathString;
		arguments: args.
	process
		runAndWaitPollingEvery: (Delay forMilliseconds: 1000)
		doing: [ :theProcess :outStream :errStream | 
			self requiresToStopSandbox
				ifTrue: [ theProcess sigterm ] ]
		onExitDo: [ :theProcess :outStream :errStream |  ]
]

{ #category : #'as yet unclassified' }
Phazzer >> sandboxStopCommand [
	| pid |
	pid := db getSandboxPID.
	pid = 0
		ifTrue: [ ^ self ].
	OSPlatform current resultOfCommand: 'pkill ' , config dbName.
	db writePID: 0
]

{ #category : #'as yet unclassified' }
Phazzer >> startSandboxAndWatchPriority: priority OnFinish: aBlock [
	| delay semaphorExecutor executor watcher |
	delay := 1 seconds asDelay.
	semaphorExecutor := Semaphore new.
	db resetLastUpdate.
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

{ #category : #'as yet unclassified' }
Phazzer >> stashTestmethod: sourceCodes base: class [
	| selector |
	sourceCodes
		do: [ :sourceCode | 
			selector := (self tools parsedMethodFrom: sourceCode) selector.
			db insertTestmethod: sourceCode selector: selector base: class ]
]

{ #category : #'as yet unclassified' }
Phazzer >> tic [
	self db writeGlobalKey: 'start' value: DateAndTime now asUnixTime
]

{ #category : #'as yet unclassified' }
Phazzer >> toc [
	self db writeGlobalKey: 'finish' value: DateAndTime now asUnixTime
]

{ #category : #accessing }
Phazzer >> tools [
	^ PzTools new
]
