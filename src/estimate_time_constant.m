%% Estimate vehicle time constant from simulated step response
% Uses the logged speed response from the Simulink model to estimate the
% first-order time constant from the 63% response point.

raw = out.speedResponse;
t = raw.time;
v = squeeze(raw.signals.values);

% Remove repeated time samples before searching the response.
[t, idx] = unique(t);
v = v(idx);

% Estimate the steady-state speed from the final samples.
finalValue = mean(v(end-50:end));
target63 = 0.63 * finalValue;

% Find the first time the response reaches 63% of steady state.
idx63 = find(v >= target63, 1, 'first');
timeConstant = t(idx63);

fprintf('Final value: %.3f mph\n', finalValue);
fprintf('63%% value: %.3f mph\n', target63);
fprintf('Estimated time constant: %.3f s\n', timeConstant);

figure;
plot(t, v, 'LineWidth', 1.5);
hold on;
yline(finalValue, '--');
plot(timeConstant, target63, 'o', 'MarkerSize', 7, 'MarkerFaceColor', 'auto');
xline(timeConstant, '--');
text(timeConstant + 0.5, target63 - 3, ...
    sprintf('\\tau = %.2f s', timeConstant), 'FontSize', 11);
grid on;
xlabel('Time (s)');
ylabel('Speed (mph)');
title('Speed Response to 9440 N Traction Force Step');
