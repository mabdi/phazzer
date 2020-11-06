Extension { #name : #RPackage }

{ #category : #'*Phazzer' }
RPackage >> phazz [
	(self definedClasses select: [ :cls | cls isTestCase ])
		do: [ :cls | cls phazz ]
		displayingProgress: 'Phazzing Package: ' , self name
]
