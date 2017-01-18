classdef test_get_roiflag < matlab.unittest.TestCase
    methods (Test)
        function pass0001(testCase)
            testRoiXyz = { [  1  2;
                             11 12;
                             21 22 ] };
            testXyz = [  1  2  3  4  5;
                        11 12 13 14 15;
                        21 22 23 24 25 ];
            expOutput = logical([ 1, 1, 0, 0, 0 ]);

            testFunc = @() get_roiflag(testRoiXyz, testXyz);

            testCase.verifyEqual( testFunc(), expOutput );
        end

        function pass0002(testCase)
            testRoiXyz = { [  1  2;
                             11 12;
                             21 22 ],
                           [  4  5;
                             14 15;
                             24 25 ] };
            testXyz = [  1  2  3  4  5;
                        11 12 13 14 15;
                        21 22 23 24 25 ];
            expOutput = logical([ 1, 1, 0, 0, 0;
                                  0, 0, 0, 1, 1 ]);

            testFunc = @() get_roiflag(testRoiXyz, testXyz);

            testCase.verifyEqual( testFunc(), expOutput );
        end
    end
end
