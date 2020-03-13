function launchApplyQd(scenarioPath, varargin)
% Input handling
p = inputParser;

defaultOutputQdFilesPath = fullfile(scenarioPath, 'Output/Ns3/QdFiles_QD');

addRequired(p, 'scenarioPath', @(x) isStringScalar(x) || ischar(x));
addParameter(p, 'qdGeneratorFunc', @reducedMultipleReflectionQdGenerator,...
    @(x) validateattributes(x, {'function_handle'}, {'scalar', 'nonempty'},...
    mfilename, 'qdGeneratorFunc'));
addParameter(p, 'outputQdFilesPath', defaultOutputQdFilesPath,...
    @(x) isStringScalar(x) || ischar(x));
addParameter(p, 'precision', 6, @(x) validateattributes(x,...
    {'numeric'}, {'scalar', 'nonempty', 'integer', 'positive'},...
    mfilename, 'precision'));
addParameter(p, 'verbose', 1, @(x) validateattributes(x,...
    {'numeric'}, {'scalar', 'nonempty', 'integer', 'nonnegative'},...
    mfilename, 'verbose'));

parse(p, scenarioPath, varargin{:});

scenarioPath = p.Results.scenarioPath;
qdGeneratorFunc = p.Results.qdGeneratorFunc;
outputQdFilesPath = p.Results.outputQdFilesPath;
precision = p.Results.precision;
verbose = p.Results.verbose;

% Init
functionPath = fileparts(mfilename('fullpath'));
addpath(fullfile(functionPath, 'raytracer'),...
    fullfile(functionPath, 'utils'))

% Import files
if verbose
    disp('Importing files...')
end
qdFiles = readAllQdFiles(scenarioPath);
triangLists = readAllTriangLists(scenarioPath);
nodesPosition = readAllNodesPositions(scenarioPath);

% Import input cfg parameters
paramCfg = parameterCfg(scenarioPath);

% Import material library
matLibraryPath = paramCfg.materialLibraryPath;
materialLibrary = importMaterialLibrary(matLibraryPath);

% Import cadData
[cadData, switchMaterial] = getCadOutput(...
    paramCfg.environmentFileName,...
    fullfile(scenarioPath, 'Input'),...
    materialLibrary,...
    paramCfg.referencePoint,...
    paramCfg.selectPlanesByDist,...
    paramCfg.indoorSwitch);

% post-processing
if verbose
    disp('Applying QD model...')
end

if switchMaterial
    qdFilesOut = applyQd(qdFiles, triangLists, nodesPosition, cadData,...
        materialLibrary, paramCfg, qdGeneratorFunc);
else
    warning('switchMaterial=0, QD not applied applied')
    return
end

% write to file
if verbose
    disp('Writing output QdFiles...')
end
mkdir(outputQdFilesPath)
writeAllQdFiles(qdFilesOut, outputQdFilesPath, precision);

end