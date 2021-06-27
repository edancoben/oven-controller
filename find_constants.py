# -*- coding: utf-8 -*-
"""
Created on Fri Nov  6 14:25:28 2020

@author: edanc
"""
import matplotlib.pyplot as plt
from numpy import diff, mean
import pandas as pd


df = pd.read_csv("Oven_Experiment.csv")
p = 1500

seconds = df[df.columns[0]] - 9 # thinks col name is 8 and 9 is measurement offset
oven_temp = df[df.columns[1]]
room_temp = df[df.columns[2]]

T = oven_temp - room_temp

Tdot_avg = []
for i in range(35):
   Tdot_avg.append( (T[i+1] - T[i]) / (seconds[i+1] - seconds[i]) ) 


 
avg_slope = mean(Tdot_avg)
c = p / avg_slope

Tdot2 = []
k = []
for j in range(180,210):
  Tdot2.append( (T[j+1] - T[j]) / (seconds[j+1] - seconds[j]) )  
  k.append( -c * Tdot2[j-180] / T[j] )  

avg_k = mean(k)
c = 2000
avg_k = 5 # for comparison to tune k

T = [0]
time = [0]
dt = 1
for i in range(1,990):
  time.append(time[i-1] + dt)
  if(i<155): # time when oven 
    p = 1500 # power input of oven
  else:
    p = 0 # oven off
  Tdot = (p-avg_k*T[i-1])/c # newtons cooling equation
  T.append(T[i-1] + Tdot*dt) 



plt.plot(seconds,oven_temp, label='measured temperature') # measured temp
# plt.plot(seconds,room_temp) # showing noise from thermocouple measurements 
plt.plot(time,T+room_temp[1], label='modeled temperature from data') # created model from data
# plt.plot(diff(oven_temp[155:10:-1])/10)
plt.legend()
plt.show()

