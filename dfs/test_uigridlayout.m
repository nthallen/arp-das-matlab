%%
fig = uifigure('Position',[100 100 437 317]);
g = uigridlayout(fig,[5 5]);
g.RowHeight = {'fit','fit','fit','fit','fit'};
g.ColumnWidth = {'fit','fit','fit','fit','fit'};
%g.RowHeight = {40,'1x'};
%g.ColumnWidth = {'1x','2x'};
%%
g.BackgroundColor = [0,0,1];
%% Add title
title = uilabel(g,'Text','Market Trends');
title.HorizontalAlignment = 'center';
title.FontSize = 24;
title.Layout.Row = 1;
title.Layout.Column = [1,2];

%%
xtxt = 'X';
for i = 1:2
  for j = 1:2
    txt = sprintf('cell(%d,%d) %s',i,j,xtxt);
    xtxt = [xtxt 'Y'];
    lbl = uilabel(g,'Text',txt);
    lbl.Layout.Row = i;
    lbl.Layout.Column = j;
    lbl.BackgroundColor = [1,1,1];
  end
end
%%
lbl2 = uilabel(g,'Text','label2');
lbl2.Layout.Row = 3;
lbl2.Layout.Column = [2,3];
lbl2.BackgroundColor = [1,1,1];
%% Add two axes
ax1 = uiaxes(g);
ax2 = uiaxes(g);
%%
% Try labels and checkboxes
fig = uifigure('Position',[100 100 437 317]);
g = uigridlayout(fig,[5 5]);
g.RowHeight = {'fit','fit','fit','fit','fit'};
g.ColumnWidth = {'fit','fit','fit','fit','fit'};
%g.RowHeight = {40,'1x'};
%g.ColumnWidth = {'1x','2x'};
g.BackgroundColor = [0,0,1];
g1 = uibutton(g,'Text','Group One');
g1.Layout.Row = 1;
g1.Layout.Column = [1,2];
cb1g1 = uicheckbox(g,'Text','');
cb1g1.Layout.Row = 2;
cb1g1.Layout.Column = 1;
p1g1 = uibutton(g,'Text','Plot One');
p1g1.Layout.Row = 2;
p1g1.Layout.Column = 2;
cb2g1 = uicheckbox(g,'Text','');
cb2g1.Layout.Row = 3;
cb2g1.Layout.Column = 1;
p2g1 = uibutton(g,'Text','P2');
p2g1.Layout.Row = 3;
p2g1.Layout.Column = 2;
fig.Visible = 'off'; fig.Visible = 'on';
%%
% Try tabbed panels
fig = uifigure('Position',[100 100 437 317]);
tabgp = uitabgroup(fig,'Position',[1 1 438 318]);
tab1 = uitab(tabgp,'Title','settings');
tab2 = uitab(tabgp,'Title','Options');
%%
% How to add runs (if/when we migrate ui_)
list_runs(fig, 'SCoPEx_Data_Dir');
fig.Visible = 'off'; fig.Visible = 'on';
%%
% Try nested grids: Is the element's position relative to the enclosing
% container, or the figure?
fig = uifigure('Position',[100 100 437 317]);
gl0 = uigridlayout(fig,[1,2]);
gl0.RowHeight = {'fit'};
gl0.ColumnWidth = {'fit','fit'};
gl1 = uigridlayout(gl0,[5 5]);
gl1.RowHeight = {'fit','fit','fit','fit','fit'};
gl1.ColumnWidth = {'fit','fit','fit','fit','fit'};
%g.RowHeight = {40,'1x'};
%g.ColumnWidth = {'1x','2x'};
gl0.BackgroundColor = [0,0,1];
g1 = uibutton(gl1,'Text','Group One');
g1.Layout.Row = 1;
g1.Layout.Column = [1,2];
cb1g1 = uicheckbox(gl1,'Text','');
cb1g1.Layout.Row = 2;
cb1g1.Layout.Column = 1;
p1g1 = uibutton(gl1,'Text','Plot One');
p1g1.Layout.Row = 2;
p1g1.Layout.Column = 2;
cb2g1 = uicheckbox(gl1,'Text','');
cb2g1.Layout.Row = 3;
cb2g1.Layout.Column = 1;
p2g1 = uibutton(gl1,'Text','P2');
p2g1.Layout.Row = 3;
p2g1.Layout.Column = 2;
fig.Visible = 'off'; fig.Visible = 'on';
%%
gl2 = uigridlayout(gl0,[5 5]);
g2 = uibutton(gl2,'Text','Group One');
% g2.Layout.Row = 1;
g2.Layout.Column = [1,2];
cb1g2 = uicheckbox(gl2,'Text','');
cb1g2.Layout.Row = 2;
cb1g2.Layout.Column = 1;
p1g2 = uibutton(gl2,'Text','Plot One');
p1g2.Layout.Row = 2;
p1g2.Layout.Column = 2;
cb2g2 = uicheckbox(gl2,'Text','');
cb2g2.Layout.Row = 3;
cb2g2.Layout.Column = 1;
p2g2 = uibutton(gl2,'Text','P2');
p2g2.Layout.Row = 3;
p2g2.Layout.Column = 2;
fig.Visible = 'off'; fig.Visible = 'on';
%%
fig = uifigure;
gl = uigridlayout(fig,[1,1]);
%gl.RowHeight = {'fit','fit','fit'};
%gl.ColumnWidth = {'fit','fit','fit','fit','fit'};
for row = 1:3
  for col = 1:5
    add_button(gl,row,col);
  end
end
%%
fig = uifigure('Position',[100 100 437 317]);
panel = uipanel(fig);
%%
function list_runs(fig, pdir)
[~,rem] = strtok(pdir,'\/');
if isempty(rem)
  set(fig, 'visible', 'off');
  pdir = ne_load_runsdir(pdir, 2);
end
files = dir( pdir );
[ ~, ifiles ] = sort({files.name});
if size(ifiles,2) > 1
  ifiles = ifiles';
end
n_runs = 0;
files = files(flipud(ifiles));
files = {files.name};
fnd = regexp(files,'^[0-9]');
V = cellfun(@isempty,fnd);
files = files(~V);
uidropdown(fig, 'Items', files, 'Value', files{1});
end

function add_button(gl, row, col)
  button = uibutton(gl,'Text',sprintf('Button (%d,%d)',row,col));
  button.Layout.Row = row;
  button.Layout.Column = col;
end
