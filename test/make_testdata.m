clear all;

%% normalize_sample
%addpath('/home/mu/aoki/work/BrainDecoderToolbox/decoder/trunk/user/decode_amh/general');
%addpath('/home/dni/aoki/work/BrainDecoderToolbox/decoder/trunk/user/decode_amh/utility');
%
%data = rand(500, 2000);
%
%group = [ones(100, 1) * 1;
%         ones(100, 1) * 2;
%         ones(100, 1) * 3;
%         ones(100, 1) * 4;
%         ones(100, 1) * 5];
%
%D.data = data;
%D.inds_runs = [  1, 100;
%               101, 200;
%               201, 300;
%               301, 400;
%               401, 500]';
%D.xyz = rand(3, size(data, 2));
%D.tvals = rand(1, size(data, 2));
%D.stat  = rand(1, size(data, 2));
%D.volInds = rand(1, size(data, 2));
%D.rois_inds_use = rand(1, size(data, 2));
%D.rois_inds = {};
%
%% Default
%[Dout, pars] = reduceOutliers(D)
%
%testData.reduce_outlier_default.inputData = D.data;
%testData.reduce_outlier_default.inputGroup = group;
%testData.reduce_outlier_default.outputData = Dout.data;
%
%% reduce_outliers
addpath('/home/mu/aoki/work/BrainDecoderToolbox/decoder/trunk/user/decode_amh/general');
addpath('/home/dni/aoki/work/BrainDecoderToolbox/decoder/trunk/user/decode_amh/utility');

data = rand(500, 2000);
for n = 1:1000
    data(randi(size(data, 1)), randi(size(data, 2))) = 5;
end

group = [ones(100, 1) * 1;
         ones(100, 1) * 2;
         ones(100, 1) * 3;
         ones(100, 1) * 4;
         ones(100, 1) * 5];

D.data = data;
D.inds_runs = [  1, 100;
               101, 200;
               201, 300;
               301, 400;
               401, 500]';
D.xyz = rand(3, size(data, 2));
D.tvals = rand(1, size(data, 2));
D.stat  = rand(1, size(data, 2));
D.volInds = rand(1, size(data, 2));
D.rois_inds_use = rand(1, size(data, 2));
D.rois_inds = {};

% Default
[Dout, pars] = reduceOutliers(D)

testData.reduce_outlier_default.inputData = D.data;
testData.reduce_outlier_default.inputGroup = group;
testData.reduce_outlier_default.outputData = Dout.data;

% Remove columns
pars.reduceOutliers.app_dim = 1;
pars.reduceOutliers.remove  = 1;

[Dout, pars] = reduceOutliers(D, pars)

testData.reduce_outlier_removeColumns.inputData = D.data;
testData.reduce_outlier_removeColumns.inputGroup = group;
testData.reduce_outlier_removeColumns.outputData = Dout.data;

%% Save test data
save('testdata_preproc.mat', 'testData');

