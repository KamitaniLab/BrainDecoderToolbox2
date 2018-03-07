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

suppdat = [];

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
        nodesign = ~isfield(builder.ses(ises).run(irun), 'design') ...
                   || isempty(builder.ses(ises).run(irun).design) ...
                   || logical(sum(isnan(builder.ses(ises).run(irun).design(:))));

        if nodesign
            fprintf('Design matrix is omitted. The resulting data lacks ''Block'' and ''Label''\n');
            blocks = NaN;
            labels = NaN;
        else
        for iblock = 1:size(builder.ses(ises).run(irun).design, 1)
            blen = builder.ses(ises).run(irun).design(iblock, 2);
            blabel = builder.ses(ises).run(irun).design(iblock, 3:end);

            blocks = [blocks; repmat(blocknum, blen, 1)];
            labels = [labels; repmat(blabel, blen, 1)];

            blocknum = blocknum + 1;
        end
        end

        % Add supplement data
        for k = 1:length(builder.ses(ises).run(irun).supplement)
            skey = builder.ses(ises).run(irun).supplement(k).name;
            sdat = builder.ses(ises).run(irun).supplement(k).data;

            if isfield(builder.ses(ises).run(irun).supplement(k), 'description')
                sdesc = builder.ses(ises).run(irun).supplement(k).description;
            else
                sdec = skey;
            end            

            if length(suppdat) < k
                suppdat(k).name = skey;
                suppdat(k).desc = sdesc;
                suppdat(k).data = sdat;
            else
                if ~strcmp(suppdat(k).name, skey)
                    error('Incorrect name in supplement data.');
                end
                suppdat(k).data = [suppdat(k).data; sdat];
            end
        end

        runnum = runnum + 1;
    end

    sesnum = sesnum + 1;
end

%% Loading ROIs --------------------------------------------------------

roi = [];

if isfield(builder, 'roi')

    for i = 1:length(builder.roi)

        roiname = builder.roi(i).name;

        if isfield(builder.roi(i), 'source')
            % Load ROI from a mask file
            roimaskfile = builder.roi(i).source;

            [mask, mxyz] = load_epi(roimaskfile);

            ind = length(roi);
            roi(ind + 1).name = roiname;
            roi(ind + 1).xyz = mxyz(:, mask(:) ~= 0);
        else isfield(builder.roi(i), 'xyz')
            % Add ROI xyz
            roi(ind + 1).name = roiname;
            roi(ind + 1).xyz = builder.roi(i).xyz;
        end
    end
end

%% Create dataSet+metaData ---------------------------------------------
[dataSet, metaData] = initialize_dataset();
[dataSet, metaData] = add_dataset(dataSet, metaData, braindat, 'VoxelData', '1 = voxel data');
[dataSet, metaData] = add_dataset(dataSet, metaData, sessions, 'Session',   '1 = session number');
[dataSet, metaData] = add_dataset(dataSet, metaData, runs,     'Run',       '1 = run number');

clear braindat sessions runs;

if ~nodesign
    [dataSet, metaData] = add_dataset(dataSet, metaData, blocks,   'Block',     '1 = block number');
    [dataSet, metaData] = add_dataset(dataSet, metaData, labels,   'Label',     '1 = labels');

    clear blocks labels;
end

for i = 1:length(suppdat)
    [dataSet, metaData] = add_dataset(dataSet, metaData, suppdat(i).data, suppdat(i).name, sprintf('1 = %s', suppdat(i).desc));
end

% Add voxel xyz coordinates
metaData = add_voxelxyz(metaData, vxyz, 'VoxelData');

% Add ROIs
for i = 1:length(roi)
    roiflag(i, :) = get_roiflag(roi(i).xyz, vxyz);

    metaData = add_metadata(metaData, ...
                            roi(i).name, ...
                            sprintf('1 = ROI %s', roi(i).name), ...
                            roiflag(i, :), ...
                            'VoxelData');
end

% Remove voxels out of ROIs
removevox = true;
if removevox
    fprintf('Removing voxels out of ROIs\n');
    isroi = logical(sum(roiflag, 1));
    dataSet(:, ~isroi) = [];
    metaData.value(:, ~isroi) = [];
end
