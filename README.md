# BrainDecoderToolbox2

BrainDecoderToolbox2 is a Matlab library for brain decoding analysis, providing interfaces to BrainDecoderToolbox2 data format and utilities for machine learning analysis and functional MRI data handling as well as drawing figures and visualizing data.

## Requirments

- MATLAB (>=R2007b)
- SPM (5, 8, or 12)

## Installation

1. Download `BrainDecoderToolbox2` in your computer.
2. Add the downloaded directory in your MATLAB path.
    - `setpath.m` will set all the necessary path of BrainDecoderToolbox2.
    - Alternatively, you can set the path by yourself (e.g., `addpath(genpath('/in/your/computer/BrainDecoderToolbox2'))`)
3. Add SPM in your MATLAB path when you use functions depending SPM.

## For developers

- The names of functions should be snake-case (e.g., `get_dataset`).
- The names of variables should be lower camel-case (e.g., `numVoxel`).
- Please push your commits or send your pull requests to `dev` branch, not to `master`.

## License

MIT License
