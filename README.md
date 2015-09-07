# Musicreatures

Musicreatures is a novel mobile app that utilizes the multimodal interaction capabilities of smart phones in playful, real-time musicalization. Musicreatures is licensed under revised BSD License.

## The app

Musicreatures is an iPhone application, targeted for all users regardless of their prior musical background. With the application, the user can create music in a simple game-like environment mainly using motion gestures. The gestures are mapped to a visual view and the visual data is then musicalized. A number of musical restrictions are enforced in order to assist the user in achieving musically satisfying results and to avoid cacophonic outcomes.

## Usage

The application can be inspected by opening the XCode project contained in this repository and the Pure Data files contained in the MusicreaturesPatch folder.

This application makes use of libraries included as submodules. Please see the instructions below for initializing these libraries.

### Submodules

Musicreatures includes the following libraries as Git submodules:

* [GPUImage](https://github.com/BradLarson/GPUImage)
* [libpd](https://github.com/libpd)

You can initialize the submodules by running:

    git submodule update --init

You will also need to initialize the submodule within the pure-data folder of the libpd to initialize the Pd Vanilla.

## Copyright

Copyright 2014-2015 Petri Myllys & University of Helsinki.  
See LICENSE.txt for conditions.

GPUImage is licensed under a BSD-style license. Libpd is licensed under the Standard Improved BSD License. Please see the directory Musicreatures/licenses for conditions.
