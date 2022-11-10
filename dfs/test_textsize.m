%%
txt = 'A Rather Long String which is really long';
f = uifigure; g = uigridlayout(f);
for col = 1:length(g.ColumnWidth)
  g.ColumnWidth{col} = 'fit';
end
for row = 1:length(g.RowHeight)
  g.RowHeight{row} = 'fit';
end
l = uilabel(g,'Text',txt);
b = uibutton(g,'Text',txt);
%%
txt = 'A Rather Long String which is really long';
f = uifigure;
l = uilabel(f,'Text',txt);
b = uibutton(f,'Text',txt); b.Position(2) = 200;
%%
txt = 'A Rather Long String which is really long';
f = uifigure; g = uigridlayout(f,[2,3]);
for col = 1:length(g.ColumnWidth)
  g.ColumnWidth{col} = 'fit';
end
for row = 1:length(g.RowHeight)
  g.RowHeight{row} = 'fit';
end
b1 = uibutton(g,'Text',txt); b1.Layout.Column = [1,3];
cb1 = uicheckbox(g,'Text',''); cb1.Layout.Row = 2; cb1.Layout.Column = 1;
b2 = uibutton(g,'Text','SW');
b2.Layout.Row = 2; b2.Layout.Column = [2,3];

