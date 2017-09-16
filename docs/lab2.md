# ECE 3400: Labs
* ## [Home](./index.md)
* ## [Team Info](./info.md)
* ## [Labs](./labs.md)
* ## [Meeting Minutes](./minutes.md)

## LAB 2: Analog Circuitry and FFT

### Overall Goal

The next step in developing our robot is to allow it to sense the world around it. Our
robot can currently move throughout its environment, but has no knowledge about where it is,
or what is around it. For this lab, we developed two different sensors to be used on our robot.
First, we used a microphone circuit to detect a 660Hz whistle blow. This is used to signal
our robot to begin exploring the maze. The second sensor was an IR sensore to detect various
treasures which blink at varying frequencies.

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

Team Members: Ryan Hornung, Alicia Coto, Raul Pacheco

### Purpose

The goal of the Optics Subteam was to develop IR sensors to detect and distinguish various treasures
around the map. These treasures simply output a varying IR signal at a specific frequency.

### Procedure


### Materials Used: