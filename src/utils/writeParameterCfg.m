function writeParameterCfg(parameterCfg, scenarioPath)
paraCfgPath = fullfile(scenarioPath, 'Input/paraCfgCurrent.txt');

fid = fopen(paraCfgPath, 'Wt');
fprintf(fid, 'ParameterName\tParameterValue\n');

cfgFields = fields(parameterCfg);


for i = 1:length(cfgFields)
    field = cfgFields{i};
    value = parameterCfg.(field);
    
    if isnumeric(value)
        value = num2str(value);
    end
    
    fprintf(fid, '%s\t%s\n', field, value);
end

fclose(fid);

end