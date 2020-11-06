Extension { #name : #Behavior }

{ #category : #'*Phazzer' }
Behavior >> pzCompile: code [
	SystemAnnouncer uniqueInstance
		suspendAllWhile: [ self compile: code ]
]
