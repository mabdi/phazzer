"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestPhazzer,
	#superclass : #PackageManifest,
	#category : #'Phazzer-Manifest'
}

{ #category : #'code-critics' }
ManifestPhazzer class >> ruleRBGuardingClauseRuleV1FalsePositive [
	^ #(#(#(#RGClassDefinition #(#PzCommandLineHandler)) #'2020-12-04T17:13:13.347657+01:00') )
]
