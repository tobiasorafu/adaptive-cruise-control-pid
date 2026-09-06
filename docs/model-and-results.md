# Model and Results

## Control Architecture

The adaptive cruise-control system uses separation distance as the controlled output. The controller adjusts the following vehicle's traction-force command so that the measured separation converges to a 20 m reference.

The simplified vehicle dynamics are represented by

\[
H(s)=\frac{K}{\tau s+1}
\]

where:

- `K = 0.0028`
- `tau = 3.87 s`

The model is intentionally simple and was used for controller design and tuning before comparison with the nonlinear Simscape vehicle.

## Final PID Gains

| Parameter | Value |
| --- | ---: |
| `Kp` | 1700 |
| `Ki` | 500 |
| `Kd` | 3000 |

## Nominal Response

The final transfer-function response produced:

| Metric | Value |
| --- | ---: |
| Reference separation | 20 m |
| Peak separation | 26.23 m |
| Settling time | 12.27 s |
| Final separation | 20.03 m |

The controller therefore achieved the desired nominal spacing response while keeping the peak below 30 m and settling within the required 10-20 s window.

## Comparison with the Nonlinear Vehicle

A nonlinear Simscape model was used to test whether the controller and simplified plant model remained representative outside the nominal design condition.

At a lead-vehicle demand of 50 m/s:

- the nonlinear following vehicle stabilised near 43 m/s;
- the traction-force command reached the 14,800 N saturation limit;
- the separation distance continued to increase, reaching approximately 118 m by 30 s;
- the linear transfer-function model did not reproduce this limitation because actuator saturation was not included.

The main conclusion is that the first-order vehicle model is useful near the operating range used for identification, but its validity does not extend to conditions dominated by actuator saturation.

## Hill-Disturbance Test

A hill disturbance was introduced in the nonlinear model. The vehicle initially fell behind the lead vehicle as the gradient added resistance. The controller then attempted to recover the target distance, producing a large over-correction.

Observed behaviour included:

- separation increasing to roughly 36 m near the top of the hill;
- a later minimum separation of about 6.6 m;
- continued oscillation around the 20 m reference;
- no complete settling within the 30 s test.

The nominal PID tuning therefore showed poor disturbance rejection under this operating condition.

## Engineering Lessons

The project highlights the difference between obtaining good nominal closed-loop performance and obtaining a controller that remains reliable across nonlinear operating conditions. The nominal PID controller worked well on the identified linear model, but the nonlinear tests exposed actuator limits, speed-range limitations and weak disturbance rejection that were hidden by the simplified model.
