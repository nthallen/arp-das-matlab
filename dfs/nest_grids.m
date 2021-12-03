%%
fig = uifigure;
gl0 = uigridlayout(fig,[1,2]);
gl0.Tag = 'gl0';
gl0.RowHeight = {'fit'};
gl0.ColumnWidth = {'fit','fit'};
gl0.BackgroundColor = [0,0,1];
array1 = new_gridlayout(gl0, 'One', '1');
array2 = new_gridlayout(gl0, 'Two', '2');
N = 30;
Psummary = zeros(N,3);
tic
drawnow;
drawnow;
for i=1:N
  P = get_widget_pos(gl0);
  Psummary(i,1) = toc;
  Psummary(i,2:3) = P(3:4);
  pause(.1);
end
Pfig = fig.Position;
Pfig(3:4) = Psummary(end,2:3);
fig.Position = Pfig;
%pause
%delete(fig);
%%
function arr = new_gridlayout(parent, longtext, shorttext)
  gl = uigridlayout(parent,[3 2]);
  gl.Tag = [ 'gl' shorttext ];
  gl.RowHeight = {'fit','fit','fit'};
  gl.ColumnWidth = {'fit','fit'};

  g1 = uibutton(gl,'Text',sprintf('Group %s',longtext));
  g1.Tag = [ gl.Tag '_b1'];
  g1.Layout.Row = 1;
  g1.Layout.Column = [1,2];

  cb1g1 = uicheckbox(gl,'Text','');
  cb1g1.Tag = [ gl.Tag '_cb2' ];
  cb1g1.Layout.Row = 2;
  cb1g1.Layout.Column = 1;

  p1g1 = uibutton(gl,'Text',sprintf('Plot %s', longtext));
  p1g1.Tag = [gl.Tag '_b2'];
  p1g1.Layout.Row = 2;
  p1g1.Layout.Column = 2;

  cb2g1 = uicheckbox(gl,'Text','');
  cb2g1.Tag = [ gl.Tag '_cb3' ];
  cb2g1.Layout.Row = 3;
  cb2g1.Layout.Column = 1;

  p2g1 = uibutton(gl,'Text',sprintf('P%s',shorttext));
  p2g1.Tag = [ gl.Tag '_b3' ];
  p2g1.Layout.Row = 3;
  p2g1.Layout.Column = 2;
  gl.BackgroundColor = [0,1,1];
  arr = gl;
end

function P = get_widget_pos(w)
% P = get_widget_max_extent(w)
% This should give the actual extents of the widget in the standard
% [x y dx dy] format. For uigridlayout (and possibly other containers), we
% will instead return [NaN NaN dx dy], i.e. only the size. x and y usually
% represent the offset of a widget within the enclosing container, but for
% uigridlayout widgets, we do not get that information, and may have to
% construct it by other means.
%
% For simple containers, it will be the max extent of
% all the contained widgets. Some container widgets however do not
% support Position, or the Position may be unrelated to the included
% widgets, so special care is needed.
% 
% uigridlayout:
%   The Position of widgets inside a uigridlayout are relative to
%   the uigridlayout. The max extent of these is a lower bound for
%   the max extent of the uigridlayout.
%
%   If another uigridlayout is nested inside, the max extent of doubly
%   nested widgets will be the max extent within the nested uigridlayout,
%   so will be <= the widgets max extent within the outer uigridlayout. If
%   we know the grid row and/or column Position based on other widgets in
%   adjacent rows or columns, then we can determine the max extent. If not,
%   we should be able to determine the row/column Position by adding up the
%   the max extents of other cells and row/column spacing.
%
%   Our concept is to in fact nest uigridlayouts freely to achieve a
%   desired layout, so this is a realistic problem.
  switch w.Type
    case {'uigridlayout'}
      P = [NaN NaN 0 0];
      rowY = zeros(length(w.RowHeight)+1,1);
      rowheight = zeros(length(w.RowHeight)+1,1);
      rowY(end) = w.RowSpacing;
      colX = zeros(length(w.ColumnWidth)+1,1);
      colwidth = zeros(length(w.ColumnWidth)+1,1);
      colX(1) = w.ColumnSpacing;
      ch = w.Children;
      for i=1:length(ch)
        % indexes into rowY and rowheight are offset by 1, so
        % rowY(2) is the Y offset of row 1, the top row of the grid.
        row = ch(i).Layout.Row;
        row_m = min(row)+1;
        row_M = max(row)+1;
        col = ch(i).Layout.Column;
        col_m = min(col);
        col_M = max(col);
        Pi = get_widget_pos(ch(i));
        % If we have full position, update P directly
        if ~any(isnan(Pi))
          P(3:4) = max(P(3:4),Pi(1:2)+Pi(3:4));
          colX(col_m) = max(colX(col_m),Pi(1));
          rowY(row_M) = max(rowY(row_M),Pi(2));
        end
        if isscalar(col)
          colwidth(col) = max(colwidth(col),Pi(3));
        end
        colX(col_M+1) = max(colX(col_M+1), ...
          colX(col_m)+Pi(3)+w.ColumnSpacing);
        if isscalar(row)
          rowheight(row_m) = max(rowheight(row_m),Pi(4));
        end
        rowY(row_m-1) = max(rowY(row_m-1), ...
          rowY(row_M)+Pi(4)+w.RowSpacing);
      end
      for i=(length(rowY)-1):-1:1
        rowY(i) = max(rowY(i),rowY(i+1)+rowheight(i+1)+w.RowSpacing);
      end
      P(4) = max(P(4),rowY(1));
      for i=2:length(colX)
        colX(i) = max(colX(i),colX(i-1)+colwidth(i-1)+w.ColumnSpacing);
      end
      P(3) = max(P(3),colX(end));
    otherwise
      try
        P = w.Position;
      catch
        fprintf(1,'Could not read Position of type %s\n',w.Type);
        P = [0 0 0 0];
      end
  end
  tag = w.Tag;
  if isempty(tag)
    tag = sprintf('Untagged %s',w.Type);
  end
  % fprintf(1,'Pos of %s is [ %d %d %d %d]\n', tag, P);
end
