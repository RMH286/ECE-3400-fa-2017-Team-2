# ECE 3400: Labs
* ## [Home](./index.md)
* ## [Team Info](./info.md)
* ## [Labs](./labs.md)
* ## [Meeting Minutes](./minutes.md)

## LAB 2: Signal Processing

### Overall Goal

The purpose of this lab was to add the first sensors to the robot. One is an electret microphone that will be used to detect the 660 Hz whistle blow, the signal indicating that the robot needs to start mapping the maze. The other is an IR sensor that will be used to detect an IR treasure blinking at 7 kHz.

## Acoustics Subteam

Team Members: Nicolas Casazzone, Ben Roberge 


### Purpose

The goal of the Acoustics Subteam was to be able to distinguish a 660Hz tone as the start signal of our autonomous robot. In order to perform this task,
we utilized the Open Music Lab FFT library within Arduino to read analog inputs from the microphone and output the frequency bin magnitudes via the built in Arduino Serial
Monitor. Once the frequency bin for the 660Hz was located, we modeled our code to constantly check the magnitude of this bin to notify if the start signal was played.

### Materials Used:

* Arduino Uno
* Electret microphone
* 1 µF capacitor
* 300 Ω resistors
* ~3 kΩ resistor
* Referred to datasheet (insert link to datasheet for ATmega328/P)

### Procedure




## Optics Subteam

### Purpose


### Procedure


### Materials Used: