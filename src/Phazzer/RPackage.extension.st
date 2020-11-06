Extension { #name : #RPackage }

{ #category : #'*Phazzer' }
RPackage >> phazz [
	self name = PzTools new defaultTempPackage
		ifTrue: [ ^ self ].
	self name = PzTools new defaultFinalPackage
		ifTrue: [ ^ self ].
	self name = Phazzer package name
		ifTrue: [ ^ self ].
	(self definedClasses select: [ :cls | cls isTestCase ])
		do: [ :cls | cls phazz ]
		displayingProgress: 'Phazzing Package: ' , self name
]
