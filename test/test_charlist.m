classdef test_charlist < matlab.unittest.TestCase
    methods (Test)
    function pass0001(testCase)
        testInput = 1:10;
        expOutput = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j' };
    
        testFunc = @() charlist(testInput);

        testCase.verifyEqual( testFunc(), expOutput );
    end
    end
end
