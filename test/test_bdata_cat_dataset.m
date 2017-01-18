classdef test_bdata_cat_dataset < matlab.unittest.TestCase

    properties
        dataSet = { [ 101, 102, 1, 1;
                      111, 112, 2, 1;
                      121, 122, 3, 2;
                      131, 132, 4, 2;
                      141, 142, 5, 3;
                      151, 152, 6, 3 ],
                    [ 201, 202, 1, 1;
                      211, 212, 2, 1;
                      221, 222, 3, 2;
                      231, 232, 4, 2;
                      241, 242, 5, 3;
                      251, 252, 6, 3 ] };

        metaData = struct('key',         {{ 'Signal', 'Block','Run', 'metaData_A', 'metaData_B'}}, ...
                          'description', {{ 'Signal', ...
                                            'Block', ...
                                            'Run', ...
                                            'Test meta-data A', ...
                                            'Test meta-data B' }}, ...
                          'value',       [   1   1   0   0;
                                             0   0   1   0;
                                             0   0   0   1;
                                           0.1 0.2 NaN NaN;
                                           NaN NaN  10 NaN]);
    end

    methods (Test)

        function cat_dataset_pass0001(testCase)

            eOutput.dataSet = [testCase.dataSet{1}; testCase.dataSet{2}];
            eOutput.metaData = testCase.metaData;

            [tOutput.dataSet, tOutput.metaData] = cat_dataset(testCase.dataSet{1}, testCase.metaData, ...
                                                              testCase.dataSet{2}, testCase.metaData);
            testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
            testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

        function cat_dataset_pass0002(testCase)

            eOutput.dataSet = [testCase.dataSet{1}; testCase.dataSet{2}; testCase.dataSet{1}];
            eOutput.metaData = testCase.metaData;

            [tOutput.dataSet, tOutput.metaData] = cat_dataset(testCase.dataSet{1}, testCase.metaData, ...
                                                              testCase.dataSet{2}, testCase.metaData, ...
                                                              testCase.dataSet{1}, testCase.metaData);
            testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
            testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

        function cat_dataset_pass0003(testCase)

            eOutput.dataSet = [ 101, 102, 1, 1;
                                111, 112, 2, 1;
                                121, 122, 3, 2;
                                131, 132, 4, 2;
                                141, 142, 5, 3;
                                151, 152, 6, 3;
                                201, 202, 1, 4;
                                211, 212, 2, 4;
                                221, 222, 3, 5;
                                231, 232, 4, 5;
                                241, 242, 5, 6;
                                251, 252, 6, 6 ];
            eOutput.metaData = testCase.metaData;

            [tOutput.dataSet, tOutput.metaData] = cat_dataset(testCase.dataSet{1}, testCase.metaData, ...
                                                              testCase.dataSet{2}, testCase.metaData, ...
                                                              'IncrementColumn', 'Run');
            testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
            testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

        function cat_dataset_pass0004(testCase)

            eOutput.dataSet = [ 101, 102,  1, 1;
                                111, 112,  2, 1;
                                121, 122,  3, 2;
                                131, 132,  4, 2;
                                141, 142,  5, 3;
                                151, 152,  6, 3;
                                201, 202,  7, 4;
                                211, 212,  8, 4;
                                221, 222,  9, 5;
                                231, 232, 10, 5;
                                241, 242, 11, 6;
                                251, 252, 12, 6 ];
            eOutput.metaData = testCase.metaData;

            [tOutput.dataSet, tOutput.metaData] = cat_dataset(testCase.dataSet{1}, testCase.metaData, ...
                                                              testCase.dataSet{2}, testCase.metaData, ...
                                                              'IncrementColumn', {'Run', 'Block'});
            testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
            testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

    end
end
