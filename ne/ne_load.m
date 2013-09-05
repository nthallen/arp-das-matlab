function [ data, time ] = ne_load(filebase, dirfunc, depth)
% [data, time] = ne_load(filebase, dirfunc, depth)
% filebase: the name of the data file without '.mat'
%   e.g. 'hcieng_1'
% dirfunc: The experiment-specific directory function name
%   e.g. 'HCI_Data_Dir'
% depth: Optional, defaults to 2. Passed to ne_load_runsdir()
if nargin < 3
    depth = 2;
end
runsdir = ne_load_runsdir(dirfunc, depth);
rundir = [ runsdir filesep getrun(1) ];
base = [ rundir filesep filebase ];
if ~exist( [base '.mat'], 'file') && exist([base '.csv'], 'file')
    oldpwd = cd(rundir);
    csv2mat([filebase '.csv']);
    cd(oldpwd);
end
if exist([base '.mat'], 'file')
    data = load([base '.mat']);
    if nargout > 1
        time = time2d(data.(['T' filebase]));
    end
else
    data = [];
    if nargout > 1
        time = [];
    end
end