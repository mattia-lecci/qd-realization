function mpcCoordinates = readAllMpcCoordinates(scenarioPath)
mpcCoordinatesList = dir(fullfile(scenarioPath, 'Output/Visualizer/MpcCoordinates'));

mpcCoordinates = {};
for i = 1:length(mpcCoordinatesList)
    tok = regexp(mpcCoordinatesList(i).name,...
        'MpcTx(\d+)Rx(\d+)Refl(\d+)Trc(\d+)\.csv', 'tokens');
    if isempty(tok)
        continue
    end
    
    tx = str2double(tok{1}{1}) + 1;
    rx = str2double(tok{1}{2}) + 1;
    trc = str2double(tok{1}{4}) + 1;
    
    filepath = fullfile(mpcCoordinatesList(i).folder, mpcCoordinatesList(i).name);
    mpcCoord = readMpcCoordinates(filepath);
    
    % initialize if necessary
    if all([tx, rx] <= size(mpcCoordinates))
        time = mpcCoordinates{tx, rx};
        if trc > length(time)
            time{trc} = {};
        end
    else
        time{trc} = {};
    end
    
    % Different reflections yield different array sizes: use cell arrays
    time{trc} = [time{trc}, {mpcCoord}];
    mpcCoordinates{tx, rx} = time;
end

end