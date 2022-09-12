function a_out = nsubplots( X, Y )
% a = nsubplots( X [, Y] )
% Displays data in multiple axes automatically.
% If X is a scalar, creates X axes
% Optionally returns the list of axes.
if isscalar(X)
  if nargin > 1 || X <= 0 || X > 10
    error('Probably misusing nsubplots(N)');
  end
  N = round(X);
  figure;
  for i = N:-1:1
    a(i) = nsubplot(N,1,i);
  end
else
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
end
if nargout > 0
  a_out = a;
end

