classdef test_make_crossvalidationindex < matlab.unittest.TestCase
    methods (Test)
        function pass0001_kfold(testCase)

        testInput   = [ 1, 1, 2, 2, 3, 3 ]';
        expOutput_tr = logical([ 0 1 1;
                                 0 1 1;
                                 1 0 1;
                                 1 0 1;
                                 1 1 0;
                                 1 1 0 ]);
        expOutput_te = logical([ 1 0 0;
                                 1 0 0;
                                 0 1 0;
                                 0 1 0;
                                 0 0 1;
                                 0 0 1 ]);
        
        [ testOutput_tr, testOutput_te ] = make_crossvalidationindex( testInput );

        testCase.verifyEqual(testOutput_tr, expOutput_tr);
        testCase.verifyEqual(testOutput_te, expOutput_te);

        end

        function pass0002_kfold_largeData(testCase)

        testInput   = [ 1:5000 ]';
        expOutput_te = logical( diag(ones(size(testInput))) );
        expOutput_tr = ~expOutput_te;
        
        [ testOutput_tr, testOutput_te ] = make_crossvalidationindex( testInput );

        testCase.verifyEqual(testOutput_tr, expOutput_tr);
        testCase.verifyEqual(testOutput_te, expOutput_te);

        end
    end
end
