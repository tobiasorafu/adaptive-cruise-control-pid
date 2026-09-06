# Adaptive Cruise Control Using PID Control

A MATLAB/Simulink control project for regulating the separation distance between a lead vehicle and a following vehicle using a PID controller.

The project uses a first-order vehicle model for controller design, tunes the spacing controller against time-domain requirements, and then checks the result against a nonlinear Simscape vehicle to identify where the simplified model stops being reliable.

## Project Overview

The control objective is to maintain a **20 m separation distance** between two vehicles.

The following vehicle is represented by the first-order model

\[
H(s)=\frac{K}{\tau s+1}
\]

with:

- `K = 0.0028`
- `tau = 3.87 s`

The vehicle velocity is integrated to obtain position, while the separation distance is calculated from the difference between the lead- and following-vehicle positions. The PID controller adjusts traction force from the separation-distance error.

```mermaid
flowchart LR
    R[Target separation<br/>20 m] --> E[Distance error]
    D[Measured separation] --> E
    E --> C[PID controller]
    C --> F[Traction force]
    F --> V[Following vehicle<br/>K / (tau s + 1)]
    VL[Lead vehicle velocity] --> S[Relative velocity]
    V --> S
    S --> I[1 / s<br/>Distance dynamics]
    I --> D
```

## PID Tuning

The controller was tuned iteratively by studying how proportional, integral and derivative action affected the separation response.

- Proportional-only control produced a lightly damped oscillatory response.
- Adding integral action reduced steady-state error but made the response less stable.
- Derivative action increased damping and reduced the oscillation.

The final controller gains were:

| Gain | Value |
| --- | ---: |
| `Kp` | 1700 |
| `Ki` | 500 |
| `Kd` | 3000 |

## Closed-Loop Results

The final tuning met the required nominal separation-response limits.

| Metric | Result |
| --- | ---: |
| Target separation | 20 m |
| Peak separation | 26.23 m |
| Settling time | 12.27 s |
| Final separation | 20.03 m |

The response returned to the desired 20 m gap without dropping below the target after the peak, while the maximum separation remained below 30 m.

## Nonlinear Vehicle Validation

The same controller was then evaluated with a nonlinear Simscape vehicle model.

At a lead-vehicle demand of **50 m/s**, the nonlinear following vehicle stabilised near **43 m/s** because the traction force reached the **14,800 N actuator limit**. The simplified transfer-function model did not contain this saturation and therefore continued to predict a much better tracking response.

The comparison exposed an important model limitation: the first-order approximation is useful around the operating range used for identification, but it does not accurately represent the vehicle once actuator saturation and stronger nonlinear effects dominate.

## Disturbance Test

A hill disturbance was introduced to test the controller away from the nominal operating condition.

The separation increased to roughly **36 m**, later fell to about **6.6 m**, and continued oscillating around the 20 m reference without fully settling within the 30 s simulation.

This showed that the nominal PID tuning was not sufficiently robust for the hill-disturbance case.

## What This Project Demonstrates

- First-order vehicle modelling for control design
- Closed-loop PID spacing control
- Manual PID tuning and transient-response analysis
- MATLAB/Simulink implementation
- Validation against a nonlinear Simscape vehicle model
- Identification of actuator saturation and model-validity limits
- Disturbance-response evaluation

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
- compare the fixed-gain PID design with a constraint-aware control approach.

## Repository Structure

```text
adaptive-cruise-control-pid/
├── README.md
├── src/
│   └── pid_parameters.m
├── docs/
│   └── model-and-results.md
├── results/
│   └── performance-summary.csv
└── .gitignore
```

## MATLAB Setup

The `src/pid_parameters.m` script stores the identified first-order vehicle model, final PID gains, target separation and traction-force limit.

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
