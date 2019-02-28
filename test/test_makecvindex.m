% Tests for make_cvindex

clear all;

% Basic test
disp('Basic test');

testInput    = [ 1, 1, 2, 2, 3, 3 ]';
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

[testOutput_tr, testOutput_te] = make_crossvalidationindex(testInput);
assert(isequal(testOutput_tr, expOutput_tr));
assert(isequal(testOutput_te, expOutput_te));

% N-fold test
disp('N-fold test');

testInput      = [ 1, 1, 2, 2, 3, 3, 4, 4 ]';
testInputNfold = 2;
expOutput_tr = logical([ 0 1;
                         0 1;
                         0 1;
                         0 1;
                         1 0;
                         1 0;
                         1 0;
                         1 0 ]);
expOutput_te = logical([ 1 0;
                         1 0;
                         1 0;
                         1 0;
                         0 1;
                         0 1;
                         0 1;
                         0 1 ]);

[testOutput_tr, testOutput_te] = make_crossvalidationindex(testInput, testInputNfold);
assert(isequal(testOutput_tr, expOutput_tr));
assert(isequal(testOutput_te, expOutput_te));

% Large data test
disp('Test 2: large data');

testInput    = [ 1:5000 ]';
expOutput_te = logical(diag(ones(size(testInput))));
expOutput_tr = ~expOutput_te;

[testOutput_tr, testOutput_te] = make_crossvalidationindex(testInput);
assert(isequal(testOutput_tr, expOutput_tr));
assert(isequal(testOutput_te, expOutput_te));

% Non-equal grouping test
disp('Non-equal grouping test');

testInput      = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]';
testInputNfold = 2;

expOutput_tr = logical([0 1;
                        0 1;
                        0 1;
                        0 1;
                        1 0;
                        1 0;
                        1 0;
                        1 0;
                        1 0;
                        1 0]);
expOutput_te = ~expOutput_tr;

[testOutput_tr, testOutput_te] = make_crossvalidationindex(testInput, testInputNfold);
assert(isequal(testOutput_tr, expOutput_tr));
assert(isequal(testOutput_te, expOutput_te));
