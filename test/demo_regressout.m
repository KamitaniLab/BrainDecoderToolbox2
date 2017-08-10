% Demo script for regressout

clear all;

nsmp = 100;
nfeat = 50;

bias = 10;

lintr = [1:nsmp]';

x = randn(nsmp, nfeat);

regressor = randn(nsmp, 6);

xin = x + repmat(sum(regressor, 2), 1, nfeat) + bias + repmat(lintr, 1, nfeat);

y1 = regressout(xin, 'Regressor', regressor);
y2 = regressout(xin, 'Regressor', regressor, 'RemoveDc', 'on');
y3 = regressout(xin, 'Regressor', regressor, 'RemoveDc', 'on', 'LinearDetrend', 'on');

figure;

plot(x(:, 1), 'k');
hold on;
plot(xin(:, 1), 'r');
plot(y1(:, 1), 'b');
plot(y2(:, 1), 'c');
plot(y3(:, 1), 'g');

legend('Original', 'Original + noise', 'Regress-out (default)', 'Regress-out (remove DC)', 'Regress-out (remove DC + linear detrend)');

box off;
