%
% program to calculate Temperature from resistance 
% program uses appropriate fits
% data taken 6/6/96 & 6/7/96
% each fit is defined in a function subprogram
hold off
clf
clear
for x=1:.5:20
r=.005*(x-.5);
rm(x)=.005*(x-.5);
T1(x)=f1b1(r);
T0(x)=f1b0(r);
T2(x)=f1b2(r);
T5(x)=f1b5(r);
T4(x)=f1b4(r);
T3(x)=f1b3(r);
T6(x)=f1b6(r);
T7(x)=f1b7(r);
end
plot(rm,T0,'.')
hold
grid
plot(rm,T1,'or')
plot(rm,T2,'ob')
plot(rm,T3,'og')
plot(rm,T4,'o')
plot(rm,T0,'+g')
plot(rm,T6,'+')
plot(rm,T7,'+r')
plot(rm,T5,'+b')
axis([0 .1 400 800])
xlabel('resistance (megohms)')
ylabel('temperature (K)')
title('fits to duct 1 hot therm data')
text(.06,780,'S1FB0="green +"')
text(.06,760,'S1FB1="red o"')
text(.06,740,'S1FB2="blue o"')
text(.06,720,'S1FB3="green o"')
text(.06,700,'S1FB4="yellow o"')
text(.06,680,'S1FB5="blue +"')
text(.06,660,'S1FB6="yellow +"')
text(.06,640,'S1FB7="red +"')
pause
% print -dwinc
axis([0 .1 400 600])
text(.06,580,'S1FB0="green +"')
text(.06,570,'S1FB1="red o"')
text(.06,560,'S1FB2="blue o"')
text(.06,550,'S1FB3="green o"')
text(.06,540,'S1FB4="yellow o"')
text(.06,530,'S1FB5="blue +"')
text(.06,520,'S1FB6="yellow +"')
text(.06,510,'S1FB7="red +"')
pause
% print -dwinc
axis([0 .1 400 500])
