//
//  UHMMusicalTerms.h
//  Musicreatures
//
//  Created by Petri J Myllys on 07/08/14.
//  Copyright (c) 2014 University of Helsinki. All rights reserved.
//

#ifndef Musicreatures_UHMMusicalTerms_h
#define Musicreatures_UHMMusicalTerms_h

//typedef enum {
//    C,
//    DB,
//    D,
//    EB,
//    E,
//    F,
//    GB,
//    G,
//    AB,
//    A,
//    BB,
//    B
//} Note;
//
typedef enum {
    IONIAN,
    DORIAN,
    PHRYGIAN,
    LYDIAN,
    MIXOLYDIAN,
    AEOLIAN,
    LOCRIAN
} Mode;
//
//typedef struct {
//    Note rootNote;
//    Mode mode;
//} Scale;

typedef enum {
    UNISON,
    MINOR_SECOND,
    MAJOR_SECOND,
    MINOR_THIRD,
    MAJOR_THIRD,
    PERFECT_FOURTH,
    AUGMENTED_FOURTH,
    FIFTH,
    MINOR_SIXTH,
    MAJOR_SIXTH,
    MINOR_SEVENTH,
    MAJOR_SEVENTH
} ScaleDegree;

#endif
