# -*- coding: utf-8 -*-
"""
Created on Fri Nov  6 14:25:28 2020

@author: edanc
"""
import matplotlib.pyplot as plt

import pandas as pd

df = pd.read_csv("Oven_Experiment.csv")

plt.plot(df['seconds'],df['oven_temp'])
plt.plot(df['seconds'],df['room_temp'])

T = df['oven_temp'] - df['room_temp']

plt.show()
print(T)
Tdot = []
for i in range(30):
   Tdot.append((T[i+1] - T[i]) / (df['seconds'][i+1] - df['seconds'][i]) )
   
# Tdot_avg = mean(Tdot)


