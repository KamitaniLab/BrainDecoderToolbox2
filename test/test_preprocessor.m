classdef test_preprocessor < matlab.unittest.TestCase

    properties
        %data = testData();
    end

    methods (Test)

    function average_sample_pass0001(testCase)
        x = rand(13, 10);
        g = [ 1; 1; 1; 1;
              2; 2;
              3; 3;
              4; 4;
              5; 5; 5 ];

        expData = [ mean(x(1:4, :), 1);
                    mean(x(5:6, :), 1);
                    mean(x(7:8, :), 1);
                    mean(x(9:10, :), 1);
                    mean(x(11:13, :), 1) ];
        expGrp  = [ 1; 5; 7; 9; 11 ];

        testFunc = @() average_sample(x, g);
        [testData, testGrp] = testFunc();

        testCase.verifyEqual(testData, expData);
        testCase.verifyEqual(testGrp, expGrp);
    end

    function average_sample_newInput_default(testCase)
        x = rand(13, 10);

        expData = mean(x, 1);
        expGrp  = 1;

        testFunc = @() average_sample(x);
        [testData, testGrp] = testFunc();

        testCase.verifyEqual(testData, expData);
        testCase.verifyEqual(testGrp, expGrp);
    end

    function average_sample_newInput_optGroup(testCase)
        x = rand(13, 10);
        g = [ 1; 1; 1; 1;
              2; 2;
              3; 3;
              4; 4;
              5; 5; 5 ];

        expData = [ mean(x(1:4, :), 1);
                    mean(x(5:6, :), 1);
                    mean(x(7:8, :), 1);
                    mean(x(9:10, :), 1);
                    mean(x(11:13, :), 1) ];
        expGrp  = [ 1; 5; 7; 9; 11 ];

        testFunc = @() average_sample(x, 'Group', g);
        [testData, testGrp] = testFunc();

        testCase.verifyEqual(testData, expData);
        testCase.verifyEqual(testGrp, expGrp);
    end

    function detrend_sample_pass0001(testCase)
        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        expData = [ detrend(x(1:5, :), 'linear') + repmat(mean(x(1:5, :), 1), 5, 1);
                    detrend(x(6:10, :), 'linear') + repmat(mean(x(6:10, :), 1), 5, 1) ];

        testFunc = @() detrend_sample(x, g);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function detrend_sample_newInput_default(testCase)
        x = rand(10, 5);

        expData = [detrend(x, 'linear') + repmat(mean(x, 1), 10, 1)];

        testFunc = @() detrend_sample(x);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function detrend_sample_newInput_optionGroup(testCase)
        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        expData = [ detrend(x(1:5, :), 'linear') + repmat(mean(x(1:5, :), 1), 5, 1);
                    detrend(x(6:10, :), 'linear') + repmat(mean(x(6:10, :), 1), 5, 1) ];

        testFunc = @() detrend_sample(x, 'Group', g);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function highpass_filter_pass0001(testCase)
        % Default
        sf = 1;
        cf = 0.01;
        order = 4;

        % Data length should be > 12
        x = rand(40, 5);
        g = [ ones(20, 1);
              2 * ones(20, 1) ];

        [b, a] = butter(order, cf / (sf / 2), 'high');
        expData = [ filtfilt(b, a, x(1:20, :));
                    filtfilt(b, a, x(21:40, :)) ];

        testFunc = @() highpass_filter(x, g);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end
    
    function highpass_filter_pass0002(testCase)
        % Keep DC
        sf = 1;
        cf = 0.01;
        order = 4;

        % Data length should be > 12
        x = rand(40, 5);
        g = [ ones(20, 1);
              2 * ones(20, 1) ];

        [b, a] = butter(order, cf / (sf / 2), 'high');
        expData = [ repmat(mean(x(1:20, :), 1), 20, 1) + filtfilt(b, a, x(1:20, :));
                    repmat(mean(x(21:40, :), 1), 20, 1) + filtfilt(b, a, x(21:40, :)) ];

        testFunc = @() highpass_filter(x, g, 'KeepDc', true);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end
    
    function highpass_filter_newInput_default(testCase)
        % Default
        sf = 1;
        cf = 0.01;
        order = 4;

        % Data length should be > 12
        x = rand(40, 5);
        g = [ ones(20, 1);
              2 * ones(20, 1) ];

        [b, a] = butter(order, cf / (sf / 2), 'high');
        expData = [ filtfilt(b, a, x(1:20, :));
                    filtfilt(b, a, x(21:40, :)) ];

        testFunc = @() highpass_filter(x, 'Group', g);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end
    
    function highpass_filter_newInput_keepDC(testCase)
        % Keep DC
        sf = 1;
        cf = 0.01;
        order = 4;

        % Data length should be > 12
        x = rand(40, 5);
        g = [ ones(20, 1);
              2 * ones(20, 1) ];

        [b, a] = butter(order, cf / (sf / 2), 'high');
        expData = [ repmat(mean(x(1:20, :), 1), 20, 1) + filtfilt(b, a, x(1:20, :));
                    repmat(mean(x(21:40, :), 1), 20, 1) + filtfilt(b, a, x(21:40, :)) ];

        testFunc = @() highpass_filter(x, 'Group', g, 'KeepDc', true);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end
    
    function normalize_sample_pass0001(testCase)
    % Default (PercentSignalChange, whole data in group as base line)
        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        mA = repmat(mean(x(1:5, :), 1), 5, 1);
        mB = repmat(mean(x(6:10, :), 1), 5, 1);
        
        expData = [ 100 * (x(1:5, :) - mA) ./ mA;
                    100 * (x(6:10, :) - mB) ./ mB ];

        testFunc = @() normalize_sample(x, g);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_pass0002(testCase)
    % Zscore, whole data in group as base line
        mode = 'Zscore';

        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        mA = repmat(mean(x(1:5, :), 1), 5, 1);
        mB = repmat(mean(x(6:10, :), 1), 5, 1);
        sA = repmat(std(x(1:5, :), 0, 1), 5, 1);
        sB = repmat(std(x(6:10, :), 0, 1), 5, 1);
        
        expData = [ (x(1:5, :) - mA) ./ sA;
                    (x(6:10, :) - mB) ./ sB ];

        testFunc = @() normalize_sample(x, g, 'Mode', mode);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_pass0003(testCase)
    % DivideMean, whole data in group as base line
        mode = 'DivideMean';

        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        mA = repmat(mean(x(1:5, :), 1), 5, 1);
        mB = repmat(mean(x(6:10, :), 1), 5, 1);

        expData = [ 100 * x(1:5, :) ./ mA;
                    100 * x(6:10, :) ./ mB ];

        testFunc = @() normalize_sample(x, g, 'Mode', mode);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_pass0004(testCase)
    % SubtractMean, whole data in group as base line
        mode = 'SubtractMean';

        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        mA = repmat(mean(x(1:5, :), 1), 5, 1);
        mB = repmat(mean(x(6:10, :), 1), 5, 1);

        expData = [ x(1:5, :) - mA;
                    x(6:10, :) - mB ];

        testFunc = @() normalize_sample(x, g, 'Mode', mode);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_pass0005(testCase)
    % PercentSignalChange, base line specified
        mode = 'PercentSignalChange';

        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];
        b = [ 1; 0; 0; 0; 0;
              1; 0; 0; 0; 0 ];

        mA = repmat(mean(x(1, :), 1), 5, 1);
        mB = repmat(mean(x(6, :), 1), 5, 1);

        expData = [ 100 * (x(1:5, :) - mA) ./ mA;
                    100 * (x(6:10, :) - mB) ./ mB ];

        testFunc = @() normalize_sample(x, g, 'Mode', mode, 'Baseline', b);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_newInput_pass0001(testCase)
    % Default (PercentSignalChange, whole data in group as base line)
        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        mA = repmat(mean(x(1:5, :), 1), 5, 1);
        mB = repmat(mean(x(6:10, :), 1), 5, 1);
        
        expData = [ 100 * (x(1:5, :) - mA) ./ mA;
                    100 * (x(6:10, :) - mB) ./ mB ];

        testFunc = @() normalize_sample(x, 'Group', g);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_newInput_pass0002(testCase)
    % Zscore, whole data in group as base line
        mode = 'Zscore';

        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        mA = repmat(mean(x(1:5, :), 1), 5, 1);
        mB = repmat(mean(x(6:10, :), 1), 5, 1);
        sA = repmat(std(x(1:5, :), 0, 1), 5, 1);
        sB = repmat(std(x(6:10, :), 0, 1), 5, 1);
        
        expData = [ (x(1:5, :) - mA) ./ sA;
                    (x(6:10, :) - mB) ./ sB ];

        testFunc = @() normalize_sample(x, 'Group', g, 'Mode', mode);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_newInput_pass0003(testCase)
    % DivideMean, whole data in group as base line
        mode = 'DivideMean';

        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        mA = repmat(mean(x(1:5, :), 1), 5, 1);
        mB = repmat(mean(x(6:10, :), 1), 5, 1);

        expData = [ 100 * x(1:5, :) ./ mA;
                    100 * x(6:10, :) ./ mB ];

        testFunc = @() normalize_sample(x, 'Group', g, 'Mode', mode);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_newInput_pass0004(testCase)
    % SubtractMean, whole data in group as base line
        mode = 'SubtractMean';

        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];

        mA = repmat(mean(x(1:5, :), 1), 5, 1);
        mB = repmat(mean(x(6:10, :), 1), 5, 1);

        expData = [ x(1:5, :) - mA;
                    x(6:10, :) - mB ];

        testFunc = @() normalize_sample(x, 'Group', g, 'Mode', mode);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function normalize_sample_newInput_pass0005(testCase)
    % PercentSignalChange, base line specified
        mode = 'PercentSignalChange';

        x = rand(10, 5);
        g = [ 1; 1; 1; 1; 1;
              2; 2; 2; 2; 2 ];
        b = [ 1; 0; 0; 0; 0;
              1; 0; 0; 0; 0 ];

        mA = repmat(mean(x(1, :), 1), 5, 1);
        mB = repmat(mean(x(6, :), 1), 5, 1);

        expData = [ 100 * (x(1:5, :) - mA) ./ mA;
                    100 * (x(6:10, :) - mB) ./ mB ];

        testFunc = @() normalize_sample(x, 'Group', g, 'Mode', mode, 'Baseline', b);
        testData = testFunc();

        testCase.verifyEqual(testData, expData);
    end

    function reduce_outlier_pass0001(testCase)
    % Default (ByStd, ByMaxMin, Dimension = 1, NumIteration = 10,
    % StdThreshold = 3, Max = inf, Min = -inf)
        numItr = 10;
        stdThres = 3;
        
        x = rand(100, 10);
        for n = 1:10
            x(randi(100), randi(10)) = 1000000;
        end
        g = [ ones(50, 1); 2 * ones(50, 1) ];

        gInd = { [1:50], [51:100] };
        expData = x;
        for t = 1:length(gInd)
            xtmp = expData(gInd{t}, :);

            for n = 1:numItr
                m = mean(xtmp, 1);
                s = std(xtmp, 0, 1);

                thup = repmat(m + s * stdThres, 50, 1);
                thlw = repmat(m - s * stdThres, 50, 1);

                xtmp(thup < xtmp) = thup(thup < xtmp);
                xtmp(thlw > xtmp) = thlw(thlw > xtmp);
            end
            expData(gInd{t}, :) = xtmp;
        end
        expInd = [];

        testFunc = @() reduce_outlier(x, g);
        [testData, testInd] = testFunc();

        testCase.verifyEqual(testData, expData);
        testCase.verifyEqual(testInd, expInd);
    end    

    function reduce_outlier_newInput_pass0001(testCase)
    % Default (ByStd, ByMaxMin, Dimension = 1, NumIteration = 10,
    % StdThreshold = 3, Max = inf, Min = -inf)
        numItr = 10;
        stdThres = 3;
        
        x = rand(100, 10);
        for n = 1:10
            x(randi(100), randi(10)) = 1000000;
        end
        g = [ ones(50, 1); 2 * ones(50, 1) ];

        gInd = { [1:50], [51:100] };
        expData = x;
        for t = 1:length(gInd)
            xtmp = expData(gInd{t}, :);

            for n = 1:numItr
                m = mean(xtmp, 1);
                s = std(xtmp, 0, 1);

                thup = repmat(m + s * stdThres, 50, 1);
                thlw = repmat(m - s * stdThres, 50, 1);

                xtmp(thup < xtmp) = thup(thup < xtmp);
                xtmp(thlw > xtmp) = thlw(thlw > xtmp);
            end
            expData(gInd{t}, :) = xtmp;
        end
        expInd = [];

        testFunc = @() reduce_outlier(x, 'Group', g);
        [testData, testInd] = testFunc();

        testCase.verifyEqual(testData, expData);
        testCase.verifyEqual(testInd, expInd);
    end    

    function shift_sample_pass0001(testCase)
        shiftSize = 1;

        x = rand(9, 10);
        g = [ 1; 1; 1; 2; 2; 2; 3; 3; 3 ];

        expData = [ x(2:3, :);
                    x(5:6, :);
                    x(8:9, :) ];
        expInd  = [ 1; 2; 4; 5; 7; 8 ];

        testFunc = @() shift_sample(x, g, 'ShiftSize', shiftSize);
        [testData, testInd] = testFunc();        

        testCase.verifyEqual(testData, expData);
        testCase.verifyEqual(testInd, expInd);
    end

    function shift_sample_pass0002(testCase)
    % Shift size = 0
        shiftSize = 0;

        x = rand(9, 10);
        g = [ 1; 1; 1; 2; 2; 2; 3; 3; 3 ];

        expData = x;
        expInd  = [1:9]';

        testFunc = @() shift_sample(x, g, 'ShiftSize', shiftSize);
        [testData, testInd] = testFunc();        

        testCase.verifyEqual(testData, expData);
        testCase.verifyEqual(testInd, expInd);
    end

    function shift_sample_newInput_pass0001(testCase)
        shiftSize = 1;

        x = rand(9, 10);
        g = [ 1; 1; 1; 2; 2; 2; 3; 3; 3 ];

        expData = [ x(2:3, :);
                    x(5:6, :);
                    x(8:9, :) ];
        expInd  = [ 1; 2; 4; 5; 7; 8 ];

        testFunc = @() shift_sample(x, 'Group', g, 'ShiftSize', shiftSize);
        [testData, testInd] = testFunc();        

        testCase.verifyEqual(testData, expData);
        testCase.verifyEqual(testInd, expInd);
    end

    end
end
