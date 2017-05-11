function a_out = nsubplots( X, Y )
% a = nsubplots( X [, Y] )
% Displays data in multiple axes automatically.
% Optionally returns the list of axes.
if nargin < 2
  Y = X;
  X = 1:size(Y,1);
end
np = size(Y,2);
figure;
a = zeros(np,1);
for i=1:np
  a(i) = nsubplot(np,1,i);
  plot(a(i),X,Y(:,i));
  if mod(i,2)
    set(a(i),'YAxisLocation', 'Right');
  end
  if i < np
    set(a(i),'XTickLabel',[]);
  end
end
addzoom
linkaxes(a,'x');
if nargout > 0
  a_out = a;
end

