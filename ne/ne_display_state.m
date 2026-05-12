function ne_display_state(h, varname)
% h Line object from graph
% varname: variable name and basename of a MAT file in which the definition
% might be found in the rundir.
set(h,'LineStyle','none','Marker','.');
%   ax = get(h(1),'parent');
%   set(ax,'ylim',[0 800]);

% What I want to do with this is:
% Identify the unique values in the ydata and get the associated strings
% from IFSCStat.tmc.
% Map the ydata onto a contiguous integers and replace the ydata with the
% contiguously mapped values
% Set ylabels for those integers using the strings
label_list = {};
label_file = [ varname '.labels' ];
try
    fname = [ getrundir filesep label_file ];
    label_list = readlines(fname, 'EmptyLineRule','skip');
catch
end
if isempty(label_list)
    fname = which(label_file);
    if ~isempty(fname)
        label_list = readlines(fname, 'EmptyLineRule','skip');
    end
end
if ~isempty(label_list)
    YData = h.YData;
    [C, ~, ic] = unique(YData);
    labels = strrep(label_list(C+1),'_','\_');
    h.YData = ic;
    N = length(C);
    % C are the N unique values
    % ic are the indexes within C for each of the YData
    %  hence the effective map from YData onto 1:N
    %IFSCStat = {}; will be an array of IFSCStat strings
    % This should be parsed at runtime from the file saved with the run.
    % To make that work, getrun would need an option to pull that file down
    % Or it could be parsed during the MATLAB portion of getrun
    % load('260319.1/IFSCStat.mat');
    % The YData values are indexes into a zero-based array,
    % but IFSCStat is one-based, so we need to add 1:
    ax = h.Parent;
    set(ax,'YTick', 1:N, 'YTickLabel', labels, 'ylim', [0.75 N+0.25]);
end
