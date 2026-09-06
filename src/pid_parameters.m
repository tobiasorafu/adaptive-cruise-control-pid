%% Adaptive Cruise Control - PID Parameters
% Identified first-order vehicle model and final PID gains used in the
% separation-distance control study.

clear;
clc;

%% Vehicle model
K = 0.0028;
tau = 3.87;          % s
vehiclePlant = tf(K, [tau 1]);

%% PID controller
Kp = 1700;
Ki = 500;
Kd = 3000;
pidController = pid(Kp, Ki, Kd);

%% Main test values
targetSeparation = 20;      % m
tractionForceLimit = 14800; % N

%% Display
vehiclePlant
pidController
