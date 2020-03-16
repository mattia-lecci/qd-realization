function output = completeMultipleReflectionQdGenerator(inRayOutput,...
    arrayOfMaterials, materialLibrary, losDelay, minPgThreshold)
%COMPLETEMULTIPLEREFLECTIONQDGENERATOR Generate diffused components starting from a
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
currentReflRays = inRayOutput;

% for each reflection, i.e., for each materialId in arrayOfMaterials
for matIdx = 1:length(arrayOfMaterials)
    materialId = arrayOfMaterials(matIdx);
    
    % reset tmp variables
    prevReflRays = currentReflRays;
    currentReflRays = nan(size(prevReflRays, 1) * 20, size(prevReflRays, 2));
    totCurrentReflRays = 0;
    
    % for each ray from previous reflection, apply QD of current reflection
    for rayIdx = 1:size(prevReflRays, 1)
        prevRay = prevReflRays(rayIdx, :);
        
        newRays = singleReflectionQdGenerator(prevRay, materialId, materialLibrary, losDelay, minPgThreshold);
        
        numNewRays = size(newRays, 1);
        currentReflRays(totCurrentReflRays+1:totCurrentReflRays+numNewRays, :) = newRays;
        totCurrentReflRays = totCurrentReflRays + numNewRays;
    end
    currentReflRays(totCurrentReflRays+1:end, :) = [];
end

output = currentReflRays;
end