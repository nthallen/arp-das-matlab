%%
% data_fields tests
close all
clear all
clc

% Setup the figure
fig = figure;
set(fig,'color',[.8 .8 1]);
dfs = data_fields(fig,'h_leading', 5, 'txt_fontsize', 12);
rec = 'engeng_1';
Tvar = [ 'T' rec ];
T0 = 
%%
% What happens if I add a graph with a record that I have not
% previously mentioned? It borked, but was easy to create record
% automatically.
% dfs.new_graph(rec, 'CPU_Pct', 'new_fig');
dfs.new_graph(rec, 'X', 'new_fig');
%%
str.(Tvar) = 
%%
% Setup the data connection
dfs.connect('127.0.0.1', 1080);
%%
dfs.disconnect();
close all
clear all
clc
