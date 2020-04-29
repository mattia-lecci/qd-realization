clear
close all
clc

addpath('../raytracer/', '../utils')
%% Parameters
cadFilePath = '../examples/L-Room/Input/L-Room.xml';
materialLibraryPath = '../material_libraries/LectureRoomAllMaterialsCeilingFloor.csv';
plotNormals = true;

%% Import CAD
[inputPath, environmentFileName, fileExtension] = fileparts(cadFilePath);
fullEnvironmentFileName = [environmentFileName, fileExtension];

materialLibrary = importMaterialLibrary(materialLibraryPath);
cadData = getCadOutput(fullEnvironmentFileName, inputPath, materialLibrary,...
    [0, 0, 0], 0, 1);

plotRoom(cadData, plotNormals)