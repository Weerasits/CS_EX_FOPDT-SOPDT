%% FOPDT (First Order Plus Dead Time) Step Response Analysis
% Professor-level example for instrumentation and control
% System: G(s) = K*exp(-L*s)/(τ*s + 1) - FOPDT Model
% Author: Control Systems Analysis - Process Control Focus
% Date: 2025

clear all; close all; clc;

%% Define symbolic variables
syms s t K L tau real positive

% Display header
fprintf('=== FOPDT (First Order Plus Dead Time) Step Response Analysis ===\n\n');

%% Method 1: General Symbolic Transfer Function Analysis
fprintf('Method 1: General Symbolic Analysis of FOPDT\n');
fprintf('-------------------------------------------\n');

% Define the FOPDT transfer function
% G(s) = K*exp(-L*s)/(tau*s + 1)
G_sym = K * exp(-L*s) / (tau*s + 1);

fprintf('FOPDT Transfer Function: G(s) = %s\n', char(G_sym));
fprintf('Where:\n');
fprintf('  K = Process gain (steady-state gain)\n');
fprintf('  L = Dead time (transport delay) [time units]\n');
fprintf('  tau = Time constant [time units]\n');
fprintf('  Typical range: L/tau ratio from 0.1 to 2.0 for most processes\n\n');

% Step input in Laplace domain: 1/s
% Y(s) = G(s) * (1/s)
Y_s = G_sym * (1/s);
fprintf('Output for unit step: Y(s) = G(s) * (1/s) = %s\n', char(Y_s));

% The inverse Laplace transform involves the delay
fprintf('\nStep response (general symbolic form):\n');
fprintf('y(t) = K * (1 - exp(-(t-L)/τ)) * u(t-L)\n');
fprintf('where u(t-L) is the unit step function delayed by L\n\n');

% Time domain interpretation
fprintf('Time domain behavior:\n');
fprintf('• For t < L: y(t) = 0 (dead time period)\n');
fprintf('• For t ≥ L: y(t) = K * (1 - exp(-(t-L)/tau))\n');
fprintf('• Final value: y(infinity) = K\n');
fprintf('• Time constant: tau (63.2 percent of final value reached at t = L + tau)\n\n');

%% Method 2: Specific Numerical Example
fprintf('Method 2: Specific Numerical Example\n');
fprintf('-----------------------------------\n');

% Define typical process parameters
K_val = 2.5;     % Process gain
L_val = 1.2;     % Dead time (seconds)
tau_val = 3.8;   % Time constant (seconds)

fprintf('Process Control Example:\n');
fprintf('G(s) = %.1f * exp(-%.1fs) / (%.1fs + 1)\n', K_val, L_val, tau_val);
fprintf('Parameters:\n');
fprintf('  Process gain K = %.1f\n', K_val);
fprintf('  Dead time L = %.1f seconds\n', L_val);
fprintf('  Time constant τ = %.1f seconds\n', tau_val);
fprintf('  L/tau ratio = %.3f (typical for process control)\n', L_val/tau_val);

% Substitute numerical values
G_num = K_val * exp(-L_val*s) / (tau_val*s + 1);
Y_s_num = G_num * (1/s);

fprintf('\nNumerical step response:\n');
fprintf('y(t) = %.1f * (1 - exp(-(t-%.1f)/%.1f)) * u(t-%.1f)\n', ...
        K_val, L_val, tau_val, L_val);

%% Method 3: Time Domain Analysis
fprintf('\nMethod 3: Time Domain Analysis\n');
fprintf('-----------------------------\n');

% Time vector for analysis
t_vec = 0:0.1:15;  % Extended time range to show complete response

% Calculate step response
y_values = zeros(size(t_vec));
for i = 1:length(t_vec)
    if t_vec(i) >= L_val
        y_values(i) = K_val * (1 - exp(-(t_vec(i) - L_val)/tau_val));
    else
        y_values(i) = 0;  % Dead time period
    end
end

% Key time points analysis
fprintf('Key Time Points Analysis:\n');
fprintf('Dead time period: 0 ≤ t < %.1f seconds\n', L_val);
fprintf('Response start: t = %.1f seconds\n', L_val);

% 63.2% of final value (one time constant)
t_63 = L_val + tau_val;
y_63 = K_val * 0.632;
fprintf('63.2 percent response: t = L + tau = %.1f + %.1f = %.1f seconds, y = %.2f\n', ...
        L_val, tau_val, t_63, y_63);

% 95% of final value (approximately 3 time constants)
t_95 = L_val + 3*tau_val;
y_95 = K_val * 0.95;
fprintf('95 percent response: t = L + 3*tau = %.1f + %.1f = %.1f seconds, y = %.2f\n', ...
        L_val, 3*tau_val, t_95, y_95);

% 99% of final value (approximately 5 time constants)
t_99 = L_val + 5*tau_val;
y_99 = K_val * 0.99;
fprintf('99 percent response: t = L + 5*tau = %.1f + %.1f = %.1f seconds, y = %.2f\n', ...
        L_val, 5*tau_val, t_99, y_99);

fprintf('Final value: y(∞) = K = %.1f\n', K_val);

%% Method 4: System Characteristics Analysis
fprintf('\nMethod 4: FOPDT System Characteristics\n');
fprintf('-------------------------------------\n');

% Poles and zeros analysis
fprintf('Poles and Zeros:\n');
fprintf('  Pole: s = -1/tau = -1/%.1f = %.3f (LHP - stable)\n', tau_val, -1/tau_val);
fprintf('  Zeros: None (except at infinity due to delay)\n');
fprintf('  Dead time: Pure delay element e^(-Ls)\n\n');

% Stability analysis
fprintf('Stability Analysis:\n');
fprintf('  Single pole in LHP → Stable system\n');
fprintf('  Dead time adds phase lag but does not affect stability\n');
fprintf('  BIBO stable for any finite L and positive τ\n\n');

% DC gain analysis
dc_gain = K_val;  % For FOPDT, DC gain = K
fprintf('Steady-State Analysis:\n');
fprintf('  DC gain: K = %.1f\n', dc_gain);
fprintf('  System type: Type 0 (finite steady-state error to step)\n');
fprintf('  Position error constant: Kp = K = %.1f\n', dc_gain);
ess_step = 1 / (1 + dc_gain);
fprintf('  Steady-state error (step): ess = 1/(1+Kp) = %.4f = %.2f percent\n', ...
        ess_step, ess_step*100);

% Process characteristics
fprintf('\nProcess Characteristics:\n');
fprintf('  Dominant time constant: tau = %.1f seconds\n', tau_val);
fprintf('  Dead time: L = %.1f seconds\n', L_val);
fprintf('  L/tau ratio: %.3f', L_val/tau_val);
ratio_val = L_val/tau_val;
if ratio_val < 0.1
    fprintf(' (fast process, minimal delay)\n');
elseif ratio_val < 0.5
    fprintf(' (moderate delay)\n');
elseif ratio_val < 1.0
    fprintf(' (significant delay)\n');
else
    fprintf(' (delay-dominated process)\n');
end

% Control difficulty assessment
control_difficulty = L_val / tau_val;
fprintf('  Control difficulty factor: L/tau = %.3f', control_difficulty);
if control_difficulty < 0.2
    fprintf(' (easy to control)\n');
elseif control_difficulty < 0.5
    fprintf(' (moderate control difficulty)\n');
elseif control_difficulty < 1.0
    fprintf(' (challenging to control)\n');
else
    fprintf(' (very difficult to control)\n');
end

%% Method 5: Performance Metrics
fprintf('\nMethod 5: FOPDT Performance Metrics\n');
fprintf('-----------------------------------\n');

% Rise time (10% to 90% of final value)
t_10 = L_val + tau_val * log(1/0.9);  % Time to reach 10%
t_90 = L_val + tau_val * log(1/0.1);  % Time to reach 90%  
rise_time = t_90 - t_10;

fprintf('Rise Time Analysis (10 to 90 percent):\n');
fprintf('  10 percent point: t_10 = L + tau*ln(1/0.9) = %.2f seconds\n', t_10);
fprintf('  90 percent point: t_90 = L + tau*ln(1/0.1) = %.2f seconds\n', t_90);
fprintf('  Rise time: t_r = t_90 - t_10 = %.2f seconds\n', rise_time);

% Settling time (2% criterion)
settling_time_2 = L_val + tau_val * log(50);  % 2% settling time
settling_time_5 = L_val + tau_val * log(20);  % 5% settling time

fprintf('\nSettling Time Analysis:\n');
fprintf('  2 percent settling time: ts = L + tau*ln(50) = %.2f seconds\n', settling_time_2);
fprintf('  5 percent settling time: ts = L + tau*ln(20) = %.2f seconds\n', settling_time_5);

% Delay time (50% of final value)
delay_time = L_val + tau_val * log(2);  % Using log(2) instead of -log(0.5)
fprintf('  Delay time (50 percent point): td = L + tau*ln(2) = %.2f seconds\n', delay_time);

% Maximum slope (at the start of response)
max_slope = K_val / tau_val;
fprintf('\nMaximum Slope Analysis:\n');
fprintf('  Maximum slope: dy/dt|max = K/tau = %.1f/%.1f = %.3f units/second\n', ...
        K_val, tau_val, max_slope);
fprintf('  Occurs at: t = L = %.1f seconds (start of response)\n', L_val);

%% Method 6: Frequency Domain Characteristics
fprintf('\nMethod 6: Frequency Domain Analysis\n');
fprintf('----------------------------------\n');

% Frequency response characteristics
omega_c = 1/tau_val;  % Corner frequency
fprintf('Frequency Response:\n');
fprintf('  Corner frequency: omega_c = 1/tau = %.3f rad/s = %.3f Hz\n', omega_c, omega_c/(2*pi));
fprintf('  -3dB frequency: Same as corner frequency for first-order\n');

% Phase characteristics
fprintf('  Phase at omega = 0: phi(0) = 0° (excluding delay)\n');
fprintf('  Phase at omega_c: phi(omega_c) = -45° (excluding delay)\n');
fprintf('  Phase at omega -> inf: phi(inf) = -90° (excluding delay)\n');
fprintf('  Dead time adds: -L*omega*180/pi degrees at frequency omega\n');

% Bandwidth
bandwidth = omega_c;
fprintf('  Bandwidth (approximate): BW ≈ 1/tau = %.3f rad/s\n', bandwidth);

%% Method 7: Graphical Analysis
fprintf('\nMethod 7: Comprehensive Graphical Analysis\n');
fprintf('-----------------------------------------\n');

% Create comprehensive plot
figure('Position', [100, 100, 1200, 900]);

% Subplot 1: Step response with annotations
subplot(2,3,1);
plot(t_vec, y_values, 'b-', 'LineWidth', 2.5);
hold on;

% Add key points
plot(L_val, 0, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Response start');
plot(t_63, y_63, 'gs', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', '63.2% point');
plot(t_95, y_95, 'm^', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', '95% point');

% Add reference lines
yline(K_val, 'r--', 'LineWidth', 1.5, 'Label', sprintf('Final Value = %.1f', K_val));
yline(y_63, 'g:', 'LineWidth', 1, 'Alpha', 0.7);
yline(y_95, 'm:', 'LineWidth', 1, 'Alpha', 0.7);
xline(L_val, 'r:', 'LineWidth', 1, 'Alpha', 0.7, 'Label', sprintf('L = %.1fs', L_val));
xline(t_63, 'g:', 'LineWidth', 1, 'Alpha', 0.7);
xline(t_95, 'm:', 'LineWidth', 1, 'Alpha', 0.7);

% Shade dead time region
fill([0, L_val, L_val, 0], [0, 0, K_val*1.1, K_val*1.1], 'red', ...
     'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', 'Dead Time');

grid on;
xlabel('Time (seconds)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('FOPDT Step Response', 'FontSize', 14, 'FontWeight', 'bold');
legend('Step Response', 'Response Start', '63.2% Point', '95% Point', ...
       'Dead Time Region', 'Location', 'best', 'FontSize', 9);
xlim([0, 15]);
ylim([0, K_val*1.1]);

% Add text annotations
text(L_val/2, K_val*0.5, sprintf('Dead Time\nL = %.1fs', L_val), ...
     'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');
text(L_val + tau_val/2, K_val*0.8, sprintf('tau = %.1fs', tau_val), ...
     'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', 'blue', 'FontWeight', 'bold');

% Subplot 2: Pole-zero map
subplot(2,3,2);
pole_location = -1/tau_val;
plot(pole_location, 0, 'rx', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Pole');
hold on;

% Draw axes
line([-1, 0.2], [0, 0], 'Color', 'k', 'LineWidth', 0.5);  % Real axis
line([0, 0], [-0.5, 0.5], 'Color', 'k', 'LineWidth', 0.5);  % Imaginary axis

% Mark origin
plot(0, 0, 'ko', 'MarkerSize', 4);

% Add grid and labels
grid on;
xlabel('Real Part (σ)', 'FontSize', 12);
ylabel('Imaginary Part (jω)', 'FontSize', 12);
title('Pole-Zero Map', 'FontSize', 14, 'FontWeight', 'bold');
text(pole_location, -0.1, sprintf('s = -1/tau\n= %.3f', pole_location), ...
     'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', 'red');
legend('Pole', 'Location', 'best');
xlim([-1, 0.2]);
ylim([-0.5, 0.5]);
axis equal;

% Subplot 3: Response components breakdown
subplot(2,3,3);
t_response = t_vec(t_vec >= L_val);
y_exponential = K_val * (1 - exp(-(t_response - L_val)/tau_val));
y_steady_state = K_val * ones(size(t_response));
y_transient = -K_val * exp(-(t_response - L_val)/tau_val);

plot(t_response, y_steady_state, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Steady State (K)');
hold on;
plot(t_response, y_transient, 'g--', 'LineWidth', 1.5, 'DisplayName', '-K*exp(-(t-L)/tau)');
plot(t_response, y_exponential, 'b-', 'LineWidth', 2, 'DisplayName', 'Total Response');

% Show dead time region
t_dead = t_vec(t_vec < L_val);
y_dead = zeros(size(t_dead));
plot(t_dead, y_dead, 'k-', 'LineWidth', 2, 'DisplayName', 'Dead Time');

grid on;
xlabel('Time (seconds)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('Response Components', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
xlim([0, 12]);

% Subplot 4: System information
subplot(2,3,4);
axis off;

% Determine control difficulty string
if control_difficulty < 0.2
    difficulty_str = 'Easy';
elseif control_difficulty < 0.5
    difficulty_str = 'Moderate';
elseif control_difficulty < 1.0
    difficulty_str = 'Challenging';
else
    difficulty_str = 'Difficult';
end

info_text = {
    'FOPDT System Information:';
    '';
    sprintf('Transfer Function: G(s) = %.1f*e^{-%.1fs}/(%.1fs+1)', K_val, L_val, tau_val);
    '';
    'Parameters:';
    sprintf('  Process gain: K = %.1f', K_val);
    sprintf('  Dead time: L = %.1f seconds', L_val);
    sprintf('  Time constant: tau = %.1f seconds', tau_val);
    sprintf('  L/tau ratio: %.3f', L_val/tau_val);
    '';
    'Characteristics:';
    sprintf('  Pole: s = %.3f (stable)', pole_location);
    sprintf('  DC gain: %.1f', dc_gain);
    sprintf('  Corner freq: %.3f rad/s', omega_c);
    '';
    'Performance Metrics:';
    sprintf('  Rise time: %.2f s', rise_time);
    sprintf('  Settling time (2%%): %.2f s', settling_time_2);
    sprintf('  Max slope: %.3f units/s', max_slope);
    '';
    'Control Assessment:';
    sprintf('  L/tau = %.3f -> %s', control_difficulty, difficulty_str);
};
text(0.05, 0.95, info_text, 'FontSize', 10, 'VerticalAlignment', 'top', ...
     'FontName', 'FixedWidth');

% Subplot 5: Frequency response magnitude
subplot(2,3,5);
omega = logspace(-2, 1, 1000);
H_mag = K_val ./ sqrt(1 + (omega * tau_val).^2);

semilogx(omega, 20*log10(H_mag), 'b-', 'LineWidth', 2);
hold on;
semilogx(omega_c, 20*log10(K_val/sqrt(2)), 'ro', 'MarkerSize', 8, 'LineWidth', 2);

grid on;
xlabel('Frequency (rad/s)', 'FontSize', 12);
ylabel('Magnitude (dB)', 'FontSize', 12);
title('Frequency Response (without delay)', 'FontSize', 14, 'FontWeight', 'bold');

% Add -3dB line
yline(20*log10(K_val) - 3, 'r--', 'LineWidth', 1, 'Label', '-3dB Line');
xline(omega_c, 'r:', 'LineWidth', 1, 'Label', sprintf('Corner Freq = %.3f', omega_c));

% Subplot 6: Phase response
subplot(2,3,6);
H_phase = -atan(omega * tau_val) * 180/pi;  % Phase without delay
H_phase_delay = H_phase - omega * L_val * 180/pi;  % Phase with delay

semilogx(omega, H_phase, 'b-', 'LineWidth', 2, 'DisplayName', 'Without delay');
hold on;
semilogx(omega, H_phase_delay, 'r-', 'LineWidth', 2, 'DisplayName', 'With delay');
semilogx(omega_c, -45, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', '-45° point');

grid on;
xlabel('Frequency (rad/s)', 'FontSize', 12);
ylabel('Phase (degrees)', 'FontSize', 12);
title('Phase Response', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);

sgtitle('FOPDT (First Order Plus Dead Time) - Complete Analysis', ...
        'FontSize', 16, 'FontWeight', 'bold');

%% Method 8: Process Control Applications
fprintf('Method 8: Process Control Applications\n');
fprintf('-------------------------------------\n');

fprintf('Common FOPDT Process Examples:\n');
fprintf('  Temperature control systems (heaters, reactors)\n');
fprintf('  Level control in tanks with outlet delay\n');
fprintf('  Flow control with pipeline delays\n');
fprintf('  Chemical reactor concentration control\n');
fprintf('  Heat exchanger temperature control\n\n');

fprintf('Typical L/tau Ratios by Industry:\n');
fprintf('  Thermal processes: 0.1 - 0.5 (moderate delay)\n');
fprintf('  Chemical reactors: 0.2 - 1.0 (significant delay)\n');
fprintf('  Pipeline systems: 0.5 - 2.0 (delay-dominated)\n');
fprintf('  Level control: 0.1 - 0.3 (minimal delay)\n\n');

fprintf('Control Design Implications:\n');
if control_difficulty < 0.2
    fprintf('  PI/PID control works well\n');
    fprintf('  Fast setpoint tracking possible\n');
    fprintf('  Good disturbance rejection\n');
elseif control_difficulty < 0.5
    fprintf('  PID control adequate with proper tuning\n');
    fprintf('  Moderate performance limitations\n');
    fprintf('  Consider feedforward for disturbances\n');
elseif control_difficulty < 1.0
    fprintf('  PID requires careful tuning\n');
    fprintf('  Significant performance limitations\n');
    fprintf('  Smith predictor may be beneficial\n');
    fprintf('  Feedforward control recommended\n');
else
    fprintf('  Standard PID may be inadequate\n');
    fprintf('  Smith predictor strongly recommended\n');
    fprintf('  Advanced control strategies needed\n');
    fprintf('  Feedforward control essential\n');
end

fprintf('\nTuning Guidelines for PID Control:\n');
% Ziegler-Nichols tuning rules for FOPDT
Kc_zn = 1.2 * tau_val / (K_val * L_val);
Ti_zn = 2 * L_val;
Td_zn = 0.5 * L_val;

fprintf('Ziegler-Nichols PID Tuning:\n');
fprintf('  Kc = 1.2*tau/(K*L) = 1.2*%.1f/(%.1f*%.1f) = %.2f\n', tau_val, K_val, L_val, Kc_zn);
fprintf('  Ti = 2L = 2*%.1f = %.1f seconds\n', L_val, Ti_zn);
fprintf('  Td = 0.5L = 0.5*%.1f = %.1f seconds\n', L_val, Td_zn);

% IMC tuning (more conservative)
lambda = max(L_val, 0.1*tau_val);  % Closed-loop time constant
Kc_imc = tau_val / (K_val * (lambda + L_val));
Ti_imc = tau_val;

fprintf('\nIMC-PID Tuning (lambda = %.1f):\n', lambda);
fprintf('  Kc = tau/(K*(lambda+L)) = %.1f/(%.1f*%.1f) = %.2f\n', tau_val, K_val, lambda + L_val, Kc_imc);
fprintf('  Ti = tau = %.1f seconds\n', Ti_imc);
fprintf('  Td = 0 seconds (PI control recommended)\n');

%% Method 9: Model Identification from Step Response
fprintf('\nMethod 9: FOPDT Model Identification\n');
fprintf('-----------------------------------\n');

fprintf('Parameter Estimation from Step Test Data:\n');
fprintf('1. Apply step input and record response\n');
fprintf('2. Identify dead time L (time to first response)\n');
fprintf('3. Measure final steady-state value for gain K\n');
fprintf('4. Find time constant tau from 63.2 percent point\n\n');

% Graphical Method
fprintf('Graphical Method:\n');
fprintf('  L = time when response starts\n');
fprintf('  K = final value divided by step magnitude\n');
fprintf('  tau = time to reach 63.2 percent minus L\n');
fprintf('  Alternatively: tau from tangent line method\n\n');

fprintf('Two-Point Method:\n');
fprintf('  Measure y1 at t1 = L + tau1\n');
fprintf('  Measure y2 at t2 = L + tau2\n');
fprintf('  Solve: tau = (t2-t1)/ln((K-y1)/(K-y2))\n\n');

fprintf('Model Validation Metrics:\n');
fprintf('• R-squared correlation coefficient > 0.95\n');
fprintf('• Mean absolute error < 5%% of range\n');
fprintf('• Residuals should be random\n');
fprintf('• Cross-validation with different data\n');

%% Summary and Educational Notes
fprintf('\nSUMMARY - FOPDT Analysis Complete\n');
fprintf('================================\n');

fprintf('Key Learning Points:\n');
fprintf('1. FOPDT is fundamental model in process control\n');
fprintf('2. Dead time creates control challenges\n');
fprintf('3. L/tau ratio determines control difficulty\n');
fprintf('4. Simple structure enables analytical solutions\n');
fprintf('5. Widely used for system identification\n\n');

fprintf('Mathematical Insights:\n');
fprintf('  Step response: y(t) = K(1-exp(-(t-L)/tau))*u(t-L)\n');
fprintf('  Time constant tau: time to reach 63.2 percent after delay\n');
fprintf('  Settling time approximately L + 5*tau for 99 percent response\n');
fprintf('  Dead time shifts entire response by L\n');
fprintf('  No overshoot (first-order system)\n\n');

fprintf('Control Engineering Applications:\n');
fprintf('  System identification and modeling\n');
fprintf('  Controller design and tuning\n');
fprintf('  Performance assessment\n');
fprintf('  Process optimization\n');
fprintf('  Predictive control model\n\n');

fprintf('Analysis completed successfully!\n');
fprintf('Use this framework for FOPDT analysis in your courses.\n');