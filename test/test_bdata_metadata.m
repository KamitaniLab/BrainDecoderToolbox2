classdef test_bdata_metadata < matlab.unittest.TestCase
%
% This test provides unit tests for the following functions:
%
% - add_metadata
% - get_metadata
% - rename_metadata
%

    properties
        metaData = struct('key',         {{ 'a'; 'b'; 'c'; 'd'}}, ...
                          'description', {{ ' Test data A'; 'Test data B'; 'Test data C'; 'Test data D' }}, ...
                          'value',       [   1   1   1   1   1   0   0   0   0   0 ;
                                             0   0   0   0   0   1   1   1   1   1 ;
                                           0.1 0.2 0.3 0.4 0.5 NaN NaN NaN NaN NaN ;
                                             1   1   1   0   0 NaN NaN NaN NaN NaN ]);
        metaDataLength = 10;

    end

    methods (Test)

        function add_metadata_pass0001(testCase)

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'x';
        testInput_description = 'Test input x';
        testInput_value       = [ 1:testCase.metaDataLength ];

        expOutput                      = testInput_metaData;
        expOutput.key{end + 1}         = testInput_key;
        expOutput.description{end + 1} = testInput_description;
        expOutput.value(end + 1, :)    = testInput_value;

        testFunc = @() add_metadata(testInput_metaData, testInput_key, testInput_description, testInput_value);

        testCase.verifyEqual(testFunc(), expOutput);

        end

        function add_metadata_pass0002(testCase)

        testInput_metaData    = NaN;
        testInput_key         = 'x';
        testInput_description = 'Test input x';
        testInput_value       = [ 1:testCase.metaDataLength ];

        expOutput = struct('key',         {{ testInput_key         }}, ...
                           'description', {{ testInput_description }}, ...
                           'value',       testInput_value);

        testFunc = @() add_metadata(testInput_metaData, testInput_key, testInput_description, testInput_value);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function add_metadata_pass0003(testCase)

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'a';
        testInput_description = 'Test A (overwrite)';
        testInput_value       = [ 1:testCase.metaDataLength ];

        expOutput = testInput_metaData;

        ind = strcmp(testInput_key, expOutput.key);
        
        expOutput.key{ind}         = testInput_key;
        expOutput.description{ind} = testInput_description;
        expOutput.value(ind, :)    = testInput_value;

        testFunc = @() add_metadata(testInput_metaData, testInput_key, testInput_description, testInput_value);
        
        testCase.verifyEqual(testFunc(), expOutput);
        testCase.verifyWarning(testFunc, 'add_metadata:OverwriteMetaData');
        
        end

        function add_metadata_pass0004(testCase)

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'x';
        testInput_description = 'Test input x';
        testInput_value       = [ 1, 2, 3, 4, 5 ];
        testInput_attr        = 'a';

        expOutput                      = testInput_metaData;
        expOutput.key{end + 1}         = testInput_key;
        expOutput.description{end + 1} = testInput_description;
        expOutput.value(end + 1, :)    = [ testInput_value, NaN, NaN, NaN, NaN, NaN ];

        testFunc = @() add_metadata(testInput_metaData, testInput_key, testInput_description, testInput_value, testInput_attr);
        
        testCase.verifyEqual(testFunc(), expOutput);
        
        end

        function add_metadata_pass0005(testCase)

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'd';
        testInput_description = 'Test D';
        testInput_value       = [ 1:5 ];
        testInput_attr        = 'b';

        expOutput = testInput_metaData;

        ind = strcmp(testInput_key, expOutput.key);
        
        expOutput.key{ind}         = testInput_key;
        expOutput.description{ind} = testInput_description;
        expOutput.value(ind, 6:10)  = testInput_value;

        testFunc = @() add_metadata(testInput_metaData, testInput_key, testInput_description, testInput_value, testInput_attr);
        
        testCase.verifyEqual(testFunc(), expOutput);
        
        end

        function get_metadata_pass0001(testCase)

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'a';

        expOutput = [   1   1   1   1   1   0   0   0   0   0 ];

        testFunc = @() get_metadata(testInput_metaData, testInput_key);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end
        
        function get_metadata_pass0002(testCase)
        % Key did not found

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'x';

        expOutput = [];

        testFunc = @() get_metadata(testInput_metaData, testInput_key);
        
        testCase.verifyEqual(testFunc(), expOutput);
        testCase.verifyWarning(testFunc, 'get_metadata:KeyNotFound' );

        end

        function get_metadata_pass0003(testCase)
        % Found more than two keys
            
        testInput_metaData    = testCase.metaData;
        testInput_key         = 'a';
        testInput_description = 'Test A (duplicate)';
        testInput_value       = [ 1:testCase.metaDataLength ];

        testInput_metaData.key{end + 1}         = testInput_key;
        testInput_metaData.description{end + 1} = testInput_description;
        testInput_metaData.value(end + 1, :)    = testInput_value;

        expOutput = [ 1 1 1 1 1 0 0 0 0 0 ;
                      testInput_value ];

        testFunc = @() get_metadata(testInput_metaData, testInput_key);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0004(testCase)
        % Option 'as_index'
            
        testInput_metaData    = testCase.metaData;
        testInput_key         = 'a';

        expOutput = logical([ 1 1 1 1 1 0 0 0 0 0 ]);

        testFunc = @() get_metadata(testInput_metaData, testInput_key, 'as_index');
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0005(testCase)
        % Option 'as_index'

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'd';

        expOutput = logical([ 1 1 1 0 0 0 0 0 0 0 ]);

        testFunc = @() get_metadata(testInput_metaData, testInput_key, 'as_index');
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0006(testCase)
        % Option 'AsIndex'

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'a';

        expOutput = logical([ 1 1 1 1 1 0 0 0 0 0 ]);

        testFunc = @() get_metadata(testInput_metaData, testInput_key, 'AsIndex', true);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0007(testCase)
        % Option 'RemoveNan'

        testInput_metaData    = testCase.metaData;
        testInput_key         = 'd';

        expOutput = [ 1 1 1 0 0 ];

        testFunc = @() get_metadata(testInput_metaData, testInput_key, 'RemoveNan', true);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0008(testCase)
        % Multiple keys specified
            
        testInput_metaData    = testCase.metaData;
        testInput_key         = {'a', 'b'};

        expOutput = [ 1   1   1   1   1   0   0   0   0   0 ;
                      0   0   0   0   0   1   1   1   1   1 ];

        testFunc = @() get_metadata(testInput_metaData, testInput_key);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0009(testCase)
        % Multiple keys specified + AsIndex

        testInput_metaData    = testCase.metaData;
        testInput_key         = {'a', 'b'};

        expOutput = logical([ 1   1   1   1   1   0   0   0   0   0 ;
                              0   0   0   0   0   1   1   1   1   1 ]);

        testFunc = @() get_metadata(testInput_metaData, testInput_key, 'AsIndex', true);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0010(testCase)
        % Multiple keys specified + RemoveNan

        testInput_metaData    = testCase.metaData;
        testInput_key         = {'c', 'd'};

        expOutput = [ 0.1 0.2 0.3 0.4 0.5;
                      1   1   1   0   0 ];

        testFunc = @() get_metadata(testInput_metaData, testInput_key, 'RemoveNan', true);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0011(testCase)
        % AsIndex

        testInput_metaData    = testCase.metaData;
        testInput_key         = {'d'};

        expOutput = logical([ 1 1 1 0 0 0 0 0 0 0 ]);

        testFunc = @() get_metadata(testInput_metaData, testInput_key, 'AsIndex', true);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function get_metadata_pass0012(testCase)
        % AsIndex + RemoveNan

        testInput_metaData    = testCase.metaData;
        testInput_key         = {'d'};

        expOutput = logical([ 1   1   1   0   0 ]);

        testFunc = @() get_metadata(testInput_metaData, testInput_key, 'AsIndex', true, 'RemoveNan', true);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function rename_metadata_pass0001(testCase)

        testInput_metaData    = testCase.metaData;
        testInput_keyOld      = 'a';
        testInput_keyNew      = 'a_new';

        expOutput        = testCase.metaData;
        expOutput.key{1} = testInput_keyNew;

        testFunc = @() rename_metadata(testInput_metaData, testInput_keyOld, testInput_keyNew);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function rename_metadata_pass0002(testCase)

        testInput_metaData    = testCase.metaData;
        testInput_keyOld      = 'key_not_found';
        testInput_keyNew      = 'key_not_found_new';

        expOutput        = testCase.metaData;

        testFunc = @() rename_metadata(testInput_metaData, testInput_keyOld, testInput_keyNew);

        testCase.verifyWarning(testFunc, 'rename_metadata:KeyNotFound' );
        testCase.verifyEqual(testFunc(), expOutput);

        end

        function rename_metadata_pass0003(testCase)

        testInput_metaData    = testCase.metaData;
        testInput_keyOld      = 'a';
        testInput_description = 'Test A (duplicate)';
        testInput_value       = [ 1:testCase.metaDataLength ];
        testInput_keyNew      = 'a_new';

        testInput_metaData.key{end + 1}         = testInput_keyOld;
        testInput_metaData.description{end + 1} = testInput_description;
        testInput_metaData.value(end + 1, :)    = testInput_value;

        expOutput          = testInput_metaData;
        expOutput.key{1}   = testInput_keyNew;
        expOutput.key{end} = testInput_keyNew;

        testFunc = @() rename_metadata(testInput_metaData, testInput_keyOld, testInput_keyNew);
        
        testCase.verifyEqual(testFunc(), expOutput);

        end
    end
end
