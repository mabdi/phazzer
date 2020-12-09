# phazzer
Fuzzer for Pharo


## Installation

```smalltalk
Metacello new
  baseline: 'Phazzer';
  repository: 'github://mabdi/phazzer/src';
  load.
```

## Fuzzing a single package

```smalltalk
Phazzer new phazzPackage: (RPackage organizer packageNamed: #'Awesome-Tests')
```


## Fuzzing all tests in the image:

If you like to fuzz all tests installed in the image, run the following command:

```smalltalk
Phazzer hackThePlanet
```
![](hacktheplanet.gif "https://giphy.com/explore/hack-the-planet")
