classdef test_fastcorr < matlab.unittest.TestCase
% Test class for stats/fastcorr
%

properties
    xVec = rand(20, 1);
    yVec = rand(20, 1);

    xMat = rand(100, 50);
    yMat = rand(100, 50);

    tol = 1e-15;
end

methods(Test)

    function vector_singlematrix(testCase)
        testOutput = fastcorr(testCase.xMat);
        expOutput = corr(testCase.xMat);
        testCase.verifyEqual(testOutput, expOutput, 'AbsTol', testCase.tol);
    end

    function vector_twovectors(testCase)
        testOutput = fastcorr(testCase.xMat, testCase.yMat);
        expOutput = corr(testCase.xMat, testCase.yMat);
        testCase.verifyEqual(testOutput, expOutput, 'AbsTol', testCase.tol);
    end

end

end