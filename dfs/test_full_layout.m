%%
fig = uifigure;
% created a context menu
gl = uigridlayout(fig,[3,1]);
ttl = uilabel(gl,'Text','SCoPEx Platform','HorizontalAlignment','center','FontWeight','bold');
ttl.Layout.Row = 1;
ttl.Layout.Column = 1;
gl3 = uigridlayout(gl,[1,3]);
gl3.Layout.Row = 3; gl3.Layout.Column = 1;
btn = uibutton(gl3,'Text','GraphSelected'); % with ButtonPushedFcn
btn.Layout.Row = 1; btn.Layout.Column = 2;
gl3.RowHeight{1} = 'fit';
gl3.ColumnWidth{1} = '1x';
gl3.ColumnWidth{2} = 'fit';
gl3.ColumnWidth{3} = '1x';

gl1 = uigridlayout(gl);
gl1.Layout.Row = 2;
gl1.Layout.Column = 1;
grp1 = uilabel(gl1,'Text','B3MB 100V1 Batt');
