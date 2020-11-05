Extension { #name : #TestCase }

{ #category : #'*Phazzer' }
TestCase class >> phazz [
	self allTestSelectors do: [ :selector | 
		(self lookupSelector: selector) phazz ]
]
