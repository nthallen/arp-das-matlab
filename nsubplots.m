function a_out = nsubplots( X, Y )
% a = nsubplots( X [, Y] )
% Displays multiple axes automatically.
% Optionally returns the list of axes.
if nargin < 2
  Y = X;
  X = 1:size(Y,1);
end
np = size(Y,2);
figure;
a = [];
for i=1:np
  a = [ a nsubplot(np,1,i)];
  plot(X,Y(:,i));
  if mod(i,2)
    set(gca,'YAxisLocation', 'Right');
  end
  if i < np
    set(gca,'XTickLabel',[]);
  end
end
addzoom
if nargout > 0
  a_out = a;
end

