function [dataSet, metaData] = create_bdata(builder)
% create_bdata    Creates BrainDecoderToolbox2 data
%
% Inputs:
%
% - builder [struct] : Standard data builder
%
% Outputs:
%
% - dataSet, metaData : BrainDecoderToolbox2 data
%


%% Init data -----------------------------------------------------------
braindat = [];
sessions = [];
runs     = [];
blocks   = [];
labels   = [];

%% Load EPIs -----------------------------------------------------------
sesnum   = 1;
runnum   = 1;
blocknum = 1;

for ises = 1:length(builder.ses)
    fprintf('Session: %s\n', builder.ses(ises).id);

    %% Runs
    for irun = 1:length(builder.ses(ises).run)
        fprintf('Run: %s\n', builder.ses(ises).run(irun).id);

        % EPI
        epifiles = builder.ses(ises).run(irun).epifile;
        [vdat, vxyz] = load_epi(epifiles);

        vollen = size(vdat, 1);
        voxnum = size(vdat, 2);

        braindat = [braindat; vdat];
        sessions = [sessions; repmat(sesnum, vollen, 1)];
        runs     = [runs; repmat(runnum, vollen, 1)];

        % TODO: add voxel XYZ consistency check
        
        % Design (blocks and labels)
        for iblock = 1:size(builder.ses(ises).run(irun).design, 1)
            blen = builder.ses(ises).run(irun).design(iblock, 2);
            blabel = builder.ses(ises).run(irun).design(iblock, 3:end);

            blocks = [blocks; repmat(blocknum, blen, 1)];
            labels = [labels; repmat(blabel, blen, 1)];

            blocknum = blocknum + 1;
        end
        
        runnum = runnum + 1;
    end
    
    sesnum = sesnum + 1;
end

%% Loading ROIs --------------------------------------------------------

roi = [];

%% ROI Masks
if isfield(builder, 'roi') && isfield(builder.roi, 'mask')
    maskspec = builder.roi.mask;

    maskfiles = {};
    for i = 1:length(maskspec)
        fs = dir(maskspec{i});
        fpath = fileparts(maskspec{i});
        
        for j = 1:length(fs)
            maskfiles{end+1, 1} = fullfile(fpath, fs(j).name);
        end
    end

    for i = 1:length(maskfiles)
        [fpath, fbase, fext] = fileparts(maskfiles{i});

        [mask, mxyz] = load_epi(maskfiles{i});

        ind = length(roi);
        roi(ind + 1).name = fbase;
        roi(ind + 1).xyz = mxyz(:, mask(:) ~= 0);
    end
end

%% ROI xyz
% Not supported yet

%% Create dataSet+metaData ---------------------------------------------
[dataSet, metaData] = initialize_dataset();
[dataSet, metaData] = add_dataset(dataSet, metaData, braindat, 'VoxelData', '1 = voxel data');
[dataSet, metaData] = add_dataset(dataSet, metaData, sessions, 'Session',   '1 = session number');
[dataSet, metaData] = add_dataset(dataSet, metaData, runs,     'Run',       '1 = run number');
[dataSet, metaData] = add_dataset(dataSet, metaData, blocks,   'Block',     '1 = block number');
[dataSet, metaData] = add_dataset(dataSet, metaData, labels,   'Label',     '1 = labels');

% Add voxel xyz coordinates
metaData = add_voxelxyz(metaData, vxyz, 'VoxelData');

% Add ROIs
for i = 1:length(roi)
    roiflag = get_roiflag(roi(i).xyz, vxyz);

    metaData = add_metadata(metaData, ...
                            roi(i).name, ...
                            sprintf('1 = ROI %s', roi(i).name), ...
                            roiflag, ...
                            'VoxelData');
end
