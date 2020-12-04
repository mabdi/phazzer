Extension { #name : #RPackage }

{ #category : #'*Phazzer' }
RPackage >> phazz [
	self name = PzTools new defaultTempPackage
		ifTrue: [ ^ self error: 'I cannot fuzz myself' ].
	self name = PzTools new defaultFinalPackage
		ifTrue: [ ^ self error: 'I cannot fuzz myself' ].
	self name = Phazzer package name
		ifTrue: [ ^ self error: 'I cannot fuzz myself' ].
	Phazzer new phazzPackage: self
]
