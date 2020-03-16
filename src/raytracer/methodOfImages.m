function [intersections, totPathGain, totRayLen, totReflectionLoss] =...
    methodOfImages(txPos, rxPos, cadData, materialLibrary,...
    triangIdxs, freq, recursionDepth)
%METHODOFIMAGES Recursive function implementing the Method of Images. Tx is
%recursively reflected over all triangles in triangIdx and intersections
%are computed. If any intersection is invalid, an empty array is returned,
%otherwise the list of intersection points is given.


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

triang = cadData(triangIdxs(recursionDepth), :);
plane = triang(10:13);
txPosReflected = reflectedImagePointPlane(txPos, plane);

reflOrder = length(triangIdxs);

if reflOrder == recursionDepth
    % Tx has been reflected over all triangles
    % Find the intersection between the reflected Tx and the Rx
    prevIntersection = rxPos;
    % Initialize for as many reflection points as the reflection order
    intersections = nan(reflOrder, 3);
    % initialize path gain and add it for each reflection segment
    totPathGain = 0;
    totRayLen = 0;
    totReflectionLoss = 0;
    
else % need more reflections
    % Proceed to the next recursion level
    [intersections, totPathGain, totRayLen, totReflectionLoss] =...
        methodOfImages(txPosReflected, rxPos, cadData, materialLibrary,...
        triangIdxs, freq, recursionDepth+1);
    
    if isempty(intersections)
        % If intersection cannot exist stop
        return
    else
        % Else, find the intersection between the reflected Tx and the
        % previous intersection point, as if it were a "virtual" Rx
        prevIntersection = intersections(recursionDepth+1, :);
    end
end

intersection = planeIntersectsSegment(plane, txPosReflected, prevIntersection, true);
if isempty(intersection)
    % Invalid if no intersection is found with given plane or if it goes in
    % the wrong direction (given by plane equation's normal vector)
    intersections = [];
    return
end
% else: valid intersection with triangle's plane
isInsideTriangle = pointInTriangle(intersection,...
    triang(1:3), triang(4:6), triang(7:9));
if isInsideTriangle
    % Add intersection point if valid
    intersections(recursionDepth, :) = intersection;
    [totReflectionLoss, totRayLen, totPathGain] =...
        getPartialPathGain(totReflectionLoss, totRayLen, intersections,...
        txPos, rxPos, cadData, materialLibrary,...
        triangIdxs, recursionDepth, freq);
    
else
    % Invalid if intersection happens outside the triangle's boundaries
    intersections = [];
    return
end

end


%% UTILS
function [totReflectionLoss, totRayLen, pathGain] =...
    getPartialPathGain(totReflectionLoss, totRayLen, intersections,...
    txPos, rxPos, cadData, materialLibrary,...
    triangIdxs, recursionDepth, freq)

currentIntersection = intersections(recursionDepth, :);
if recursionDepth == length(triangIdxs)
    % Reflection from last bounce to rx
    % Consider path from last intesection(s) to rx and reflection loss of
    % last bounce's material
    rayLen = norm(rxPos - currentIntersection);
else
    % Intermediate reflections
    % Consider path from current to next intersection and reflection
    % loss of current bounce's material
    nextIntersection = intersections(recursionDepth + 1, :);
    rayLen = norm(currentIntersection - nextIntersection);
end

materialId = cadData(triangIdxs(recursionDepth), 14);
% deterministic reflection losses
totReflectionLoss = totReflectionLoss + materialLibrary.mu_RL(materialId);

totRayLen = totRayLen + rayLen;

if recursionDepth == 1
    % Reflection from tx to first bounce
    % Consider path from tx to first intesection(s) only
    % Note: for first-order reflections first and last recursionDepth
    % coincide, and thus need an external if statement
    rayLen = norm(currentIntersection - txPos);
    totRayLen = totRayLen + rayLen;
end

pathGain = friisPathGain(totRayLen, freq) - totReflectionLoss;

end