function [dataset, meta_data, discarded_fields] = convert_from_bdtb(D)
% convert_from_bdtb    Convert D structure of BrainDecoderToolbox into BrainDecoderToolbox2 format data
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     dataset = convert_from_bdtb(D)
%     [dataset, meta_data] = convert_from_bdtb(D)
%     [dataset, meta_data, discarded_fields] = convert_from_bdtb(D)
%
% Note:
%
% See <http://www.cns.atr.jp/dni/en/downloads/brain-decoder-toolbox/> for the
% details on BrainDecoderToolbox.
%
% - Default meta_data keys
%     - Feature                   : Meta data index for features (voxel data)
%     - Label                     : Meta data index for labels
%     - Design                    : Meta data index for experiment design information
%     - Block                     : Meta data index for block index
%     - Run                       : Meta data index for run index
%     - voxel_x, voxel_y, voxel_z : voxel x, y, z coordinates (D.xyz)
%     - ROI_*                     : ROI indexes 
%     - Label_*                   : Label indexes
%

% Set basic meta data keys and descriptions
feature_key = 'Feature'; feature_description = 'Index for features';
label_key   = 'Label';   label_description   = 'Index for labels';
block_key   = 'Block';   block_description   = 'Index for block numbers';
run_key     = 'Run';     run_description     = 'Index for run numbers';

roi_prefix    = 'ROI_';
label_prefix  = 'Label_';

d_fields     = fieldnames(D);
field_unused = true(size(d_fields));

%% Get feature data, labels, and ROIs data from the D structure
if isfield(D, 'data')
    voxel_data = D.data;
    field_unused(strcmp(d_fields, 'data')) = false;
else
    error('convert_from_bdtb:DataNotFound', ...
          '''data'' was not found in ''D''');
end

if     isfield(D, 'label'),  label_data = D.label;  field_unused(strcmp(d_fields, 'label')) = false;
elseif isfield(D, 'labels'), label_data = D.labels; field_unused(strcmp(d_fields, 'labels')) = false;
else                         label_data = [];
end

if     isfield(D, 'label_type'),  label_type = D.label_type;  field_unused(strcmp(d_fields, 'label_type')) = false;
elseif isfield(D, 'labels_type'), label_type = D.labels_type; field_unused(strcmp(d_fields, 'labels_type')) = false;
else                              label_type = [];
end

if     isfield(D, 'label_def'),  label_def = D.label_def;  field_unused(strcmp(d_fields, 'label_def')) = false;
elseif isfield(D, 'labels_def'), label_def = D.labels_def; field_unused(strcmp(d_fields, 'labels_def')) = false;
else                             label_def = [];
end

if     isfield(D, 'roi_names'),  roiNameList = D.roi_names;  field_unused(strcmp(d_fields, 'roi_names')) = false;
elseif isfield(D, 'rois_names'), roiNameList = D.rois_names; field_unused(strcmp(d_fields, 'rois_names')) = false;
else                             roiNameList = [];
end

if     isfield(D, 'roi_inds'),  roiIndList = D.roi_inds;  field_unused(strcmp(d_fields, 'roi_inds')) = false;
elseif isfield(D, 'rois_inds'), roiIndList = D.rois_inds; field_unused(strcmp(d_fields, 'rois_inds')) = false;
else                            roiIndList = [];
end

% Misc
numSample  = size(voxel_data, 1);   % Num of samples
numFeature = size(voxel_data, 2);   % Num of features (brain data)
numLabel   = size(label_data, 2);   % Num of labels
numDesign  = 2;                     % Num of design information (run and block)
numAddCols = numLabel + numDesign;  % Num of additional columns in dataset

%% dataset

if ~isfield(D, 'inds_blocks')
    error('convert_from_bdtb:IndsBlocksNotFound', ...
          '''inds_blocks'' was not found in ''D''');
else
    field_unused(strcmp(d_fields, 'inds_blocks')) = false;
end

if ~isfield(D, 'inds_runs')
    error('convert_from_bdtb:IndsRunsNotFound', ...
          '''inds_runs'' was not found in ''D''');
else
    field_unused(strcmp(d_fields, 'inds_runs')) = false;
end

blockData = convert_index(D.inds_blocks);
runData   = convert_index(D.inds_runs);

dataset = [ voxel_data, label_data, blockData', runData' ];

%% meta_data

% Data index
meta_data = NaN; % add_metadata initialize meta_data if meta_data == NaN
meta_data = add_metadata(meta_data, feature_key, feature_description, [ ones( 1, numFeature), zeros(1, numLabel), 0, 0 ]);
meta_data = add_metadata(meta_data, label_key,   label_description,   [ zeros(1, numFeature), ones( 1, numLabel), 0, 0 ]);
meta_data = add_metadata(meta_data, block_key,   block_description,   [ zeros(1, numFeature), zeros(1, numLabel), 1, 0 ]);
meta_data = add_metadata(meta_data, run_key,     run_description,     [ zeros(1, numFeature), zeros(1, numLabel), 0, 1 ]);

% fMRI data
if isfield(D, 'xyz')
    meta_data = add_metadata(meta_data, 'voxel_x', 'voxel x coordinate', [ D.xyz(1, :), nan(1, numAddCols) ]);
    meta_data = add_metadata(meta_data, 'voxel_y', 'voxel y coordinate', [ D.xyz(2, :), nan(1, numAddCols) ]);
    meta_data = add_metadata(meta_data, 'voxel_z', 'voxel z coordinate', [ D.xyz(3, :), nan(1, numAddCols) ]);

    field_unused(strcmp(d_fields, 'xyz')) = false;
end

% ROIs
for n = 1:length(roiNameList)
    roiName = roiNameList{n}; % Current ROI name
    roiInd  = roiIndList{n};  % Current ROI index

    roiDescpriton = sprintf('1 = in ROI %s; 0 = not in ROI %s', roiName, roiName);

    roiVector           = [ zeros(1, numFeature), nan(1, numAddCols) ];
    roiVector(roiInd) = 1;
    
    meta_data = add_metadata(meta_data, [ roi_prefix roiName ], roiDescpriton, roiVector);

    clear roiVector;
end

% Labels
for n = 1:length(label_type)
    meta_data_key                      = [ label_prefix label_type{n} ];
    meta_data_description              = '';
    meta_data_vector                   = [ nan(1, numFeature), zeros(1, numLabel), nan(1, 2) ];
    meta_data_vector( numFeature + n ) = 1;

    for t =1:length(label_def{n});
        meta_data_description = sprintf('%s%d = label %s; ', meta_data_description, t, label_def{n}{t});
    end
    if strcmp(meta_data_description(end), ' ')
        meta_data_description = meta_data_description(1:end);
    end
    
    meta_data = add_metadata(meta_data, meta_data_key, meta_data_description, meta_data_vector);
end

%% Display unused fields in D
discarded_fields = {};
c = 1;
for n = 1:length(field_unused)
    if field_unused(n)
        fprintf('Field %s in D is discarded.\n', d_fields{n});
        discarded_fields{c} = d_fields{n};
        c = c + 1;
    end
end
