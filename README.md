# Adaptive Cruise Control Using PID Control

A MATLAB/Simulink control project for regulating the separation distance between a lead vehicle and a following vehicle using a PID controller.

The project uses an identified first-order vehicle model for controller design, tunes the spacing controller against time-domain requirements, and then compares the simplified model with a nonlinear Simscape vehicle to identify actuator and model-validity limits.

## Project Overview

The control objective is to maintain a **20 m separation distance** between the lead and following vehicles.

The following vehicle is represented by the first-order model:

$$
H(s)=\frac{K}{\tau s+1}
$$

with:

- `K = 0.0028`
- `tau = 3.87 s`

The time constant was estimated from the 63% point of a simulated vehicle step response. Vehicle velocity is integrated to obtain position, and the relative position of the two vehicles gives the separation distance used for feedback.

### Control architecture

```text
20 m separation reference
        |
        v
  Separation error ---> PID controller ---> Traction force ---> Following vehicle
        ^                                                       |
        |                                                       v
        +--------------- Separation distance <--- Position <--- Velocity
                                      ^
                                      |
                              Lead vehicle position
```

## System Identification

A **9440 N traction-force step** was applied to the virtual vehicle with no hill or bump disturbance. The response reached approximately 60 mph and gave an estimated time constant of **3.87 s**.

The supporting MATLAB script is available in [`src/estimate_time_constant.m`](src/estimate_time_constant.m).

## PID Tuning

The following-vehicle controller was tuned iteratively by observing how proportional, integral and derivative action affected the separation response.

- Proportional-only control produced a lightly damped oscillatory response.
- Adding integral action reduced steady-state error but made the response less stable.
- Derivative action increased damping and reduced the oscillation.

The final controller gains were:

| Gain | Value |
| --- | ---: |
| `Kp` | 1700 |
| `Ki` | 500 |
| `Kd` | 3000 |

The parameter setup is stored in [`src/pid_parameters.m`](src/pid_parameters.m).

## Closed-Loop Results

The final tuning met the nominal separation-response limits.

| Metric | Result |
| --- | ---: |
| Target separation | 20 m |
| Peak separation | 26.23 m |
| Settling time | 12.27 s |
| Final separation | 20.03 m |

The response returned to the desired 20 m gap without dropping below the target after the peak, while the maximum separation remained below 30 m.

## Nonlinear Vehicle Validation

The same controller was evaluated with a nonlinear Simscape vehicle model.

At a lead-vehicle demand of **50 m/s**, the nonlinear following vehicle stabilised near **43 m/s** because the traction-force command reached the **14,800 N actuator limit**. The simplified transfer-function model does not include this saturation and therefore predicts much better tracking.

This comparison shows that the first-order model is useful around the operating range used for identification, but it is not reliable once actuator saturation and stronger nonlinear effects dominate.

## Hill-Disturbance Test

A hill disturbance was introduced to test the controller away from the nominal operating condition.

The separation increased to roughly **36 m**, later fell to about **6.6 m**, and continued oscillating around the 20 m reference without fully settling within the 30 s simulation.

This showed that the nominal PID tuning was not sufficiently robust for the hill-disturbance case.

## What This Project Demonstrates

- first-order vehicle modelling from a simulated step response;
- closed-loop PID spacing control;
- manual PID tuning and transient-response analysis;
- MATLAB/Simulink implementation;
- comparison with a nonlinear Simscape vehicle model;
- identification of actuator saturation and model-validity limits;
- disturbance-response evaluation.

## Limitations Identified

- The linear vehicle model does not represent actuator saturation.
- Controller performance degrades when the vehicle is operated well outside the model-identification range.
- The nominal PID gains provide poor disturbance rejection during the hill test.
- A fixed-gain controller cannot account for all changes in vehicle behaviour across a wide operating range.

## Future Development

The next stage would focus on robustness rather than only improving the nominal response:

- retune the controller across realistic operating speeds and disturbances;
- add actuator-aware anti-windup protection;
- investigate gain scheduling for different vehicle speeds;
- add road-gradient compensation or feedforward control;
- compare the fixed-gain PID design with a constraint-aware control approach such as MPC.

## Repository Structure

```text
adaptive-cruise-control-pid/
├── README.md
├── src/
│   ├── estimate_time_constant.m
│   └── pid_parameters.m
├── docs/
│   └── model-and-results.md
├── results/
│   └── performance-summary.csv
└── .gitignore
```

## MATLAB Setup

```matlab
K = 0.0028;
tau = 3.87;
vehiclePlant = tf(K, [tau 1]);

Kp = 1700;
Ki = 500;
Kd = 3000;
pidController = pid(Kp, Ki, Kd);
```

## Tools

- MATLAB
- Simulink
- Simscape

## References

- R. Rajamani, *Vehicle Dynamics and Control*, 2nd ed., Springer, 2012.
- K. Ogata, *Modern Control Engineering*, 5th ed., Pearson, 2010.
- N. S. Nise, *Control Systems Engineering*, 8th ed., Wiley, 2020.
