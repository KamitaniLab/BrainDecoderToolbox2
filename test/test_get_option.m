classdef test_get_option < matlab.unittest.TestCase
    properties
        optDef = { {'a', 'scalar',  0}, ...
                   {'b', 'strings', 'hoge' } };
        expOpt = struct('a', 0, ...
                        'b', 'hoge'); 
    end
    
    methods (Test)
    function pass0001(testCase)
        testArgs   = {'a', 100};
        testOptDef = testCase.optDef;

        expOutput   = testCase.expOpt;
        expOutput.a = 100;
    
        testFunc = @() get_option( testArgs, testOptDef );

        testCase.verifyEqual( testFunc(), expOutput );
    end

    function pass0002(testCase)
        testArgs   = {'a', 100, 'b', 'fuga'};
        testOptDef = testCase.optDef;

        expOutput   = testCase.expOpt;
        expOutput.a = 100;
        expOutput.b = 'fuga';
    
        testFunc = @() get_option( testArgs, testOptDef );

        testCase.verifyEqual( testFunc(), expOutput );
    end

    function pass0003_noargs(testCase)
        testArgs   = {};
        testOptDef = testCase.optDef;

        expOutput = testCase.expOpt;
    
        testFunc = @() get_option( testArgs, testOptDef );

        testCase.verifyEqual( testFunc(), expOutput );
    end

    function error0001_invalid_key(testCase)
        testArgs   = {'a', 100, 'invalid_key', 1000};
        testOptDef = testCase.optDef;

        expOutput = testCase.expOpt;
    
        testFunc = @() get_option( testArgs, testOptDef );

        testCase.verifyError( testFunc, 'get_option:InvalidKey' );
    end

    function error0001_invalid_args(testCase)
        testArgs   = {'a', 100, 'b' };
        testOptDef = testCase.optDef;

        expOutput = testCase.expOpt;
    
        testFunc = @() get_option( testArgs, testOptDef );

        testCase.verifyError( testFunc, 'get_option:InvalidArgs' );
    end
    end
end
