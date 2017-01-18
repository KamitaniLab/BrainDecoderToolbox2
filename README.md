# BrainDecoderToolbox2

Matlab library for brain decoding

## Requirments

- MATLAB (>R2007b)
- SPM (5, 8, or 12)

## Installation

1. Put `BrainDecoderToolbox2` in your computer
2. Run `setpath` or `addpath(genpath('/in/your/computer/BrainDecoderToolbox2'))` on MATLAB.
3. Add SPM in your MATLAB path.

## Files

- bdata/
    - Set of data interface functions for BrainDecoderToolbox2 data format
- distcomp/
    - Functions for distributed computation supports
- fig/
    - Functions for visualization and figure drawing
- ml/
    - Fuctions supporting machine learning analysis
- mri/
    - Fuctions handling MRI data
- preproc/
    - Functions for preprocessing
- stats/
    - Fuctions for statistics
- test/
    - Test scripts
- util/
    - Utility functions
- setpath.m
    - Matlab script to set paths to BrainDecoderToolbox2 functions
- README.md
    - This file
- .gitignore
    - Git related file

## For developers

- The names of functions should be snake-case (e.g., `get_dataset`).
- The names of variables should be lower camel-case (e.g., `numVoxel`).
- Please push your commits or send your pull requests to `dev` branch, not to `master`.

## Third-party functions

BrainDecoderToolbox2 contains the following third-party functions:

- `errorbar_h` by The MathWorks, Inc.
- `hline` by Brandon Kuczenski
- `suptitle` by Drea Thomas, John Cristion, and Mark Histed
