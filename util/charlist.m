function charList = charlist(num)
% charlist    Return a list (cell array) of characters
%
% This file is a part of BrainDecoderToolbox2.
%
% Example:
%
%     >> charlist(1:10)
%
%     ans = 
%
%         'a'    'b'    'c'    'd'    'e'    'f'    'g'    'h'    'i'    'j'
%

for n = num
    if 1 <= n && n <= 26
        charList{n} = char('a' + n - 1);
    elseif n > 26
        charList{n} = [ char 'a' char('a' + n - 27) ];
    end
end

% Remove empties
count = 1;
for n = 1:length(charList)
    if ~isempty(charList{n})
        charListNoEmp{count} = charList{n};
        count = count + 1;
    end
end

charList = charListNoEmp;