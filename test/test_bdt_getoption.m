classdef test_bdt_getoption < matlab.unittest.TestCase
    properties
        optDef = {{'scalar_key',  'scalar',  0}, ...
                  {'vector_key',  'vector',  [0, 1, 2]}, ...
                  {'matrix_key',  'matrix',  [0, 1, 2; 3, 4, 5]}, ...
                  {'string_key',  'string',  'hoge'}, ...
                  {'char_key',    'char',    'fuga'}, ...
                  {'logical_key', 'logical', true}, ...
                  {'onoff_key',   'onoff',   true}};
        expOpt = struct('scalar_key',  0, ...
                        'vector_key',  [0, 1, 2], ...
                        'matrix_key',  [0, 1, 2; 3, 4, 5], ...
                        'string_key',  'hoge', ...
                        'char_key',    'fuga', ...
                        'logical_key', true, ...
                        'onoff_key',   true);
    end
    
    methods (Test)
    function pass0001(testCase)
        % scalar
        testPattern(1).testArgs             = {'scalar_key', 100};
        testPattern(1).expOutput            = testCase.expOpt;
        testPattern(1).expOutput.scalar_key = 100;
 
        % vector (horizontal)
        testPattern(2).testArgs             = {'vector_key', [100, 200, 300]};
        testPattern(2).expOutput            = testCase.expOpt;
        testPattern(2).expOutput.vector_key = [100, 200, 300];
 
        % vector (vertical)
        testPattern(3).testArgs             = {'vector_key', [100, 200, 300]'};
        testPattern(3).expOutput            = testCase.expOpt;
        testPattern(3).expOutput.vector_key = [100, 200, 300]';
 
        % matrix
        testPattern(4).testArgs             = {'matrix_key', [100, 200, 300; 400, 500, 600]};
        testPattern(4).expOutput            = testCase.expOpt;
        testPattern(4).expOutput.matrix_key = [100, 200, 300; 400, 500, 600];
 
        % string
        testPattern(5).testArgs             = {'string_key', 'foo'};
        testPattern(5).expOutput            = testCase.expOpt;
        testPattern(5).expOutput.string_key = 'foo';
 
        % char
        testPattern(6).testArgs           = {'char_key', 'bar'};
        testPattern(6).expOutput          = testCase.expOpt;
        testPattern(6).expOutput.char_key = 'bar';
 
        % logical
        testPattern(7).testArgs              = {'logical_key', false};
        testPattern(7).expOutput             = testCase.expOpt;
        testPattern(7).expOutput.logical_key = false;
 
        % onoff (on)
        testPattern(8).testArgs            = {'onoff_key', 'on'};
        testPattern(8).expOutput           = testCase.expOpt;
        testPattern(8).expOutput.onoff_key = true;
 
        % onoff (off)
        testPattern(9).testArgs            = {'onoff_key', 'off'};
        testPattern(9).expOutput           = testCase.expOpt;
        testPattern(9).expOutput.onoff_key = false;
 
        % onoff (true)
        testPattern(10).testArgs            = {'onoff_key', true};
        testPattern(10).expOutput           = testCase.expOpt;
        testPattern(10).expOutput.onoff_key = true;
 
        % onoff (false)
        testPattern(11).testArgs            = {'onoff_key', false};
        testPattern(11).expOutput           = testCase.expOpt;
        testPattern(11).expOutput.onoff_key = false;
 
        for i = 1:length(testPattern)
            testFunc = @() bdt_getoption(testPattern(i).testArgs, testCase.optDef);
            testCase.verifyEqual(testFunc(), testPattern(i).expOutput);
        end
    end

    function pass0003_noargs(testCase)
        testArgs   = {};
        testOptDef = testCase.optDef;

        expOutput = testCase.expOpt;
    
        testFunc = @() bdt_getoption(testArgs, testOptDef);

        testCase.verifyEqual(testFunc(), expOutput);
    end

    function error0001_invalid_key(testCase)
        testArgs   = {'a', 100, 'invalid_key', 1000};
        testOptDef = testCase.optDef;

        testFunc = @() bdt_getoption(testArgs, testOptDef);

        testCase.verifyError(testFunc, 'bdt_getoption:InvalidOptionKey');
    end

    function error0002_invalid_args(testCase)
        testArgs   = {'a', 100, 'b' };
        testOptDef = testCase.optDef;

        testFunc = @() bdt_getoption(testArgs, testOptDef);

        testCase.verifyError(testFunc, 'bdt_getoption:InvalidArgs');
    end
    end
end
