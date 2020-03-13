function qdFileOut = applyQdToTimestep(qdFileIn, triangList,...
    nodesPosition, cadData, materialLibrary, paramCfg, qdGeneratorFunc)
% extract time-step information
% LoS delay
nodesDistance = nodesPosition{2} - nodesPosition{1};
losDelay = norm(nodesDistance) / physconst('LightSpeed');

% Threshold for minimum path gain
maxPathGain = max(qdFileIn.pathGain);
minPgThreshold = max(maxPathGain + paramCfg.minRelativePathGainThreshold,...
    paramCfg.minAbsolutePathGainThreshold);

% init
qdArrayOut = nan(qdFileIn.numRays * 20, 21);
qdOutLastIdx = 0;

for i = 1:qdFileIn.numRays
    rayInfo = struct('pathGain', qdFileIn.pathGain(i),...
        'delay', qdFileIn.delay(i),...
        'phaseOffset', qdFileIn.phaseOffset(i),...
        'aodAz', qdFileIn.aodAz(i),...
        'aodEl', qdFileIn.aodEl(i),...
        'aoaAz', qdFileIn.aoaAz(i),...
        'aoaEl', qdFileIn.aoaEl(i),...
        'reflOrder', length(triangList{i}));
    
    qdArray = fillOutputRayInfo(rayInfo);
    
    if rayInfo.reflOrder > 0
        % Reflected ray: generate QD
        arrayOfMaterials = cadData(triangList{i}, 14);
        qdArray = qdGeneratorFunc(qdArray, arrayOfMaterials,...
            materialLibrary, losDelay, minPgThreshold);
    end
%     figure
%     scatter(qdArray(:,8), qdArray(:,9))
    
    % Add new rays
    numMpcs = size(qdArray, 1);
    qdArrayOut(qdOutLastIdx+1:qdOutLastIdx+numMpcs, :) = qdArray;
    qdOutLastIdx = qdOutLastIdx + numMpcs;
    
end

qdArrayOut = qdArrayOut(1:qdOutLastIdx, :);
qdFileOut = qdArray2Struct(qdArrayOut);

% % sanity-check plot
% maxPg = max(qdFileOut.pathGain);
% minPg = maxPg - 50;
% scalePg = @(pg) max(0, 50*(pg - minPg)/(maxPg - minPg)) + 0.01;
% 
% figure
% scatter(qdFileOut.aodAz, qdFileOut.aodEl, scalePg(qdFileOut.pathGain)); hold on
% scatter(qdFileIn.aodAz, qdFileIn.aodEl, scalePg(qdFileIn.pathGain));hold off
% xlim([0 360])
% ylim([0 180])
% title('AoD')
% set(gca, 'YDir', 'reverse')
% 
% figure
% scatter(qdFileOut.aoaAz, qdFileOut.aoaEl, scalePg(qdFileOut.pathGain)); hold on
% scatter(qdFileIn.aoaAz, qdFileIn.aoaEl, scalePg(qdFileIn.pathGain));hold off
% xlim([0 360])
% ylim([0 180])
% title('AoA')
% set(gca, 'YDir', 'reverse')

end


%% UTILS
function qStruct = qdArray2Struct(qdArray)
qStruct = struct('numRays', size(qdArray, 1),...
        'pathGain', qdArray(:, 9),...
        'delay', qdArray(:, 8),...
        'phaseOffset', qdArray(:, 18),...
        'aodAz', qdArray(:, 10),...
        'aodEl', qdArray(:, 11),...
        'aoaAz', qdArray(:, 12),...
        'aoaEl', qdArray(:, 13));
end