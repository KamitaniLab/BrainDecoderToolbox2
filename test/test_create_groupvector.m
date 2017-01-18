classdef test_create_groupvector < matlab.unittest.TestCase
    methods (Test)
        function pass0001(testCase)
            testGroupLabel = [ 1, 2, 3 ];
            testGroupSize  = 1;
            expOutput = [ 1, 2, 3 ]';

            testFunc = @() create_groupvector(testGroupLabel, testGroupSize)

            testCase.verifyEqual( testFunc(), expOutput );
        end

        function pass0002(testCase)
            testGroupLabel = [ 1, 2, 3 ];
            testGroupSize  = 2;
            expOutput = [ 1, 1, 2, 2, 3 3 ]';

            testFunc = @() create_groupvector(testGroupLabel, testGroupSize)

            testCase.verifyEqual( testFunc(), expOutput );
        end

        function pass0003(testCase)
            testGroupLabel = [ 1, 2, 3 ];
            testGroupSize  = [ 2, 3, 2 ];
            expOutput = [ 1, 1, 2, 2, 2, 3 3 ]';

            testFunc = @() create_groupvector(testGroupLabel, testGroupSize)

            testCase.verifyEqual( testFunc(), expOutput );
        end
    end
end
