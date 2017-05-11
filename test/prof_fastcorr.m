clear all;
profile clear;

x = rand(1000, 100);
y = rand(1000, 100);

profile on;
tic
c1 = corr(x, y);
toc

tic
c2 = fastcorr(x, y);
toc
profile off;
profile viewer;

testCase = matlab.unittest.TestCase.forInteractiveUse;
verifyEqual(testCase, c2, c1, 'AbsTol', 1e-15);
