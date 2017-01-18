classdef test_convert_index < matlab.unittest.TestCase
    methods (Test)
    function pass0001_ind2label_row(testCase)
        testInput = [ 1 4 7;
              3 6 9 ];
        expOutput = [ 1 1 1 2 2 2 3 3 3 ];
    
        testFunc = @() convert_index(testInput);

        testCase.verifyEqual( testFunc(), expOutput );
    end

    function pass0002_ind2label_col(testCase)
        testInput = [ 1 3;
              4 6;
              7 9 ];
        expOutput = [ 1 1 1 2 2 2 3 3 3 ];
    
        testFunc = @() convert_index(testInput);

        testCase.verifyEqual( testFunc(), expOutput );
    end

    function pass0003_label2ind_row(testCase)
        testInput = [ 1 1 1 2 2 2 3 3 3 ];
        expOutput = [ 1 4 7;
              3 6 9 ];
    
        testFunc = @() convert_index(testInput);

        testCase.verifyEqual( testFunc(), expOutput );
    end

    function error0001_unsupported_index_format(testCase)
        testInput = [ 1 1 1;
              2 2 2;
              3 3 3 ];
    
        testFunc = @() convert_index(testInput);

        testCase.verifyError( testFunc, 'convert_index:UnsupportedIndexFormat' );
    end
    end
end
