Class {
	#name : #BaselineOfPhazzer,
	#superclass : #BaselineOf,
	#category : #BaselineOfPhazzer
}

{ #category : #baselines }
BaselineOfPhazzer >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'OSSubprocess'
				with: [ spec
						repository: 'github://pharo-contributions/OSSubprocess:master/repository' ].
			spec package: 'Phazzer' with: [ spec requires: #('OSSubprocess') ].
			spec
			package: 'Phazzer-Tests'
			with: [ spec requires: #( 'Phazzer' ) ].
			 ]
]
