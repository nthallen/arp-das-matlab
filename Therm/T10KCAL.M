% T_actual and SF*F*_bit are row vectors, so a transposition is required to get to
% a column vector standard.

global Temperature Counts typename
load lowt_cal.mat
T_actual = T_actual' - 273.15;
rows = length(T_actual);

load t10kold.mat % That's To and Co from the old calibration

fid=fopen('calib.tmc', 'w');
for j=[1:2]
  for k=[0:6]
    if j ~= 1 | k ~= 2
      cmd = [ 'Counts = ' sprintf( 'SF%dF%d_bit(1,[1:rows]);', j, k ) ];
      eval( cmd );
      typename = sprintf('AD12_T10K%d%d', j, k );
    else
      Counts = SFF_bit;
      typename = 'AD12_T10K';
    end
    fprintf( 1, 'Processing type %s\r\n', typename );
    Counts = Counts';
    ilow = Co < min(Counts);
    ihigh = Co > max(Counts);
    Temperature = [ To(ilow); T_actual; To(ihigh) ];
    Counts =      [ Co(ilow); Counts;   Co(ihigh) ];
    Counts = Counts / 16;

    CV = allpts( .5 );
    TV = interp1(Counts,Temperature,CV);
    fprintf(fid, 'Calibration ( %s, CELCIUS ) {', typename );
    for i = [1:length(CV)]
      fprintf(fid, '\r\n  %4.0f, %6.2f', CV(i)*16, TV(i) );
      if ( i < length(CV) ) fprintf(fid, ','); end
    end
    fprintf(fid, '\r\n}\r\n' );
  end
end
