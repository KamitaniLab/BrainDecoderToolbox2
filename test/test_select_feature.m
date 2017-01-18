classdef test_select_feature < matlab.unittest.TestCase

    properties
        dataSet = rand(3, 10);
        metaData = struct('key', {{ 'VoxelData', ...
                                    'Stat_P', ...
                                    'ROI_A', ...
                                    'ROI_B', ...
                                    'ROI_C' }}, ...
                          'description', {{ '', '', '', '' }}, ...
                          'value', [
                              1   1   1   1   1   1   1   1   1   1;
                              5   7   9   10  2   8   1   3   4   6;
                              1   1   1   0   0   0   0   0   0   0; % [ 1, 2, 3]
                              0   0   0   1   1   0   1   1   0   0; % [ 4, 5, 7, 8]
                              0   1   0   1   0   1   0   1   0   1; % [ 2, 4, 6, 8, 10]

                   ]);
    end

    methods (Test)

        function select_feature_pass0001(testCase)
        selectExpr = 'ROI_A = 1';

        expOutput  = testCase.dataSet(:, [ 1, 2, 3 ]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0002(testCase)
        selectExpr = 'ROI_A = 1 | ROI_B = 1';

        expOutput  = testCase.dataSet(:, [ 1, 2, 3, 4, 5, 7, 8]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0003(testCase)
        selectExpr = 'ROI_B = 1 & ROI_C = 1';

        expOutput  = testCase.dataSet(:, [ 4, 8 ]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0004(testCase)
        selectExpr = 'ROI_A = 1 | ROI_B = 1 & ROI_C = 1';

        expOutput  = testCase.dataSet(:, [2, 4, 8]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0005(testCase)
        selectExpr = 'ROI_C = 1 & ROI_B = 1 | ROI_A = 1';

        expOutput  = testCase.dataSet(:, [1, 2, 3, 4, 8]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0006(testCase)
        selectExpr = 'ROI_C = 1 & (ROI_B = 1 | ROI_A = 1)';

        expOutput  = testCase.dataSet(:, [2, 4, 8]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0101(testCase)
        selectExpr = 'Stat_P top 3';

        expOutput  = testCase.dataSet(:, [3, 4, 6]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0102(testCase)
        selectExpr = 'Stat_P top 5';

        expOutput  = testCase.dataSet(:, [2, 3, 4, 6, 10]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0103(testCase)
        selectExpr = 'Stat_P top 0';

        expOutput  = ones(3, 0);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0104(testCase)
        selectExpr = 'ROI_A = 1 & Stat_P top 5';

        expOutput  = testCase.dataSet(:, [2, 3]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0105(testCase)
        selectExpr = 'ROI_A = 1 | Stat_P top 3';

        expOutput  = testCase.dataSet(:, [1, 2, 3, 4, 6]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0106(testCase)
        selectExpr = 'Stat_P top 3 @ ROI_C = 1';

        expOutput  = testCase.dataSet(:, [2, 4, 6]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0107(testCase)
        selectExpr = 'Stat_P top 3 @ (ROI_A = 1 | ROI_C = 1)';

        expOutput  = testCase.dataSet(:, [3, 4, 6]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

        function select_feature_pass0108(testCase)
        selectExpr = 'Stat_P top 3 @ ROI_A = 1 | ROI_C = 1';

        expOutput  = testCase.dataSet(:, [3, 4, 6]);
        testOutput = select_feature(testCase.dataSet, testCase.metaData, selectExpr);

        testCase.verifyEqual(testOutput, expOutput);
        end

    end
end
