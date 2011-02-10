function gencal3( T, Ct, Scale, FromType, Desc, ToType, quiet, fid )
% gencal3( T, Ct, Scale, FromType, Desc, ToType, quiet [, fid] )
%### This is a candidate to migrate into the nort Matlab library
%### Need to generalize the plotting units.
% T Temperature Vector
% Ct Counts Vector
% Scale Scale factor counts should be multiplied by at output
% File File to which to write the TMC calibration
% Desc Descriptive Text
% ToType String identifying the source and dest TMC types:
%      'AD12_T30K, CELCIUS'
% quiet = 0 (or omitted) produces the most verbose output
% quiet = 1 will output "done with ..." messages
% quiet = 2 will not
%
% This version will calculate the Threshold based on dT/dCt
% If specified, fid is an open file handle to which the
% calibration curve will be written. Otherwise, the data
% will be written to FromType + ".tmc".

global Temperature Counts Threshold typename
Temperature=T;
Counts=Ct;
typename=FromType;
if nargin < 8
  fid = -1;
  if nargin < 7
    quiet = 0;
  end
  File=[ typename '.tmc' ];
elseif fid <= 0
  error('Invalid fid');
end

% What I'm really interested in now is dT/dCt over the desired temperature
% range.
dT = diff(Temperature); dC = diff(Counts);
%T1 = Temperature(1:length(dT)) + dT;
dTdC = dT./dC;
Threshold = abs(dTdC/2);
Threshold = [ Threshold(1); Threshold ];
figure;
set(gcf, 'Name', [ typename ' Summary' ] );
set(gcf, 'NumberTitle', 'off' );
subplot(2,1,2);
%plot(T1,dTdC);
semilogy(Temperature,Threshold);
xlabel( ToType );
ylabel('Precision');
grid;
set(gca,'Ylim', [ min(Threshold) max(Threshold) ]);
%set(gca, 'Xlim', [0 150]);
subplot(2,1,1);
CV = allpts2(quiet);
TV = interp1(Counts,Temperature,CV);
if quiet
  plot( Temperature, Counts, 'y', TV, CV, 'xb' );
  grid;
end
title(Desc);
ylabel( FromType );
if fid < 0
  fid=fopen(File, 'w');
end
fprintf(fid, [ '/* ' Desc ' */\n' ] );
fprintf(fid, ['Calibration ( ' FromType ', ' ToType ' ) {'] );
for i = [1:length(CV)]
  fprintf(fid, '\n  %4.0f, %6.5g', CV(i)*Scale, TV(i) );
  if ( i < length(CV) ) fprintf(fid, ','); end
end
fprintf(fid, '\n}\n' );
if nargin < 8
  fclose(fid);
  fprintf(1,'Wrote Calibratrion to %s\n', File );
end

