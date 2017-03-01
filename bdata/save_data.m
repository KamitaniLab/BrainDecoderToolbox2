function save_data(fileName, dataSet, metaData, varargin)
% save_data    Save `dataSet` and `metaData` to a file
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     save_data(fileName, dataSet, metaData)
%
% Inputs:
%
% - fileName : The name of a saved file
% - dataSet  : Dataset matrix
% - metaData : Metadata structure
%
% Outputs:
%
% None
%

opt = bdt_getoption(varargin, ...
                    {{'Version', 'char', '-v7.3'}});

save_ver = opt.Version;

[p, n, ext] = fileparts(fileName);

switch ext
  case '.mat'
    fileType = 'mat';
  case '.h5'
    fileType = 'hdf5';
  otherwise
    fileType = '';
end

% Get the file name calling me
[st, ind] = dbstack('-completenames');
if length(st) == 1
    createScript = '<Directly called>';
else
    createScript = st(ind + 1).file;
end

% Get data creation time
createDateRaw = now;
createDate = datestr(createDateRaw, 'yyyy-mm-dd HH:MM:SS');

% Save data
switch fileType
  case 'mat'
    save(fileName, ...
         'dataSet', 'metaData', ...
         'createScript', 'createDateRaw', 'createDate', ...
         save_ver);
  case 'hdf5'
    dat.dataSet = dataSet;
    dat.metaData = metaData;
    dat.createScript = createScript;
    dat.createDateRaw = createDateRaw;
    dat.createDate = createDate;

    writehdf5fromstruct(fileName, dat);

  otherwise
    error('save_data:UnkownFileType', ...
          [ 'Unknown file type: ' fileType ]);
end


%% Subfunctions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function save_data_hdf5(fileName, dataSet, metaData)
% save_data_hdf5    Save `dataSet` and `metaData` in `fileName` with HDF5 format
%

fid = H5F.create(fileName);

%% Create dataSet

dims = fliplr(size(dataSet));

tidDs = H5T.copy('H5T_NATIVE_DOUBLE');
sidDs = H5S.create_simple(2, dims, dims);

didDs = H5D.create(fid, 'dataSet', tidDs, sidDs, 'H5P_DEFAULT');

H5D.write(didDs, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', dataSet);

H5T.close(tidDs);
H5S.close(sidDs);
H5D.close(didDs);

%% Create metaData

strLen = 512;

dims = fliplr(size(metaData.value));
keyNum = length(metaData.key);

tidMdVal = H5T.copy('H5T_NATIVE_DOUBLE');
sidMdVal = H5S.create_simple(2, dims, dims);
tidMdStr = H5T.copy('H5T_C_S1');
H5T.set_size(tidMdStr, 'H5T_VARIABLE');
sidMdStr = H5S.create_simple(1, keyNum, keyNum);

gid = H5G.create(fid, '/metaData', 'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');

didMdKey = H5D.create(gid, 'key', tidMdStr, sidMdStr, 'H5P_DEFAULT');
didMdDsc = H5D.create(gid, 'description', tidMdStr, sidMdStr, 'H5P_DEFAULT');
didMdVal = H5D.create(gid, 'value', tidMdVal, sidMdVal, 'H5P_DEFAULT');

H5D.write(didMdKey, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', metaData.key);
H5D.write(didMdDsc, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', metaData.description);
H5D.write(didMdVal, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', metaData.value);

H5G.close(gid);
H5T.close(tidMdVal);
H5T.close(tidMdStr);
H5S.close(sidMdVal);
H5S.close(sidMdStr);
H5D.close(didMdKey);
H5D.close(didMdDsc);
H5D.close(didMdVal);

% Finialization
H5F.close(fid);

