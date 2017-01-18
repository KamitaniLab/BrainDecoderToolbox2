classdef test_combcat < matlab.unittest.TestCase
    methods (Test)
    function pass0001(testCase)
        testInput = {'a', {'x', 'y', 'z'}};
        expOutput = { 'ax', 'ay', 'az' };

        testFunc = @() combcat('a', {'x', 'y', 'z'});

        testCase.verifyEqual( testFunc(), expOutput );
    end
    end
end
