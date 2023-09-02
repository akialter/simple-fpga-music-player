# simple-fpga-music-player

## Introduction
This VHDL project was programmed on a DE10-Standard FPGA board using Intel Quartus software, as part of Georgia Institute of Technology's ECE2031 (Digital Design Laboratory) course.

## Description
The instructors provided ```SCOMP.vhd```, which simulated a 16-bit processor with simple instructions, such as add, load/store, and jump.

We were tasked to develop ```TONEGEN.vhd```, which defined a simple DDS (direct digital synthesis) device that generated sine waves in range of 100 Hz to 5000 Hz and 
produced a musical note within 1% error. We then programmed this VHDL code to DE10-Standard board connected to a speaker, and wrote ```SongTest.asm``` assembly code for SCOMP 
to play the melody of "Twinkle Twinkle Little Star".

## Functionality
The summary for the peripheral can be found here: [project summary](https://view.officeapps.live.com/op/view.aspx?src=https%3A%2F%2Fs3.amazonaws.com%2Fsymp.csm.usprod%2Fgatech%2Ffiles%2Fde3%2Fde379497174ae172fcb5b4b7cd5f0d6e.docx%3FX-Amz-Content-Sha256%3DUNSIGNED-PAYLOAD%26X-Amz-Algorithm%3DAWS4-HMAC-SHA256%26X-Amz-Credential%3DAKIAID3RBESXBCESHUGA%252F20230902%252Fus-east-1%252Fs3%252Faws4_request%26X-Amz-Date%3D20230902T204018Z%26X-Amz-SignedHeaders%3Dhost%26X-Amz-Expires%3D3600%26X-Amz-Signature%3D3d3948443b74fdad4519a7f2968a64ce3d38c345c6e81c4b207ce92c79fe8dc8&wdOrigin=BROWSELINK)

We provided some functionalites in conjuction with the requirement from the instructors:

- Produced the musical note in range (100 Hz to 5 kHz) within 1% accuracy. (required)
- Added volume control ability by manipulating the waveform's amplitude.
- Added multiple waveforms (square and triangle, in addition to sine wave).
- Optimized the device's memory usage by only storing a quarter of the symmetric wave and adding/substracting a "tuning word" so that the device can produced the full waveform.
