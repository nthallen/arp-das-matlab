function CR_1M_C;
% Fit for Steinhart/Hart equation
RD = {
  [ 133	3.29e6 0.96e6 0.56e6 0.33e6	2.83e-4	2.12e-4	5.9e-8 1.0002e6 ], 'Gas1T'
  [ 132 2.78e6 0.8e6 0.47e6 0.27e6 3.46e-4 2.1e-4 6.09e-8 1.0005e6 ], 'Gas2T'
  [ 103 2.83e6 0.82e6 0.48e6 0.28e6 3.63e-4 2.08e-4 6.36e-8 1.0004e6 ], 'CG1MT'
  [ 106 2.67e6 0.77e6 0.45e6 0.26e6 3.52e-4 2.10e-4 6.24e-8 1.0004e6 ], 'SH1MT'
};

Tcal = [ 0 25 37 50 ];

for i=1:size(RD,1)
  X0 = RD{i,1}(6:8)';
  X = lsqcurvefit(@SteinHart, X0, RD{i,1}(2:5)', Tcal );
  fprintf(1,'[ %d %.2g %.2g %.2g %.2g %.6g %.6g %.6g %.4g
function T = SteinHart( Rtherm, a0, a1, a2 )
  logR = log(Rtherm);
  T = 1./(a0 + a1 .* logR + a2.*(logR.^3)) - 273.15;
