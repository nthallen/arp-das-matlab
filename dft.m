function F = dft( X, Y, f, verbose )
% F = dft( X, Y, f [, verbose] );
% Evaluate the Discrete Fourier Transform (DFT)
% of columns of X vs Y at frequencies f.
% If verbose is non-zero, some diagnostic information is printed
if size(X,1) ~= size(Y,1)
  error('X and Y must have the same number of rows');
end
if size(X,2) == 1
  dx = 0;
else
  dx = 1;
end
if size(Y,2) == 1
  dy = 0;
else
  dy = 1;
end
if nargin < 4, verbose = 0; end
ncols = max(size(X,2),size(Y,2));
if dx && dy && (size(X,2) ~= size(Y,2))
  error('X and Y must have the same number of columns');
end
F = zeros(length(f),ncols);
if dx == 0 && all(~any(isnan(X))) && all(~any(isnan(Y)))
  % all columns of Y have the same X coordinates
  % and there are no NaNs buried in either vector
  if verbose
    fprintf(1,'Doing optimized dft\n');
  end
  for k = 1:length(f)
    F(k,:) = exp(-1i*2*pi*f(k)*X)' * Y;
  end
else
  if verbose
    fprintf(1,'Doing slow dft\n');
  end
  for i = 0:ncols-1
    x = X(:,i*dx+1);
    y = Y(:,i*dy+1);
    v = ~isnan(x)&~isnan(y);
    for k = 1:length(f)
      F(k,i+1) = sum(y(v) .* exp(-1i*2*pi*f(k)*x(v)));
    end
  end
end