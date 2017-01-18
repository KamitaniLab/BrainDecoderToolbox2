classdef test_reshaperow < matlab.unittest.TestCase
    methods (Test)
        function pass0001(testCase)
        % Reshape to 2-d array (matrix), horizontal vector as input
            
            test_x = [ 1, 2, 3, 4, 5, 6 ];
            test_size = [ 2, 3 ];

            exp_output = [ 1, 2, 3;
                           4, 5, 6 ];

            test_output = reshaperow(test_x, test_size);

            testCase.verifyEqual(test_output, exp_output);
        end

        function pass0002(testCase)
        % Reshape to 2-d array (matrix), vertical vector as input

            test_x = [ 1, 2, 3, 4, 5, 6 ]';
            test_size = [ 2, 3 ];

            exp_output = [ 1, 2, 3;
                           4, 5, 6 ];

            test_output = reshaperow(test_x, test_size);

            testCase.verifyEqual(test_output, exp_output);
        end

        function pass0003(testCase)
        % Reshape to 3-d array
            
            test_x = [ 1, 2, 3, 4, 5, 6, 7, 8 ];
            test_size = [ 2, 2, 2 ];

            exp_output(1, 1, :) = [ 1, 2 ];
            exp_output(1, 2, :) = [ 3, 4 ];
            exp_output(2, 1, :) = [ 5, 6 ];
            exp_output(2, 2, :) = [ 7, 8 ];

            test_output = reshaperow(test_x, test_size);

            testCase.verifyEqual(test_output, exp_output);
        end
    end
end
