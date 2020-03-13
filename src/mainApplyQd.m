clear
close all
clc

addpath('utils', 'raytracer')
%%
scenarioPath = 'ScenarioTest';
qdGeneratorFunc = @completeMultipleReflectionQdGenerator;

launchApplyQd(scenarioPath, 'qdGeneratorFunc', qdGeneratorFunc);