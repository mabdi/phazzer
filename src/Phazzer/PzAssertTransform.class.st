Class {
	#name : #PzAssertTransform,
	#superclass : #Object,
	#category : #Phazzer
}

{ #category : #removing }
PzAssertTransform class >> removeAllAsserts: aParseTree [
	^ self new transformAllAsserts: aParseTree extract: false
]

{ #category : #removing }
PzAssertTransform class >> transformAllAsserts: aParseTree [
	^ self new transformAllAsserts: aParseTree extract: true
]

{ #category : #accessor }
PzAssertTransform >> getAllPatterns [
	| methodsToBeCalled |
	methodsToBeCalled := ((self class
		methodsInProtocol: 'transform pattern') collect: #selector) asOrderedCollection.
	methodsToBeCalled
		addAll:
			((self class methodsInProtocol: 'transform pattern should')
				collect: #selector).
	^ methodsToBeCalled
		inject: OrderedCollection new
		into: [ :result :item | 
			result
				addAll: (self perform: item);
				yourself ]
]

{ #category : #accessor }
PzAssertTransform >> getReduceOraclePatterns [
	| methodsToBeCalled |
	methodsToBeCalled := (self class
		methodsInProtocol: 'transform pattern') collect: #selector.
	^ methodsToBeCalled
		inject: OrderedCollection new
		into: [ :result :item | 
			result
				addAll: (self perform: item);
				yourself ]
]

{ #category : #running }
PzAssertTransform >> numberOfAssertionsIn: aParseTree [
	| searcher timesToApply |
	searcher := RBParseTreeSearcher new.
	timesToApply := 0.
	self getAllPatterns
		do: [ :each | 
			searcher
		matches: each key
		do: [ :node :answer | timesToApply := timesToApply + 1 ]. ].
	searcher executeTree: aParseTree copy.
	^ timesToApply
	
	
]

{ #category : #running }
PzAssertTransform >> rewriteAllAssertsIn: aParseTree replaceBlock: aBlock [
	| rewriter parser tree |
	rewriter := RBParseTreeRewriter new.
	parser := aParseTree copy.
	self getReduceOraclePatterns
		do: [ :each | 
			rewriter
				addRule: (RBBlockReplaceRule searchFor: each key replaceWith: aBlock) ].
	rewriter executeTree: parser.
	tree := rewriter tree.
	^ tree
]

{ #category : #running }
PzAssertTransform >> transformAllAsserts: aParseTree extract: doExtract [
	| rewriter parser empty tree |
	rewriter := RBParseTreeRewriter new.
	parser := self transformRemoveReturn: aParseTree copy.
	empty := RBParser parseExpression: ''.
	self getAllPatterns
		do: [ :each | 
			doExtract
				ifTrue: [ rewriter replace: each key with: each value ]
				ifFalse: [ rewriter
						addRule:
							(RBBlockReplaceRule searchFor: each key replaceWith: [ :node | empty ]) ] ].
	rewriter executeTree: parser.
	tree := rewriter tree.
	^ tree
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformAssert [
	^ { 
		  ('self assert: ``@aBooleanOrBlock' -> '``@aBooleanOrBlock value').
		  ('self assert: ``@aBooleanOrBlock description: ``@aStringOrBlock'
		   -> '``@aBooleanOrBlock value').
		  ('self assert: ``@aBooleanOrBlock description: ``@aStringOrBlock resumable: ``@resumableBoolean'
		   -> '``@aBooleanOrBlock value').
		  ('self should: ``@aBooleanOrBlock' -> '``@aBooleanOrBlock value').
		  ('self should: ``@aBooleanOrBlock description: ``@aStringOrBlock'
		   -> '``@aBooleanOrBlock value') }
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformAssertCloseTo [
	^ { 
		  ('self assert: ``@actual closeTo: ``@expected' -> '``@actual closeTo: ``@expected')}
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformAssertCollectionEquals [
	^ { ('self assertCollection: ``@actual equals: ``@expected'
	   -> '``@actual = ``@expected') }
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformAssertCollectionHasSameElements [
	^ { ('self assertCollection: ``@actual hasSameElements: ``@expected'
	   -> '(``@actual difference: ``@expected) isEmpty and: [(``@expected
		difference: (``@actual intersection: ``@expected)) isEmpty]') }
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformAssertCollectionIncludesAll [
	^ { ('self assertCollection: ``@actual includesAll: ``@subcollection'
	   ->
		   '``@actual includesAll: ``@subcollection') }
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformAssertEmpty [
	^ {('self assertEmpty: ``@aCollection' -> '``@aCollection isEmpty')}
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformAssertEquals [
	^ { 'self assert: ``@actual equals: ``@expected' -> '``@actual = ``@expected'.
	  'self assert: ``@actual equals: ``@expected description: ``@description' -> '``@actual = ``@expected' }
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformAssertIdenticalTo [
	^ { 'self assert: ``@actual identicalTo: ``@expected' -> '``@expected == ``@actual'}
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformDeny [
	^ { 
		  'self deny: ``@aBooleanOrBlock' -> '``@aBooleanOrBlock value not'.
		  ('self deny: ``@aBooleanOrBlock description: ``@aStringOrBlock'
		   -> '``@aBooleanOrBlock value not').
		  ('self deny: ``@aBooleanOrBlock description: ``@aStringOrBlock resumable: ``@resumableBoolean'
		   -> '``@aBooleanOrBlock value not').
		  ('self shouldnt: ``@aBooleanOrBlock'
		   -> '``@aBooleanOrBlock value not').
		  ('self shouldnt: ``@aBooleanOrBlock description: ``@aStringOrBlock'
		   -> '``@aBooleanOrBlock value not') }
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformDenyCollection [
	^ { 'self denyCollection: ``@actual equals: ``@expected' -> '(``@expected = ``@actual) not'}
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformDenyEquals [
	^ { 'self deny: ``@actual equals: ``@expected' -> '(``@expected = ``@actual) not' }
]

{ #category : #'transform pattern' }
PzAssertTransform >> transformDenyIdenticalTo [
	self flag: #TODO. "check it"
	^ { ('self deny: ``@actual identicalTo: ``@expected'
	   -> '(``@expected == ``@actual) not') }
]

{ #category : #running }
PzAssertTransform >> transformRemoveReturn: aParseTree [
	| rewriter parser tree |
	rewriter := RBParseTreeRewriter new.
	parser := aParseTree copy.
	rewriter replace: '^``@object' with: '``@object'.
	rewriter executeTree: parser.
	tree := rewriter tree.
	^ tree
]

{ #category : #'transform pattern should' }
PzAssertTransform >> transformShouldNotTakeMoreThan [
	^ { 'self should: ``@aBlock notTakeMoreThan: ``@aDuration' -> '[``@aBlock value. true] valueWithin: ``@aDuration
		onTimeout: [  false]' }
]

{ #category : #'transform pattern should' }
PzAssertTransform >> transformShouldNotTakeMoreThanMilliseconds [
	^ { ('self should: ``@aBlock notTakeMoreThanMilliseconds: ``@anInteger'
	   -> '[``@aBlock value. true] valueWithin: (Duration milliSeconds: ``@anInteger)
		onTimeout: [false]') }
]

{ #category : #'transform pattern should' }
PzAssertTransform >> transformShouldRaise [
	^ { 'self should: ``@aBlock raise: ``@anExceptionalEvent' -> '[ ``@aBlock value. false ]
		on: ``@anExceptionalEvent
		do: [ :ex | ex return: true ]'.
	  'self should: ``@aBlock raise: ``@anExceptionalEvent description: ``@qwe' -> '[ ``@aBlock value. false ]
		on: ``@anExceptionalEvent
		do: [ :ex | ex return: true ]' }
]

{ #category : #'transform pattern should' }
PzAssertTransform >> transformShouldntRaise [
	^ { 'self shouldnt: ``@aBlock raise: ``@anExceptionalEvent' -> '([ ``@aBlock value. false ]
		on: ``@anExceptionalEvent
		do: [ :ex | ex return: true ]) not'.
	  'self shouldnt: ``@aBlock raise: ``@anExceptionalEvent description: ``@qwe' -> '([ ``@aBlock value. false ]
		on: ``@anExceptionalEvent
		do: [ :ex | ex return: true ]) not' }
]
