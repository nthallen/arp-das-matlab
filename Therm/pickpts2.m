function V = pickpts2( A, B, quiet )
%pickpts
%  V = pickpts2( A, B, quiet )
%   Recursively searches for suitable Counts values provide a
%   suitable lookup table for the global Temperature and Counts
%   vectors. Returns a vector of suitable points starting with A
%   but not including B (as suits the recursion).
global CtMin Tvec ThVec
if nargin < 3
  quiet = 0;
end

V = A;
if ( B - A > 1.5 )
  C = [ A B ];
  T = Tvec( C-CtMin ); % interp1( Counts, Temperature, C );
  Ct = [ A:B ];
  Tt = Tvec( Ct-CtMin ); % interp1( Counts, Temperature, Ct );
  Tt1 = Tvec(A-CtMin)+(Ct-A)*(Tvec(B-CtMin)-Tvec(A-CtMin))/(B-A); %interp1( C, T, Ct );
  err = abs(Tt1 - Tt);
  if ( any( err > ThVec(Ct-CtMin) ))
    M = ceil((A+B)/2);
    if ( M < B )
      if ~quiet
        plot( Tvec(M-CtMin), M, 'xb' );
        drawnow;
      end
      V = pickpts2( A, M, quiet );
      if quiet < 2
        fprintf( 1, 'Done with %f\n', M );
      end
      V = [ V pickpts2( M, B, quiet ) ];
    end
  end
end
