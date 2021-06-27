clear all
close all
clc

x = csvread ("Oven_Experiment.csv");

p = 1500;

seconds = x(:,1) - 8;
oven_temp = x(:,2);
room_temp = x(:,3);

T = oven_temp - room_temp;



for i = 1:35
  Tdot_avg(i) = (T(i+1) - T(i)) / (seconds(i+1) - seconds(i));
endfor


avg_slope = mean(Tdot_avg)
c = p / avg_slope

for j = 180:210
  Tdot2(j-179) = (T(j+1) - T(j)) / (seconds(j+1) - seconds(j));
  k(j-179) = -c * Tdot2(j-179) / T(j);
endfor
avg_k = mean(k)

c = 2000
avg_k = 5 #10.225

T = 0;
time = 0;
dt = 1;
for i = 2:990
  time(i) = time(i-1) + dt;
  if(i<155)
    p = 1500;
  else
    p = 0;
  endif
  Tdot = (p-avg_k*T(i-1))/c;
  T(i) = T(i-1) + Tdot*dt;
endfor

figure
plot(seconds,oven_temp); # measured temp
hold on;
#plot(seconds,room_temp);
plot(time,T+room_temp(1)); # created model from data
#plot(diff(oven_temp(155:10:end))/10)
