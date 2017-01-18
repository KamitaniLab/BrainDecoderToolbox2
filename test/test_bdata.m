classdef test_bdata < matlab.unittest.TestCase
%
% This test provides unit tests for the following functions:
%
% - add_dataset
% - get_dataset
% - join_dataset
% - get_metadata
%

    properties

        dataTimeline = [ 101, 102,  1;
                         111, 112,  2;
                         121, 122,  3;
                         131, 132,  4;
                         141, 142,  5 ];

        metaData = struct('key',         {{ 'attr_A', 'attr_B','metaData_C', 'metaData_D'}}, ...
                          'description', {{ 'Test attribute A', ...
                                            'Test attribute B', ...
                                            'Test meta-data C', ...
                                            'Test meta-data D' }}, ...
                          'value',       [   1   1   0;
                                             0   0   1;
                                           0.1 0.2 NaN;
                                           NaN NaN  10 ]);
    end

    methods (Test)

        function add_dataset_pass0001(testCase)
            tInput.x         = rand(5, 3);
            tInput.attribute = 'attr_A';

            eOutput.dt = [ testCase.dataTimeline, tInput.x ];
            eOutput.md = testCase.metaData;
            eOutput.md.value = [ testCase.metaData.value(1, :),   1   1   1 ;
                                 testCase.metaData.value(2, :), NaN NaN NaN ;
                                 testCase.metaData.value(3, :), NaN NaN NaN ;
                                 testCase.metaData.value(4, :), NaN NaN NaN ];

            [ tOutput.dt tOutput.md ] = add_dataset(testCase.dataTimeline, testCase.metaData, ...
                                                    tInput.x, tInput.attribute);

            testCase.verifyEqual(tOutput.dt, eOutput.dt);
            testCase.verifyEqual(tOutput.md, eOutput.md);
        end

        function add_dataset_pass0002(testCase)
            tInput.x         = rand(5, 3);
            tInput.attribute = 'attr_B';

            eOutput.dt = [ testCase.dataTimeline, tInput.x ];
            eOutput.md = testCase.metaData;
            eOutput.md.value = [ testCase.metaData.value(1, :), NaN NaN NaN ;
                                 testCase.metaData.value(2, :),   1   1   1 ;
                                 testCase.metaData.value(3, :), NaN NaN NaN ;
                                 testCase.metaData.value(4, :), NaN NaN NaN ];

            [ tOutput.dt tOutput.md ] = add_dataset(testCase.dataTimeline, testCase.metaData, ...
                                                    tInput.x, tInput.attribute);

            testCase.verifyEqual(tOutput.dt, eOutput.dt);
            testCase.verifyEqual(tOutput.md, eOutput.md);
        end

        function add_dataset_pass0003(testCase)
            tInput.x         = rand(5, 3);
            tInput.attribute = 'attr_NotInMetaData';

            eOutput.dt = [ testCase.dataTimeline, tInput.x ];
            eOutput.md = testCase.metaData;
            eOutput.md.key{end+1} = 'attr_NotInMetaData';
            eOutput.md.description{end+1} = '1 = attr_NotInMetaData';
            eOutput.md.value = [ testCase.metaData.value(1, :), NaN, NaN, NaN ;
                                 testCase.metaData.value(2, :), NaN, NaN, NaN ;
                                 testCase.metaData.value(3, :), NaN, NaN, NaN ;
                                 testCase.metaData.value(4, :), NaN, NaN, NaN ;
                                 nan(1, 3),                       1,   1,   1 ];

            [ tOutput.dt tOutput.md ] = add_dataset(testCase.dataTimeline, testCase.metaData, ...
                                                    tInput.x, tInput.attribute);

            testCase.verifyEqual(tOutput.dt, eOutput.dt);
            testCase.verifyEqual(tOutput.md, eOutput.md);
        end

        function get_dataset_pass0001(testCase)
            tInput.key   = 'attr_A';
            tInput.value = 1;

            eOutput = [ 101, 102;
                        111, 112;
                        121, 122;
                        131, 132;
                        141, 142 ];
            
            tFunc = @() get_dataset(testCase.dataTimeline, testCase.metaData, tInput.key, tInput.value);

            testCase.verifyEqual(tFunc(), eOutput);

        end

        function get_dataset_pass0002(testCase)
            tInput.key   = 'attr_A';
            tInput.value = 0;

            eOutput = [ 1, 2, 3, 4, 5 ]';
            
            tFunc = @() get_dataset(testCase.dataTimeline, testCase.metaData, tInput.key, tInput.value);

            testCase.verifyEqual(tFunc(), eOutput);
        end

        function get_dataset_pass0003(testCase)
            tInput.key = 'attr_A';

            eOutput = [ 101, 102;
                        111, 112;
                        121, 122;
                        131, 132;
                        141, 142 ];
            
            tFunc = @() get_dataset(testCase.dataTimeline, testCase.metaData, tInput.key);

            testCase.verifyEqual(tFunc(), eOutput);
        end

        function get_dataset_pass0004(testCase)
            tInput.key = 'key_not_found';

            eOutput = [];
            
            tFunc = @() get_dataset(testCase.dataTimeline, testCase.metaData, tInput.key);

            testCase.verifyWarning(tFunc, 'get_metadata:KeyNotFound');
            testCase.verifyEqual(tFunc(), eOutput);

        end

        function join_dataset_pass0001(testCase)
            tInput.dt = [ 201:205, 1, 1;
                          211:215, 2, 2;
                          221:225, 3, 2;
                          231:235, 4, 3;
                          241:245, 5, 3];

            tInput.md = struct( ...
                'key', {{ 'attr_A', 'attr_B', 'attr_X', 'metaData_C', 'metaData_Y'}}, ...
                'description', {{ 'Test attribute A', ...
                                  'Test attribute B', ...
                                  'Test attribute X', ...
                                  'Test meta-data C', ...
                                  'Test meta-data Y' }}, ...
                'value',       [   1   1   1   1   1   0   0 ;
                                   0   0   0   0   0   1   1 ;
                                   0   0   0   0   0   0   1 ;
                                 0.1 0.2 0.3 0.4 0.5 NaN NaN ;
                                 NaN NaN NaN NaN NaN NaN  20 ] );

            eOutput.dt = [ testCase.dataTimeline, tInput.dt ];
            eOutput.md = testCase.metaData;
            eOutput.md.key = { eOutput.md.key{:}, 'attr_X', 'metaData_Y' };
            eOutput.md.description = { eOutput.md.description{:}, 'Test attribute X', 'Test meta-data Y' };
            eOutput.md.value = testCase.metaData.value;
            eOutput.md.value = [ eOutput.md.value(1, :),   1,   1,   1,   1,   1,   0,   0 ;
                                 eOutput.md.value(2, :),   0,   0,   0,   0,   0,   1,   1 ;
                                 eOutput.md.value(3, :), 0.1, 0.2, 0.3, 0.4, 0.5, NaN, NaN ;
                                 eOutput.md.value(4, :), NaN, NaN, NaN, NaN, NaN, NaN, NaN ;
                                 NaN(1, 3),                0,   0,   0,   0,   0,   0,   1 ; 
                                 NaN(1, 3),              NaN, NaN, NaN, NaN, NaN, NaN,  20 ];
            
            [ tOutput.dt tOutput.md ] = join_dataset(testCase.dataTimeline, testCase.metaData, ...
                                                     tInput.dt, tInput.md);
            
            testCase.verifyEqual(tOutput.dt, eOutput.dt);
            testCase.verifyEqual(tOutput.md, eOutput.md);
        end
        
        function get_metadata_pass0001(testCase)
            tInput.key = 'metaData_C';

            eOutput = [0.1, 0.2, NaN];
            
            tFunc = @() get_metadata(testCase.metaData, tInput.key);
            tOutput = tFunc();
            
            testCase.verifyEqual(tOutput, eOutput);
        end

        function get_metadata_pass0002(testCase)
            tInput.key = 'metaData_C';
            tInput.opt = '-i';
            
            eOutput = [true, true, false];
            
            tFunc = @() get_metadata(testCase.metaData, tInput.key, tInput.opt);
            tOutput = tFunc();
            
            testCase.verifyEqual(tOutput, eOutput);
        end

        function get_metadata_pass0003(testCase)
            tInput.key = 'metaData_C';
            tInput.opt = '-n';
            
            eOutput = [0.1, 0.2];
            
            tFunc = @() get_metadata(testCase.metaData, tInput.key, tInput.opt);
            tOutput = tFunc();
            
            testCase.verifyEqual(tOutput, eOutput);
        end

    end
end
