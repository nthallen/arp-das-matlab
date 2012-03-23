function csv2mat(pattern)
%csv2mat(pattern)
%  Reads .csv files in and saves the contents to .mat files.
%  pattern is an optional argument to specify with files to
%  convert. The default is '*.csv'

if nargin < 1
    pattern = '*.csv';
end
files = dir(pattern);
for i = 1:length(files)
    ifile = files(i).name;
    dataparts = importdata(ifile,',');
    for i = 1:size(dataparts.colheaders, 2)
        data.(dataparts.colheaders{i}) = dataparts.data(:,i);
    end
    ext = max(strfind(ifile,'.'));
    if isempty(ext)
        ofile = [ ifile '.mat' ];
    else
        ofile = [ ifile(1:ext) 'mat'];
    end
    save(ofile,'-struct','data');
    fprintf(1,'Converted %s to %s\n', ifile, ofile);
end
