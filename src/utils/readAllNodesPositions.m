function nodesPositions = readAllNodesPositions(scenarioPath)
nodePosList = dir(fullfile(scenarioPath, 'Input'));

nodesPositions = {};
for i = 1:length(nodePosList)
    tok = regexp(nodePosList(i).name, 'NodePosition(.+)\.dat','tokens');
    if isempty(tok)
        continue
    end
    
    idx = str2double(tok{1}{1});
    filepath = fullfile(nodePosList(i).folder, nodePosList(i).name);
    t = readtable(filepath); % for backward compatibility
    nodesPositions{idx} = t{:, :};
end

end