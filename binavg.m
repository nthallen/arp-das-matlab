function [ t_avg, data_avg ] = binavg ( t, data, t_res )

% function [ t_avg, data_avg ] = binavg ( t, data, t_res )

j=1;
for i = min(t):t_res:max(t)
    data_avg(j,:)=nanmean( data( find( t >= i & t < i+t_res ) ,: ),1 );
    t_avg(j)=i+t_res/2;
    j=j+1;
end
