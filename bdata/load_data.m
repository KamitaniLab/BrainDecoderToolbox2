function [dataSet, metaData] = load_data(fileName)
% load_data    Load `dataSet` and `metaData` from a file
%
% This file is a part of BrainDecoderToolbox2.
%

[ p, n, ext ] = fileparts(fileName);

switch ext
  case '.mat'
    fileType = 'mat';
  case '.h5'
    fileType = 'hdf5';
  otherwise
    fileType = '';
end


switch fileType
  case 'mat'
    load(fileName);
  case 'hdf5'
    d = readhdf5asstruct(fileName);
    dataSet = d.dataSet;
    metaData = d.metaData;
  otherwise
    error('load_data:UnkownFileType', ...
          [ 'Unknown file type: ' fileType ]);
end


if ~exist('dataSet', 'var')
    error('load_data:dataSetNotFound', ...
          'dataSet was not found');
end

if ~exist('metaData', 'var')
    error('load_data:metaDataNotFound', ...
          'metaData was not found');
end

