classdef test_bdata_remove_reduncol < matlab.unittest.TestCase

    properties
        dataSet = [     1, 101, 101, 101, 101, 201, 201, 301, 301, 401, 401, 501, 501 ;
                        2, 102, 102, 102, 999, 202, 202, 302, 302, 402, 402, 502, 502 ];
        mdValue = [     0,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1;
                        1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0;
                      NaN,  11,  11,  11,  11,  21,  21,  31,  31,  41,  41,  51,  51;
                      NaN,  12,  12,  12,  12,  22,  22, NaN,  32,   0,  42,   0,  52;
                      NaN,  13,  13,   0,  13,  23,  23,  33,  33,  43,  43,  53,   0];

        mdKey = { 'Signal', ...
                  'Run', ...
                  'metaData_A', ...
                  'metaData_B', ...
                  'metaData_C'};

        mdDesc = { 'Signal', ...
                   'Run', ...
                   'Test meta-data A', ...
                   'Test meta-data B', ...
                   'Test meta-data C' };

    end

    methods (Test)

        function remove_reduncol_pass0001(testCase)

        tInput.metaData.key = testCase.mdKey;
        tInput.metaData.description = testCase.mdDesc;
        tInput.metaData.value = testCase.mdValue;

        indSurvive = [1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13];
        
        eOutput.dataSet = testCase.dataSet(:, indSurvive);
        eOutput.metaData.value = testCase.mdValue(:, indSurvive);
        eOutput.metaData.key = testCase.mdKey;
        eOutput.metaData.description = testCase.mdDesc;

        
        [tOutput.dataSet, tOutput.metaData] = remove_reduncol(testCase.dataSet, tInput.metaData, ...
                                                                {'Signal', 'metaData_A', 'metaData_B', 'metaData_C'});

        testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
        testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

        function remove_reduncol_pass0002(testCase)

        tInput.metaData.key = testCase.mdKey;
        tInput.metaData.description = testCase.mdDesc;
        tInput.metaData.value = testCase.mdValue;

        indSurvive = [1, 2, 5, 6, 8, 9, 10, 11, 12, 13];
        
        eOutput.dataSet = testCase.dataSet(:, indSurvive);
        eOutput.metaData.value = testCase.mdValue(:, indSurvive);
        eOutput.metaData.key = testCase.mdKey;
        eOutput.metaData.description = testCase.mdDesc;

        
        [tOutput.dataSet, tOutput.metaData] = remove_reduncol(testCase.dataSet, tInput.metaData, ...
                                                                {'Signal', 'metaData_A', 'metaData_B'});

        testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
        testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

        function remove_reduncol_pass0003(testCase)

        tInput.metaData.key = testCase.mdKey;
        tInput.metaData.description = testCase.mdDesc;
        tInput.metaData.value = testCase.mdValue;

        indSurvive = [1, 2, 4, 5, 6, 9, 11, 12, 13];
        
        eOutput.dataSet = testCase.dataSet(:, indSurvive);
        eOutput.metaData.value = testCase.mdValue(:, indSurvive);
        eOutput.metaData.key = testCase.mdKey;
        eOutput.metaData.description = testCase.mdDesc;

        
        [tOutput.dataSet, tOutput.metaData] = remove_reduncol(testCase.dataSet, tInput.metaData, ...
                                                                {'Signal', 'metaData_A', 'metaData_C'});

        testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
        testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

        function remove_reduncol_pass0004(testCase)

        tInput.metaData.key = testCase.mdKey;
        tInput.metaData.description = testCase.mdDesc;
        tInput.metaData.value = testCase.mdValue;

        indSurvive = [1, 2, 5, 6, 9, 11, 12];
        
        eOutput.dataSet = testCase.dataSet(:, indSurvive);
        eOutput.metaData.value = testCase.mdValue(:, indSurvive);
        eOutput.metaData.value(:, end) = [ 1, 0, 51, 52, 53 ]';
        eOutput.metaData.key = testCase.mdKey;
        eOutput.metaData.description = testCase.mdDesc;

        
        [tOutput.dataSet, tOutput.metaData] = remove_reduncol(testCase.dataSet, tInput.metaData, ...
                                                                {'Signal', 'metaData_A'});

        testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
        testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

        function remove_reduncol_perfomance0001(testCase)

        tInput.dataSet = rand(1000, 3000);
        tInput.metaData.key = testCase.mdKey;
        tInput.metaData.description = testCase.mdDesc;
        tInput.metaData.value = rand(length(testCase.mdKey), 3000);

        eOutput.dataSet = tInput.dataSet;
        eOutput.metaData.key = tInput.metaData.key;
        eOutput.metaData.description = tInput.metaData.description;
        eOutput.metaData.value = tInput.metaData.value;

        tic
        [tOutput.dataSet, tOutput.metaData] = remove_reduncol(tInput.dataSet, tInput.metaData, ...
                                                                {'Signal', 'metaData_A'});
        toc

        testCase.verifyEqual(tOutput.dataSet, eOutput.dataSet);
        testCase.verifyEqual(tOutput.metaData, eOutput.metaData);
        end

    end
end
