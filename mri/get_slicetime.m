function sliceTime = get_slicetime(dcm, saveFileName)
% get_slicetime   Get slice acquisition times
%
% Only Siemens DICOM files are supported yet.
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     sliceTime = get_slicetime(dcm, saveFileName)
%

% Get a DICOM file list
if ~iscell(dcm)
    if exist(dcm, 'dir')
        files = dir(dcm);
        c = 1;
        for i = 1:length(files)
            [d, b, ext] = fileparts(files(i).name);
            if isequal(ext, '.dcm')
                dcmList{c} = fullfile(dcm, files(i).name);
                c = c + 1;
            end
        end
    elseif exist(dcm, 'file')
        dcmList = {dcm};
    else
        error('Invalid input');
    end
else
    dcmList = dcm;
end

% Get slice time
for i = 1:length(dcmList)
    dcmFile = dcmList{i};
    hdr = spm_dicom_headers(dcmFile);
    sliceTime(i, :) = hdr{1}.Private_0019_1029;
end

% Save data if `saveFileName` is specified
if exist('saveFileName', 'var')
    save(saveFileName, 'sliceTime');
end
