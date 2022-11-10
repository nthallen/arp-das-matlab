%%
% Grid lines
fig = uifigure;
gl = uigridlayout(fig);
new_gridlayout(gl,'Group One','g1',2,2);
lb = uilabel(gl,'Text','<hr>','Interpreter','html');
lb.Layout.Row = 1; lb.Layout.Column = [1,4];
for i=1:length(gl.RowHeight)
  gl.RowHeight{i} = 'fit';
end
for i=1:length(gl.ColumnWidth)
  gl.ColumnWidth{i} = 'fit';
end

%%
function new_gridlayout(gl, longtext, shorttext, row, col)
  % This version does not create the grid layout, just populates it
  g1 = uibutton(gl,'Text',sprintf('Group %s',longtext));
  g1.Tag = [ gl.Tag '_b1'];
  g1.Layout.Row = row;
  g1.Layout.Column = col+[0,1];

  cb1g1 = uicheckbox(gl,'Text','');
  cb1g1.Tag = [ gl.Tag '_cb2' ];
  cb1g1.Layout.Row = row+1;
  cb1g1.Layout.Column = col;

  p1g1 = uibutton(gl,'Text',sprintf('Plot %s', longtext));
  p1g1.Tag = [gl.Tag '_b2'];
  p1g1.Layout.Row = row+2;
  p1g1.Layout.Column = col+1;

  cb2g1 = uicheckbox(gl,'Text','');
  cb2g1.Tag = [ gl.Tag '_cb3' ];
  cb2g1.Layout.Row = 3;
  cb2g1.Layout.Column = col;

  p2g1 = uibutton(gl,'Text',sprintf('P%s',shorttext));
  p2g1.Tag = [ gl.Tag '_b3' ];
  p2g1.Layout.Row = row+2;
  p2g1.Layout.Column = col+1;
  gl.BackgroundColor = [0,1,1];
  arr = gl;
end
