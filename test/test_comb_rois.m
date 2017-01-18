classdef test_comb_rois < matlab.unittest.TestCase

    properties

        dataTimeline = [ 1:10 ];

        metaData = struct('key',         {{ 'attr_A', 'attr_B', 'ROI_A','ROI_B', 'ROI_C'}}, ...
                          'description', {{ 'Test attribute A', ...
                                            'Test attribute B', ...
                                            'Test ROI A', ...
                                            'Test ROI B', ...
                                            'Test ROI C' }}, ...
                          'value',       [   1,   1,   1,   1,   1,   1,   1,   1,   1, NaN;
                                           NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN;
                                             1,   1,   1,   1,   1,   0,   0,   0,   0, NaN;
                                             0,   0,   0,   0,   0,   0,   0,   1,   1, NaN;
                                             1,   1,   1,   0,   0,   1,   1,   1,   0, NaN ]);
    end

    methods (Test)

        function comb_roi_pass0001(testCase)
            expOutput = [ 1, 1, 1, 1, 1, 0, 0, 1, 1, NaN ];
        
            metaData = comb_rois(testCase.metaData, ...
                                 'TEST0001', {'ROI_A', 'ROI_B'}, 'OR');

            testOutput = get_metadata(metaData, 'TEST0001');
            
            testCase.verifyEqual(testOutput, expOutput);
        end

        function comb_roi_pass0002(testCase)
            expOutput = [ 1, 1, 1, 0, 0, 0, 0, 0, 0, NaN ];
        
            metaData = comb_rois(testCase.metaData, ...
                                 'TEST0002', {'ROI_A', 'ROI_C'}, 'AND');

            testOutput = get_metadata(metaData, 'TEST0002');
            
            testCase.verifyEqual(testOutput, expOutput);
        end

        function comb_roi_pass0003(testCase)
            expOutput = [ 0, 0, 0, 1, 1, 0, 0, 0, 0, NaN ];
        
            metaData = comb_rois(testCase.metaData, ...
                                 'TEST0003', {'ROI_A', 'ROI_C'}, 'SUB');

            testOutput = get_metadata(metaData, 'TEST0003');
            
            testCase.verifyEqual(testOutput, expOutput);
        end

    end
end
