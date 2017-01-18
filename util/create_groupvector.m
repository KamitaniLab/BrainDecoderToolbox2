function v = create_groupvector(groupLabel, groupSize)
% create_groupvector    Create group vector for dataSet
%
% This file is a part of BrainDecoderToolbox2.
%
% Usage:
%
%     v = create_groupvector(groupLabel, groupSize)
%

nGrp = length(groupLabel);

if isscalar(groupSize)
    groupSize = groupSize .* ones(1, nGrp);
end

v = [];

for n = 1:nGrp
    v = [ v; ones(groupSize(n), 1) .* groupLabel(n) ];
end
