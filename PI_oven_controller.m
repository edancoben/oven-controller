clear all 
close all
clc
pkg load control;

a = 2.5e-3; # constant from newtons cooling equation and experiment run on oven
b = 5e-4; # constant from newtons cooling equation and experiment run on oven

Kp = 50 % proportional gain
KI = Kp * a % integral gain

P = tf([b],[1 a]); # first order system transfer function 
C = tf([Kp KI], [1 0]); # PI control transfer function

G = feedback(P*C); # whole system transfer function
#figure
#plot(step(G)) # plotting my system response


# ***************************************************************
# simulation to test out PI controller gains
# ***************************************************************

p = 0; 
Tamb = 25; # ambient (room) temperature in celsius
T = Tamb; # current temperature
time = 0; # start time
dt = 0.1; # sample rate in sec for the integrator error (10Hz seems to work well)

c = 2000; # constant from newtons cooling equation and experiment run on oven
avg_k = 5; # constant from newtons cooling equation and experiment run on oven

setTemperature = 120; # desired temperature in celsius 
ie = 0; # integral error
tOff = 0; # time oven is off in seconds
minutesOfSimulation = 8; # how long the oven is on in minutes 

for i = 2:(minutesOfSimulation*60/dt)
  %controller
  Tm(i) = T(i-1);
  e = setTemperature - Tm(i); # error measured
  ie = ie + e*dt; # integrator error
  u(i) = e*Kp + ie*KI; # set control effort dependent on error measured and gains (watts)
  
  if u(i) > 1500 # oven takes in 1500 watts and cannot exceed that limit in control effort
    u(i) = 1500;
  endif
  if abs(ie) > 4000.0 # preventing integrator windup
    ie = ie - e*dt; 
  endif
  
  
  tOff = 10 * (u(i) / 1500); # time spent off
  tDuty = mod(i,10/dt)*dt; # with a 10 second duty cycle
  if tDuty <= tOff # oven on
   p(i) = 1500;
  elseif tDuty > tOff # oven off
   p(i) = 0;
  end
  
  % model
  time(i) = time(i-1) + dt; # time in discrete jumps of sample rate
  Tdot = (p(i)-avg_k*(T(i-1)-Tamb))/c; # Newtons cooling equation (first order differential equation)
  T(i) = T(i-1) + Tdot*dt; # simulation of temperature behavior
  
endfor

figure('color','white')

subplot(3,1,1); # oven behavior 
hold on
grid on 
title('Oven Temperature Celcius');
xlabel('time (sec)');
ylabel('Temperature (celsius)');
plot(time,T);

subplot(3,1,2); # oven when on and off
hold on
grid on 
title('Pulse-Width Modulation');
xlabel('time (sec)');
ylabel('Power into system (watts)');
plot(time,p); 

subplot(3,1,3);
e = setTemperature-T; # making sure our oven stays within 1 degree celsius of our set point at all times 
hold on
grid on 
title('Error once we are at desired temperature');
plot(e(end-200:end));