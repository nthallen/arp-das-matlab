function getrun_startup(ui_func_handle, data_dir_func_name, title)
% getrun_startup(ui_func_handle, data_dir_func_name, title);
% ui_func_handle: handle of the ui_ function to start the instrument's
%   engineering graphing tool
% data_dir_func_name: char array with the name of the data_dir_func.
% title: (optional) char array specifying the title to display on the UI
%
% The directory reported by the data_dir_func is the location where
% runs.dat is located.
pdir = ne_load_runsdir(data_dir_func_name);
cd(pdir);
[fd,~] = fopen('runs.dat','r');
if fd > 0
    tline = fgetl(fd);
    while ischar(tline)
        fprintf(1,'Processing: "%s"\n', tline);
        if exist(tline,'dir') == 7
            oldfolder = cd(tline);
            csv2mat;
            delete *.csv
            cd(oldfolder);
        end
        tline = fgetl(fd);
    end
    fclose(fd);
    delete runs.dat
end
if nargin < 3
  ui_func_handle(data_dir_func_name);
else
  ui_func_handle(data_dir_func_name, title);
end
