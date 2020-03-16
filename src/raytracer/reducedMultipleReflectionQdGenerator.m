function [output, cursorOutput, outputPre, outputPost] = reducedMultipleReflectionQdGenerator(inRayOutput,...
    arrayOfMaterials, materialLibrary, losDelay, minPgThreshold)
%REDUCEDMULTIPLEREFLECTIONQDGENERATOR Generate diffused components starting from a
%deterministic ray on multiple reflectors following NIST's
%Quasi-Deterministic model.


% Copyright (c) 2020, University of Padova, Department of Information
% Engineering, SIGNET lab.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

if nargin < 4
    losDelay = 0;
end
if nargin < 5
    minPgThreshold = -Inf;
end

% init
cursorOutput = inRayOutput;
totMaterials = length(arrayOfMaterials);
outputPre = [];
outputPost = [];
% for each reflection, i.e., for each materialId in arrayOfMaterials
for matIdx = 1:totMaterials
    materialId = arrayOfMaterials(matIdx);
    otherMaterials = arrayOfMaterials([1:matIdx-1, matIdx+1:totMaterials]);
    
    [~, cursorOutput, currentOutputPre, currentOutputPost] =...
        singleReflectionQdGenerator(cursorOutput, materialId, materialLibrary,...
        losDelay, minPgThreshold);
    
    outputPre = [outputPre; otherMaterialsRl(currentOutputPre, otherMaterials, materialLibrary)];
    outputPost = [outputPost; otherMaterialsRl(currentOutputPost, otherMaterials, materialLibrary)];
end

output = [outputPre; cursorOutput; outputPost];
end


%% UTILS
function diffusedRays = otherMaterialsRl(diffusedRays, otherMaterials, materialLibrary)

if isempty(diffusedRays)
    return
end

nRays = size(diffusedRays, 1);
totRl = zeros(nRays, 1); % already subtracts mean RL

for i = 1:length(otherMaterials)
    materialId = otherMaterials(i);
    
    sRl = materialLibrary.s_RL(materialId);
    sigmaRl = materialLibrary.sigma_RL(materialId);
    muRl = materialLibrary.mu_RL(materialId);
    
    rl = rndRician(sRl, sigmaRl, nRays, 1) - muRl;
    totRl = totRl + rl;
    
end

diffusedRays(:, 9) = diffusedRays(:, 9) - totRl;

end