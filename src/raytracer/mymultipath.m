function [output, multipath, currentMaxPathGain, outTriangList] =...
    mymultipath(rxPos, txPos, rxVel, txVel, triangIdxList, cadData,...
    visibilityMatrix, materialLibrary, qdGeneratorType, freq,...
    minAbsolutePathGainThreshold, minRelativePathGainThreshold, currentMaxPathGain)
%MYMULTIPATH Computes ray, if it exists, between rxPos and txPos, bouncing
%over the given lists of triangles. Also computes QD MPCs if requested.


% Copyright (c) 2019, University of Padova, Department of Information
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

triangListLen = size(triangIdxList,1);
reflOrder = size(triangIdxList,2);

losDelay = norm(rxPos - txPos) / physconst('LightSpeed');

% init outputs
switch(qdGeneratorType)
    case 'off'
        % Only D-rays
        output = nan(triangListLen, 21);
    case {'legacy', 'reduced', 'complete'}
        % Concatenate D-rays and QD MPCs
        % Output size not known a-priori
        output = nan(0, 21);
    otherwise
        error('qdGeneratorType''%s'' not recognized', qdGeneratorType)
end
multipath = nan(triangListLen, 1 + 3 * (reflOrder+2));
outTriangList = cell(1, triangListLen);

multipath(:,1) = reflOrder;

for i = 1:triangListLen
    currentTriangIdxs = triangIdxList(i,:);
    
    [pathExists, dod, doa, rowMultipath, rayLen, dopplerFactor, pathGain,...
        currentMaxPathGain] = computeSingleRay(txPos, rxPos, txVel, rxVel,...
        currentTriangIdxs, cadData, visibilityMatrix, materialLibrary,...
        freq, minAbsolutePathGainThreshold,...
        minRelativePathGainThreshold, currentMaxPathGain);
    
    if pathExists
        deterministicRayOutput = fillOutputDeterm(reflOrder, dod, doa, rayLen,...
            pathGain, dopplerFactor, freq);
        outTriangList{i} = currentTriangIdxs;
        
        switch(qdGeneratorType)
            case 'off'
                output(i,:) = deterministicRayOutput;
                
            case 'reduced'
                arrayOfMaterials = cadData(currentTriangIdxs, 14);
                minPgThreshold = max(currentMaxPathGain + minRelativePathGainThreshold,...
                    minAbsolutePathGainThreshold);
                
                qdOutput = reducedMultipleReflectionQdGenerator(...
                    deterministicRayOutput,...
                    arrayOfMaterials,...
                    materialLibrary,...
                    losDelay,...
                    minPgThreshold);
                
                output = [output; qdOutput];
                
            case 'complete'
                arrayOfMaterials = cadData(currentTriangIdxs, 14);
                minPgThreshold = max(currentMaxPathGain + minRelativePathGainThreshold,...
                    minAbsolutePathGainThreshold);
                
                qdOutput = completeMultipleReflectionQdGenerator(...
                    deterministicRayOutput,...
                    arrayOfMaterials,...
                    materialLibrary,...
                    losDelay,...
                    minPgThreshold);
                
                output = [output; qdOutput];
                
            otherwise
                error('qdGeneratorType=''%s'' not supported', qdGeneratorType);
        end
        
        multipath(i, 2:end) = rowMultipath;
    end
end

% Remove invalid output rows
invalidRows = all(isnan(output), 2);
output(invalidRows,:) = [];
multipath(invalidRows,:) = [];
outTriangList(invalidRows) = [];

end