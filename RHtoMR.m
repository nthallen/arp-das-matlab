function mr = RHtoMR(RH, T)
  % mr = RHtoMR(RH, T);
  % RH is the relative humidity expressed as a fraction
  % T is the temperature in Celcius
  
  % This is based on tables from:
  % http://www.atmo.arizona.edu/students/courselinks/fall12/atmo336/lectures/sec1/Saturation_Mixing_Ratio_Tables.htm
  % Column 1 is Celcius
  % Column 2 is saturation mixing ratio by mass in g/Kg
  % We need to convert to mixing ratio by volume, using
  % H2O 18 g/Mol and Air 29 g/Mol
TvsSMR = [
  -40, 0.1
  -30, 0.3
  -20, 0.8
  -10, 1.8
  0, 3.8
  5, 5.4
  10, 7.6
  15, 10.6
  20, 14.7
  25, 20.1
  30, 27.2
  35, 36.6
  40, 49.0
  ];
H2Owt = 18; % g/Mol
Airwt = 29; % g/Mol
SMRm = interp1(TvsSMR(:,1),TvsSMR(:,2),T)*1e-3; % g/g
SMRv = SMRm * Airwt/H2Owt; % Mol/Mol
mr = RH.*SMRv;

