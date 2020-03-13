function fids = getOutputFids(folderpath, numberOfNodes, useOptimizedOutputToFile)
%GETOUTPUTFIDS Opens/creates all output files with 'At' permission (create
% or append to text file without automatic flushing).
%
% INPUTS:
% - folderpath: output folder path
% - numberOfNodes: number of nodes in the simulation
% - useOptimizedOutputToFile: flag. Disable if "Too many files open" error
% is thrown. See PARAMETERCFG.
%
% OUTPUTS:
% - fids: Empty array is ~useOptimizedOutputToFile. Otherwise, matrix of
% File IDs. The main diagonal is NaN-filled.
%
% SEE ALSO: CLOSEQDFILESIDS, PARAMETERCFG


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

if useOptimizedOutputToFile
    fids = nan(numberOfNodes, numberOfNodes);
else
    fids = [];
end

for iTx = 1:numberOfNodes
    for iRx = 1:numberOfNodes
        if iTx == iRx
            continue
        end
        
        filename = sprintf('Tx%dRx%d.txt', iTx-1, iRx-1);
        filepath = fullfile(folderpath, filename);
        
        if useOptimizedOutputToFile
            fids(iTx,iRx) = fopen(filepath,'Wt');
        else
            delete(filepath)
        end
    end
    
end

end