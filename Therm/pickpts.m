function V = pickpts( A, B, threshold )
%pickpts
%  V = pickpts( A, B, threshold )
%   Recursively searches for suitable Counts values provide a
%   suitable lookup table for the global Temperature and Counts
%   vectors. Returns a vector of suitable points starting with A
%   but not including B (as suits the recursion).
global CtMin Tvec
V = A;
if ( B - A > 1.5 )
  C = [ A B ];
  T = Tvec( C-CtMin ); % interp1( Counts, Temperature, C );
  Ct = [ A:B ];
  Tt = Tvec( Ct-CtMin ); % interp1( Counts, Temperature, Ct );
  Tt1 = Tvec(A-CtMin)+(Ct-A)*(Tvec(B-CtMin)-Tvec(A-CtMin))/(B-A); %interp1( C, T, Ct );
  err = max(abs(Tt1 - Tt));
  if ( err > threshold )
    % figure;
    % subplot(2,1,1);
    % plot(Ct,Tt,Ct,Tt1);
    % subplot(2,1,2);
    % plot(Ct,Tt-Tt1);
    % pause;
    % close(gcf);
    M = ceil((A+B)/2);
    if ( M < B )
      % fprintf( 1, 'Trying %f\n', M );
      plot( Tvec(M-CtMin), M, 'xb' );
      drawnow;
      V = pickpts( A, M, threshold );
      fprintf( 1, 'Done with %f\n', M );
      V = [ V pickpts( M, B, threshold ) ];
    end
  end
end
