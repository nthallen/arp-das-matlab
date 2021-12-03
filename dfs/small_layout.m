%%
% Lines 15-30 are setting up a simple layout, and all
% the remaining code is just documenting the fact
% that the layout is not always finalized after
% calling drawnow. The surrounding loop is due
% to the fact that drawnow is usually sufficient,
% so a number of iterations is required before the
% failure is demonstrated.
% After a failure, Psummary can be examined to see
% the different Position values returned for the
% p1g1 button, with column 1 containing the 'toc'
% values when the Position was recorded.
ntries = 0;
while true
  fig = uifigure;
  gl0 = uigridlayout(fig,[2,2]);
  gl0.RowHeight = {'fit','fit'};
  gl0.ColumnWidth = {'fit','fit'};

  g1 = uibutton(gl0,'Text','Long Label');
  g1.Layout.Row = 1;
  g1.Layout.Column = [1,2];

  cb1g1 = uicheckbox(gl0,'Text','');
  cb1g1.Layout.Row = 2;
  cb1g1.Layout.Column = 1;

  p1g1 = uibutton(gl0,'Text','Short');
  p1g1.Layout.Row = 2;
  p1g1.Layout.Column = 2;

  N = 5;
  Psummary = zeros(N,5);
  tic
  drawnow;
  for i=1:N
    Psummary(i,1) = toc;
    Psummary(i,2:5) = p1g1.Position;
    pause(.1);
  end
  final = ones(N,1)*p1g1.Position;
  if any(any(final~=Psummary(:,2:5)))
    fprintf(1,'Layout not finalized after drawnow\n');
    break;
  else
    ntries = ntries+1;
    fprintf(1,'OK %d\n', ntries);
    delete(fig);
  end
end
