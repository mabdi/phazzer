Class {
	#name : #PzCommandLineHandler,
	#superclass : #CommandLineHandler,
	#category : #Phazzer
}

{ #category : #accessing }
PzCommandLineHandler class >> commandName [
	^ 'phazz'
]

{ #category : #accessing }
PzCommandLineHandler class >> description [
	^ 'runs Phazzer, the fuzzing by test methods'
]

{ #category : #activation }
PzCommandLineHandler >> activate [
	self activateHelp
		ifTrue: [ ^ self ].
	(self hasOption: 'run')
		ifTrue: [ self flagExecuted.
			Phazzer runAllInstalled.
			Smalltalk snapshot: false andQuit: true ]
]

{ #category : #activation }
PzCommandLineHandler >> flagExecuted [
		(FileLocator imageDirectory / 'sandbox-child.txt') writeStream
		nextPutAll: 'executed cmdHandler';
		cr;
		close.
]
