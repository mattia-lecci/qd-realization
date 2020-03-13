function qdFilesOut = applyQd(qdFilesIn, triangLists, nodesPosition,...
    cadData, materialLibrary, paramCfg, qdGeneratorFunc)

numNodes = length(nodesPosition);
assert(size(qdFilesIn, 1) == numNodes && size(qdFilesIn, 2) == numNodes);

qdFilesOut = cell(numNodes, numNodes);

for nodeIdx1 = 1:numNodes
    for nodeIdx2 = nodeIdx1+1:numNodes
        qdFile = qdFilesIn{nodeIdx1, nodeIdx2};
        triangList = triangLists{nodeIdx1, nodeIdx2};
        positions = nodesPosition([nodeIdx1, nodeIdx2]);
        
        tTot = length(qdFile);
        assert(length(triangList) == tTot);
        assert(length(positions{1}) == tTot+1 &&...
            length(positions{2}) == tTot+1);
        
        for t = 1:tTot
            qdFileOut(t) = applyQdToTimestep(qdFile(t), triangList{t},...
                {positions{1}(t, :), positions{2}(t, :)}, cadData,...
                materialLibrary, paramCfg, qdGeneratorFunc);
        end
        
        % store QD files
        qdFilesOut{nodeIdx1, nodeIdx2} = qdFileOut;
        
        % reverse angles
        qdFileOut = swapFields(qdFileOut, 'aodAz', 'aoaAz');
        qdFileOut = swapFields(qdFileOut, 'aodEl', 'aoaEl');
        
        % store reversed QD files
        qdFilesOut{nodeIdx2, nodeIdx1} = qdFileOut;
        
    end
end

end


%% UTILITIES
function s = swapFields(s, field1, field2)

for i = 1:numel(s)
    tmp = s(i).(field1);
    s(i).(field1) = s(i).(field2);
    s(i).(field2) = tmp;
end

end