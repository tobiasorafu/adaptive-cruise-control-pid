# Adaptive Cruise Control Using PID Control

A MATLAB/Simulink control project for regulating the separation distance between a lead vehicle and a following vehicle using a PID controller.

The project starts with a first-order vehicle model, tunes a PID spacing controller, evaluates the closed-loop response, and then compares the simplified model against a nonlinear Simscape vehicle. The comparison is used to identify where the controller performs well and where actuator limits and road disturbances become important.

## Project Overview

The control objective is to maintain a **20 m separation distance** between two vehicles.

The following vehicle is represented by the first-order model

\[
H(s)=\frac{K}{\tau s+1}
\]

with the identified parameters:

- `K = 0.0028`
- `tau = 3.87 s`

The vehicle velocity is integrated to obtain position, and the separation distance is determined from the difference between the lead- and following-vehicle positions. A PID controller adjusts the traction-force command from the separation-distance error.

![Adaptive cruise control block diagram](figures/acc-block-diagram.png)

## PID Controller

The controller was tuned iteratively by studying the effect of proportional, integral and derivative action on the separation response. Proportional-only control produced a weakly damped oscillatory response. Adding integral action reduced steady-state error but made the response less stable. Derivative action was then used to increase damping and reduce the oscillation.

The final controller gains were:

| Gain | Value |
| --- | ---: |
| `Kp` | 1700 |
| `Ki` | 500 |
| `Kd` | 3000 |

## Closed-Loop Results

The final tuning met the required separation-response limits.

| Metric | Result |
| --- | ---: |
| Target separation | 20 m |
| Peak separation | 26.23 m |
| Settling time | 12.27 s |
| Final separation | 20.03 m |

![PID separation response](figures/pid-separation-response.png)

The response reaches the target without dropping below the 20 m reference after the peak, while the peak remains below 30 m.

## Nonlinear Vehicle Validation

The same controller was also evaluated using a nonlinear Simscape vehicle model.

![Simulink adaptive cruise control model](figures/simulink-acc-model.png)

At a lead-vehicle demand of **50 m/s**, the nonlinear following vehicle could only stabilise near **43 m/s** because the traction force reached the **14,800 N actuator limit**. The simplified transfer-function model did not include this saturation and therefore continued to track the demanded condition.

![Transfer-function and Simscape comparison](figures/linear-vs-simscape.png)

This comparison shows an important model limitation: the first-order approximation is useful around the operating range used for identification, but it should not be expected to predict behaviour accurately once actuator limits and stronger nonlinear effects dominate.

## Disturbance Test

A hill disturbance was introduced to test the controller away from the nominal operating condition.

![Hill disturbance response](figures/hill-disturbance-response.png)

The disturbance caused large overshoot and undershoot in separation distance and the system did not fully settle within the 30 s simulation. This showed that the final nominal PID tuning was not sufficiently robust for strong road-gradient disturbances.

## What This Project Demonstrates

- First-order vehicle modelling for control design
- Closed-loop PID spacing control
- Manual PID tuning and transient-response analysis
- MATLAB/Simulink implementation
- Validation against a nonlinear Simscape vehicle model
- Identification of actuator saturation and model-validity limits
- Disturbance-response evaluation

## Limitations

The project also exposed several limitations that are useful for further development:

- The linear vehicle model does not represent actuator saturation.
- Controller performance degrades when the vehicle is operated far outside the identification range.
- The nominal PID gains provide poor disturbance rejection during the hill test.
- A fixed-gain PID controller cannot account for all changes in vehicle dynamics across a wide operating range.

## Future Work

The next development stage would focus on improving robustness rather than only retuning the nominal response. Useful extensions include:

- retuning the controller for realistic operating speeds and disturbances;
- adding actuator-aware anti-windup protection;
- testing gain scheduling across different vehicle speeds;
- adding road-gradient compensation or feedforward control;
- comparing the PID design with MPC or another constraint-aware controller.

## Project Structure

```text
adaptive-cruise-control-pid/
├── README.md
├── docs/
│   └── model-and-results.md
├── figures/
│   ├── acc-block-diagram.png
│   ├── simulink-acc-model.png
│   ├── pid-separation-response.png
│   ├── linear-vs-simscape.png
│   └── hill-disturbance-response.png
├── results/
│   └── performance-summary.csv
└── .gitignore
```

## Tools

- MATLAB
- Simulink
- Simscape

## References

- R. Rajamani, *Vehicle Dynamics and Control*, 2nd ed., Springer, 2012.
- K. Ogata, *Modern Control Engineering*, 5th ed., Pearson, 2010.
- N. S. Nise, *Control Systems Engineering*, 8th ed., Wiley, 2020.
