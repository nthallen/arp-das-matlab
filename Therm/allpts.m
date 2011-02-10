function V = allpts( threshold )
%allpts
%  Uses the global Counts and Temperature vectors and pickpts()
%  to pick a complete vector of suitable Counts values for a
%  lookup table
global Counts Temperature typename
global CtMin Tvec

A = ceil(min(Counts));
B = floor(max(Counts));
C = [ A B ]
T = interp1( Counts, Temperature, C );
plot( Temperature, Counts, 'y', T, C, 'xy' );
xlabel( 'Temperature' );
ylabel( 'Counts' );
if length(typename) > 0
  title( typename )
end
drawnow;
hold;
C = [A:B];
CtMin = A-1;
Tvec = interp1( Counts, Temperature, C );
% ginput(1);

CV = [ pickpts( A, B, threshold ) B ];
fprintf( 1, 'Optimizing...\n' );
l = length(CV);
V = CV(1);
lastC = CV(1);
for i=[2:l-1]
  C = [ lastC CV(i+1) ];
  T = Tvec(C-CtMin); % interp1( Counts, Temperature, C );
  Ct = [ lastC:CV(i+1) ];
  Tt = Tvec(Ct-CtMin); % interp1( Counts, Temperature, Ct );
  Tt1 = (Ct-lastC)*(Tvec(CV(i+1)-CtMin)-Tvec(lastC-CtMin))/(CV(i+1)-lastC);
  Tt1 = Tt1 + Tvec(lastC-CtMin);
  err = max(abs(Tt1 - Tt));
  if ( err > threshold )
    V = [ V CV(i) ];
    lastC = CV(i);
  else
    fprintf( 1, 'Optimized out %.0f\n', CV(i) );
    plot( interp1( Counts, Temperature, CV(i)), CV(i), 'xr' );
    drawnow;
  end
end
V = [ V CV(l) ];
hold;
