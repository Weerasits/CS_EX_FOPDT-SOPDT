%% SOPDT (Second Order Plus Dead Time) Step Response Analysis
% Professor-level example for instrumentation and control
% System: G(s) = K*exp(-L*s)/(tau^2*s^2 + 2*zeta*tau*s + 1) - SOPDT Model
% Author: Control Systems Analysis - Advanced Process Control
% Date: 2025

clear all; close all; clc;

%% Define symbolic variables
syms s t K L tau zeta real positive

% Display header
fprintf('=== SOPDT (Second Order Plus Dead Time) Step Response Analysis ===\n\n');

%% Method 1: General Symbolic Transfer Function Analysis
fprintf('Method 1: General Symbolic Analysis of SOPDT\n');
fprintf('--------------------------------------------\n');

% Define the SOPDT transfer function
% G(s) = K*exp(-L*s)/(tau^2*s^2 + 2*zeta*tau*s + 1)
G_sym = K * exp(-L*s) / (tau^2*s^2 + 2*zeta*tau*s + 1);

fprintf('SOPDT Transfer Function: G(s) = %s\n', char(G_sym));
fprintf('Standard form: G(s) = K*exp(-Ls)/(tau^2*s^2 + 2*zeta*tau*s + 1)\n');
fprintf('Where:\n');
fprintf('  K = Process gain (steady-state gain)\n');
fprintf('  L = Dead time (transport delay) [time units]\n');
fprintf('  tau = Time constant [time units]\n');
fprintf('  zeta = Damping ratio (dimensionless)\n');
fprintf('  Typical range: L/tau ratio from 0.1 to 1.5 for most processes\n\n');

% Alternative factored form
fprintf('Factored form: G(s) = K*exp(-Ls)/((tau1*s + 1)(tau2*s + 1))\n');
fprintf('Where tau1 and tau2 are the individual time constants\n');
fprintf('Relationship: tau1 + tau2 = 2*zeta*tau, tau1*tau2 = tau^2\n\n');

% Step input in Laplace domain: 1/s
Y_s = G_sym * (1/s);
fprintf('Output for unit step: Y(s) = G(s) * (1/s) = %s\n', char(Y_s));

% Time domain interpretation
fprintf('\nTime domain behavior depends on damping:\n');
fprintf('• For t < L: y(t) = 0 (dead time period)\n');
fprintf('• For t ≥ L: y(t) depends on zeta value\n');
fprintf('  - zeta > 1: Overdamped (no overshoot)\n');
fprintf('  - zeta = 1: Critically damped (no overshoot, fastest response)\n');
fprintf('  - zeta < 1: Underdamped (overshoot and oscillations)\n');
fprintf('• Final value: y(infinity) = K\n\n');

%% Method 2: Specific Numerical Example - Underdamped Case
fprintf('Method 2: Specific Numerical Example - Underdamped SOPDT\n');
fprintf('--------------------------------------------------------\n');

% Define typical underdamped process parameters
K_val = 3.2;     % Process gain
L_val = 0.8;     % Dead time (seconds)
tau_val = 4.5;   % Time constant (seconds)
zeta_val = 0.6;  % Damping ratio (underdamped)

fprintf('Underdamped Process Control Example:\n');
fprintf('G(s) = %.1f * exp(-%.1fs) / (%.1f^2*s^2 + %.2f*%.1f*s + 1)\n', ...
        K_val, L_val, tau_val, 2*zeta_val, tau_val);
fprintf('Parameters:\n');
fprintf('  Process gain K = %.1f\n', K_val);
fprintf('  Dead time L = %.1f seconds\n', L_val);
fprintf('  Time constant tau = %.1f seconds\n', tau_val);
fprintf('  Damping ratio zeta = %.1f (underdamped)\n', zeta_val);
fprintf('  L/tau ratio = %.3f (moderate delay)\n', L_val/tau_val);

% Calculate derived parameters
omega_n = 1/tau_val;  % Natural frequency
omega_d = omega_n * sqrt(1 - zeta_val^2);  % Damped frequency
sigma = zeta_val * omega_n;  % Real part of poles

fprintf('\nDerived parameters:\n');
fprintf('  Natural frequency omega_n = 1/tau = %.3f rad/s\n', omega_n);
fprintf('  Damped frequency omega_d = omega_n*sqrt(1-zeta^2) = %.3f rad/s\n', omega_d);
fprintf('  Settling frequency sigma = zeta*omega_n = %.3f rad/s\n', sigma);
fprintf('  Oscillation period T_d = 2*pi/omega_d = %.2f seconds\n', 2*pi/omega_d);

% Poles calculation
fprintf('\nPole locations:\n');
s1 = -sigma + 1j*omega_d;
s2 = -sigma - 1j*omega_d;
fprintf('  s1,s2 = %.3f ± j%.3f (complex conjugate pair)\n', -sigma, omega_d);

%% Method 3: Time Domain Analysis
fprintf('\nMethod 3: Time Domain Analysis\n');
fprintf('------------------------------\n');

% Time vector for analysis
t_vec = 0:0.1:60;  % Extended time range for oscillatory response (60 seconds)

% Calculate step response for underdamped case
y_values = zeros(size(t_vec));
for i = 1:length(t_vec)
    if t_vec(i) >= L_val
        t_eff = t_vec(i) - L_val;  % Effective time after delay
        if zeta_val < 1  % Underdamped
            y_values(i) = K_val * (1 - exp(-sigma*t_eff) * ...
                         (cos(omega_d*t_eff) + (sigma/omega_d)*sin(omega_d*t_eff)));
        elseif zeta_val == 1  % Critically damped
            y_values(i) = K_val * (1 - exp(-omega_n*t_eff) * (1 + omega_n*t_eff));
        else  % Overdamped
            tau1 = tau_val * (zeta_val + sqrt(zeta_val^2 - 1));
            tau2 = tau_val * (zeta_val - sqrt(zeta_val^2 - 1));
            y_values(i) = K_val * (1 - (tau1*exp(-t_eff/tau2) - tau2*exp(-t_eff/tau1))/(tau1-tau2));
        end
    else
        y_values(i) = 0;  % Dead time period
    end
end

% Key time points analysis
fprintf('Key Time Points Analysis:\n');
fprintf('Dead time period: 0 ≤ t < %.1f seconds\n', L_val);
fprintf('Response start: t = %.1f seconds\n', L_val);

% Find peak overshoot (for underdamped case)
if zeta_val < 1
    [max_val, max_idx] = max(y_values);
    peak_time = t_vec(max_idx);
    overshoot_percent = ((max_val - K_val) / K_val) * 100;
    
    theoretical_peak_time = L_val + pi/omega_d;
    theoretical_overshoot = exp(-pi*zeta_val/sqrt(1-zeta_val^2)) * 100;
    
    fprintf('Peak overshoot: %.2f percent at t = %.2f seconds\n', overshoot_percent, peak_time);
    fprintf('Theoretical overshoot: %.2f percent at t = %.2f seconds\n', ...
            theoretical_overshoot, theoretical_peak_time);
end

% 2% settling time
settling_time_2 = L_val + 4/(zeta_val*omega_n);  % Approximation for underdamped
fprintf('2 percent settling time (approx): ts = L + 4/(zeta*omega_n) = %.2f seconds\n', settling_time_2);

% Rise time (approximate for underdamped)
if zeta_val < 1
    rise_time = (1.76*zeta_val^3 - 0.417*zeta_val^2 + 1.039*zeta_val + 1) / omega_n;
    fprintf('Rise time (10-90 percent): tr ≈ %.2f seconds (after delay)\n', rise_time);
end

fprintf('Final value: y(infinity) = K = %.1f\n', K_val);

%% Method 4: System Characteristics Analysis
fprintf('\nMethod 4: SOPDT System Characteristics\n');
fprintf('--------------------------------------\n');

% Poles and zeros analysis
fprintf('Poles and Zeros:\n');
fprintf('  Poles: s = %.3f ± j%.3f (complex conjugate pair in LHP)\n', -sigma, omega_d);
fprintf('  Zeros: None (except at infinity due to delay)\n');
fprintf('  Dead time: Pure delay element exp(-Ls)\n\n');

% Stability analysis
fprintf('Stability Analysis:\n');
fprintf('  Both poles in LHP → Stable system\n');
fprintf('  Dead time adds phase lag but does not affect stability\n');
fprintf('  BIBO stable for any finite L and positive tau, zeta\n\n');

% DC gain analysis
dc_gain = K_val;
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
fprintf('  Damping ratio: zeta = %.1f', zeta_val);

if zeta_val < 0.4
    fprintf(' (highly underdamped - significant overshoot)\n');
elseif zeta_val < 0.7
    fprintf(' (underdamped - moderate overshoot)\n');
elseif zeta_val < 1.0
    fprintf(' (lightly underdamped - small overshoot)\n');
elseif zeta_val == 1.0
    fprintf(' (critically damped - optimal response)\n');
else
    fprintf(' (overdamped - sluggish response)\n');
end

fprintf('  L/tau ratio: %.3f', L_val/tau_val);
control_difficulty = L_val / tau_val;
if control_difficulty < 0.1
    fprintf(' (easy to control)\n');
elseif control_difficulty < 0.5
    fprintf(' (moderate control difficulty)\n');
elseif control_difficulty < 1.0
    fprintf(' (challenging to control)\n');
else
    fprintf(' (very difficult to control)\n');
end

%% Method 5: Performance Metrics
fprintf('\nMethod 5: SOPDT Performance Metrics\n');
fprintf('-----------------------------------\n');

% Overshoot analysis (for underdamped systems)
if zeta_val < 1
    Mp = exp(-pi*zeta_val/sqrt(1-zeta_val^2)) * 100;
    tp = L_val + pi/omega_d;
    
    fprintf('Overshoot Analysis (Underdamped):\n');
    fprintf('  Maximum overshoot: Mp = %.2f percent\n', Mp);
    fprintf('  Peak time: tp = L + pi/omega_d = %.2f seconds\n', tp);
    fprintf('  Number of oscillations in first 4*tau: ~%.1f\n', 4*tau_val*omega_d/(2*pi));
else
    fprintf('Overshoot Analysis:\n');
    fprintf('  Maximum overshoot: 0 percent (overdamped/critically damped)\n');
    fprintf('  No oscillations in response\n');
end

% Settling time analysis
ts_2_exact = L_val + 4/(zeta_val*omega_n);  % 2% settling time
ts_5_exact = L_val + 3/(zeta_val*omega_n);  % 5% settling time

fprintf('\nSettling Time Analysis:\n');
fprintf('  2 percent settling time: ts = L + 4/(zeta*omega_n) = %.2f seconds\n', ts_2_exact);
fprintf('  5 percent settling time: ts = L + 3/(zeta*omega_n) = %.2f seconds\n', ts_5_exact);

% Rise time (more accurate for second-order systems)
if zeta_val < 1
    % Empirical formula for underdamped second-order systems
    tr_10_90 = (1.8 - 0.8*zeta_val) / omega_n;
    fprintf('  Rise time (10-90 percent): tr = %.2f seconds (after delay)\n', tr_10_90);
end

%% Method 6: Frequency Domain Characteristics
fprintf('\nMethod 6: Frequency Domain Analysis\n');
fprintf('-----------------------------------\n');

% Frequency response characteristics
fprintf('Frequency Response:\n');
fprintf('  Natural frequency: omega_n = 1/tau = %.3f rad/s = %.3f Hz\n', omega_n, omega_n/(2*pi));
fprintf('  Damped frequency: omega_d = %.3f rad/s = %.3f Hz\n', omega_d, omega_d/(2*pi));

% Resonant frequency (for underdamped systems)
if zeta_val < 0.707
    omega_r = omega_n * sqrt(1 - 2*zeta_val^2);
    Mr = K_val / (2*zeta_val*sqrt(1-zeta_val^2));
    fprintf('  Resonant frequency: omega_r = %.3f rad/s\n', omega_r);
    fprintf('  Resonant peak: Mr = %.2f dB\n', 20*log10(Mr));
else
    fprintf('  No resonance peak (zeta > 0.707)\n');
    fprintf('  Monotonic magnitude response\n');
end

% Bandwidth (approximate)
bandwidth = omega_n * sqrt(1 - 2*zeta_val^2 + sqrt(4*zeta_val^4 - 4*zeta_val^2 + 2));
fprintf('  Bandwidth (approximate): BW = %.3f rad/s\n', bandwidth);

%% Method 7: Comprehensive Graphical Analysis
fprintf('\nMethod 7: Comprehensive Graphical Analysis\n');
fprintf('-----------------------------------------\n');

% Create comprehensive plot
figure('Position', [100, 100, 1400, 1000]);

% Subplot 1: Step response with annotations
subplot(2,3,1);
plot(t_vec, y_values, 'b-', 'LineWidth', 2.5);
hold on;

% Add key points
plot(L_val, 0, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Response start');

if zeta_val < 1 && exist('max_val', 'var')
    plot(peak_time, max_val, 'rs', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Peak overshoot');
    yline(max_val, 'm:', 'LineWidth', 1, 'Alpha', 0.7, 'Label', sprintf('Peak = %.2f', max_val));
end

% Add reference lines
yline(K_val, 'r--', 'LineWidth', 1.5, 'Label', sprintf('Final Value = %.1f', K_val));
yline(K_val*1.02, 'g:', 'LineWidth', 1, 'Alpha', 0.7, 'Label', '+2% band');
yline(K_val*0.98, 'g:', 'LineWidth', 1, 'Alpha', 0.7, 'Label', '-2% band');
xline(L_val, 'r:', 'LineWidth', 1, 'Alpha', 0.7, 'Label', sprintf('L = %.1fs', L_val));

if zeta_val < 1
    xline(settling_time_2, 'g--', 'LineWidth', 1, 'Alpha', 0.7, 'Label', sprintf('ts = %.1fs', settling_time_2));
end

% Shade dead time region
fill([0, L_val, L_val, 0], [0, 0, K_val*1.3, K_val*1.3], 'red', ...
     'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', 'Dead Time');

grid on;
xlabel('Time (seconds)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('SOPDT Step Response (Underdamped)', 'FontSize', 14, 'FontWeight', 'bold');

% Adjust legend based on damping
if zeta_val < 1
    legend('Step Response', 'Response Start', 'Peak Overshoot', 'Dead Time Region', ...
           'Location', 'best', 'FontSize', 9);
else
    legend('Step Response', 'Response Start', 'Dead Time Region', ...
           'Location', 'best', 'FontSize', 9);
end

xlim([0, 60]);
ylim([0, K_val*1.3]);

% Add text annotations
text(L_val/2, K_val*0.5, sprintf('Dead Time\nL = %.1fs', L_val), ...
     'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', 'red', 'FontWeight', 'bold');

if zeta_val < 1
    text(L_val + 2, K_val*1.15, sprintf('zeta = %.1f\n(Underdamped)', zeta_val), ...
         'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', 'blue', 'FontWeight', 'bold');
end

% Subplot 2: Pole-zero map
subplot(2,3,2);
plot(real(s1), imag(s1), 'rx', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Complex Poles');
hold on;
plot(real(s2), imag(s2), 'rx', 'MarkerSize', 15, 'LineWidth', 3);

% Draw axes and stability boundary
line([-0.5, 0.1], [0, 0], 'Color', 'k', 'LineWidth', 0.5);  % Real axis
line([0, 0], [-0.5, 0.5], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '-.', 'DisplayName', 'jω-axis');

% Draw constant damping lines
zeta_line_x = linspace(-0.4, 0, 100);
zeta_line_y1 = -zeta_line_x * tan(acos(zeta_val));
zeta_line_y2 = -zeta_line_x * tan(-acos(zeta_val));
plot(zeta_line_x, zeta_line_y1, 'g--', 'LineWidth', 1, 'DisplayName', sprintf('zeta = %.1f lines', zeta_val));
plot(zeta_line_x, zeta_line_y2, 'g--', 'LineWidth', 1);

% Mark origin
plot(0, 0, 'ko', 'MarkerSize', 4);

grid on;
xlabel('Real Part (σ)', 'FontSize', 12);
ylabel('Imaginary Part (jω)', 'FontSize', 12);
title('Pole-Zero Map', 'FontSize', 14, 'FontWeight', 'bold');

% Add pole annotations
text(real(s1)-0.05, imag(s1)+0.05, sprintf('%.3f+j%.3f', real(s1), imag(s1)), ...
     'FontSize', 9, 'Color', 'red');
text(real(s2)-0.05, imag(s2)-0.08, sprintf('%.3f-j%.3f', real(s2), imag(s2)), ...
     'FontSize', 9, 'Color', 'red');

legend('Complex Poles', 'Stability Boundary', 'Damping Lines', 'Location', 'best', 'FontSize', 9);
xlim([-0.4, 0.1]);
ylim([-0.4, 0.4]);
axis equal;

% Subplot 3: Response components breakdown
subplot(2,3,3);
t_response = t_vec(t_vec >= L_val) - L_val;  % Time after delay starts
y_steady = K_val * ones(size(t_response));

if zeta_val < 1
    y_envelope = K_val * exp(-sigma*t_response);
    y_oscillatory = -y_envelope .* cos(omega_d*t_response + atan(sigma/omega_d));
    
    plot(t_response + L_val, y_steady, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Steady State (K)');
    hold on;
    plot(t_response + L_val, y_envelope + K_val, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Upper Envelope');
    plot(t_response + L_val, -y_envelope + K_val, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Lower Envelope');
    plot(t_response + L_val, y_oscillatory + K_val, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Oscillatory Component');
    plot(t_response + L_val, y_values(t_vec >= L_val), 'b-', 'LineWidth', 2, 'DisplayName', 'Total Response');
end

% Show dead time region
t_dead = t_vec(t_vec < L_val);
y_dead = zeros(size(t_dead));
plot(t_dead, y_dead, 'k-', 'LineWidth', 2, 'DisplayName', 'Dead Time');

grid on;
xlabel('Time (seconds)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('SOPDT Response Components', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
xlim([0, 60]);

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

% Determine damping description
if zeta_val < 0.4
    damping_str = 'Highly Underdamped';
elseif zeta_val < 0.7
    damping_str = 'Underdamped';
elseif zeta_val < 1.0
    damping_str = 'Lightly Underdamped';
elseif zeta_val == 1.0
    damping_str = 'Critically Damped';
else
    damping_str = 'Overdamped';
end

info_text = {
    'SOPDT System Information:';
    '';
    sprintf('Transfer Function: G(s) = %.1f*exp(-%.1fs)/(%.1f^2*s^2+%.2f*s+1)', ...
            K_val, L_val, tau_val, 2*zeta_val*tau_val);
    '';
    'Parameters:';
    sprintf('  Process gain: K = %.1f', K_val);
    sprintf('  Dead time: L = %.1f seconds', L_val);
    sprintf('  Time constant: tau = %.1f seconds', tau_val);
    sprintf('  Damping ratio: zeta = %.1f', zeta_val);
    sprintf('  L/tau ratio: %.3f', L_val/tau_val);
    '';
    'Pole Characteristics:';
    sprintf('  Poles: s = %.3f ± j%.3f', -sigma, omega_d);
    sprintf('  Natural freq: %.3f rad/s', omega_n);
    sprintf('  Damped freq: %.3f rad/s', omega_d);
    '';
    'Performance (Underdamped):';
    sprintf('  Overshoot: %.1f percent', Mp);
    sprintf('  Peak time: %.2f s', tp-L_val);
    sprintf('  Settling time: %.2f s', ts_2_exact);
    '';
    'Classification:';
    sprintf('  Damping: %s', damping_str);
    sprintf('  Control: %s', difficulty_str);
};
text(0.05, 0.95, info_text, 'FontSize', 9, 'VerticalAlignment', 'top', ...
     'FontName', 'FixedWidth');

% Subplot 5: Frequency response magnitude
subplot(2,3,5);
omega = logspace(-2, 1, 1000);
H_mag = K_val ./ sqrt((1 - (omega*tau_val).^2).^2 + (2*zeta_val*omega*tau_val).^2);

semilogx(omega, 20*log10(H_mag), 'b-', 'LineWidth', 2);
hold on;
semilogx(omega_n, 20*log10(K_val), 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Natural freq');

if zeta_val < 0.707 && exist('omega_r', 'var')
    semilogx(omega_r, 20*log10(Mr), 'gs', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Resonant peak');
    yline(20*log10(Mr), 'g--', 'LineWidth', 1, 'Label', sprintf('Mr = %.1f dB', 20*log10(Mr)));
end

grid on;
xlabel('Frequency (rad/s)', 'FontSize', 12);
ylabel('Magnitude (dB)', 'FontSize', 12);
title('Frequency Response (without delay)', 'FontSize', 14, 'FontWeight', 'bold');
xline(omega_n, 'r:', 'LineWidth', 1, 'Label', sprintf('omega_n = %.3f', omega_n));
legend('Location', 'best', 'FontSize', 9);

% Subplot 6: Phase response
subplot(2,3,6);
H_phase = -atan2(2*zeta_val*omega*tau_val, 1 - (omega*tau_val).^2) * 180/pi;
H_phase_delay = H_phase - omega * L_val * 180/pi;

semilogx(omega, H_phase, 'b-', 'LineWidth', 2, 'DisplayName', 'Without delay');
hold on;
semilogx(omega, H_phase_delay, 'r-', 'LineWidth', 2, 'DisplayName', 'With delay');
semilogx(omega_n, -90, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', '-90° point');

grid on;
xlabel('Frequency (rad/s)', 'FontSize', 12);
ylabel('Phase (degrees)', 'FontSize', 12);
title('Phase Response', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);

sgtitle('SOPDT (Second Order Plus Dead Time) - Complete Analysis', ...
        'FontSize', 16, 'FontWeight', 'bold');

%% Method 8: Process Control Applications
fprintf('Method 8: Process Control Applications\n');
fprintf('--------------------------------------\n');

fprintf('Common SOPDT Process Examples:\n');
fprintf('  Temperature control in multi-stage processes\n');
fprintf('  Pressure control in vessels with complex dynamics\n');
fprintf('  Composition control in distillation columns\n');
fprintf('  Level control in cascaded tanks\n');
fprintf('  Motor speed control systems\n');
fprintf('  pH control in neutralization processes\n\n');

fprintf('Typical Damping Ratios by Industry:\n');
fprintf('  Thermal processes: 0.3 - 0.8 (underdamped to lightly damped)\n');
fprintf('  Mechanical systems: 0.1 - 0.5 (highly to moderately underdamped)\n');
fprintf('  Chemical processes: 0.4 - 1.2 (underdamped to overdamped)\n');
fprintf('  Electrical systems: 0.2 - 0.9 (underdamped to nearly critical)\n\n');

fprintf('Control Design Implications:\n');
if control_difficulty < 0.2
    if zeta_val < 0.5
        fprintf('  PID control works well but tune carefully for overshoot\n');
        fprintf('  Consider derivative action to reduce overshoot\n');
        fprintf('  Fast setpoint tracking with some oscillations\n');
    else
        fprintf('  PI/PID control works excellently\n');
        fprintf('  Fast and stable response\n');
        fprintf('  Good disturbance rejection\n');
    end
elseif control_difficulty < 0.5
    fprintf('  PID control adequate with proper tuning\n');
    fprintf('  Balance between speed and stability\n');
    fprintf('  Consider feedforward for disturbances\n');
    if zeta_val < 0.4
        fprintf('  High overshoot potential - tune conservatively\n');
    end
elseif control_difficulty < 1.0
    fprintf('  PID requires very careful tuning\n');
    fprintf('  Significant performance limitations\n');
    fprintf('  Smith predictor beneficial for delay compensation\n');
    fprintf('  Feedforward control recommended\n');
    if zeta_val < 0.5
        fprintf('  Oscillatory tendencies - use conservative gains\n');
    end
else
    fprintf('  Standard PID challenging to tune\n');
    fprintf('  Smith predictor or IMC strongly recommended\n');
    fprintf('  Advanced control strategies needed\n');
    fprintf('  Model predictive control consideration\n');
end

% PID Tuning recommendations
fprintf('\nTuning Guidelines for PID Control:\n');

% Ziegler-Nichols equivalent for SOPDT (approximate)
if zeta_val < 1
    Kc_zn = 0.6 * tau_val / (K_val * L_val * (1 + 0.5*zeta_val));
    Ti_zn = 2 * L_val * (1 + zeta_val);
    Td_zn = 0.5 * L_val / (1 + 2*zeta_val);
    
    fprintf('Modified Ziegler-Nichols for SOPDT:\n');
    fprintf('  Kc = %.2f\n', Kc_zn);
    fprintf('  Ti = %.1f seconds\n', Ti_zn);
    fprintf('  Td = %.1f seconds\n', Td_zn);
else
    fprintf('Overdamped system - use FOPDT approximation methods\n');
end

% IMC tuning for SOPDT
lambda_imc = max(L_val, 0.2*tau_val);  % More conservative for second-order
Kc_imc = (2*zeta_val*tau_val) / (K_val * (lambda_imc + L_val));
Ti_imc = 2*zeta_val*tau_val;
Td_imc = tau_val / (2*zeta_val);

fprintf('\nIMC-PID Tuning for SOPDT (lambda = %.1f):\n', lambda_imc);
fprintf('  Kc = %.2f\n', Kc_imc);
fprintf('  Ti = %.1f seconds\n', Ti_imc);
fprintf('  Td = %.1f seconds\n', Td_imc);

%% Method 9: Comparison with Different Damping Ratios
fprintf('\nMethod 9: Damping Ratio Effect Analysis\n');
fprintf('---------------------------------------\n');

% Compare responses for different damping ratios
zeta_values = [0.3, 0.5, 0.707, 1.0, 1.5];
colors = ['r', 'g', 'b', 'm', 'c'];

figure('Position', [200, 200, 1200, 800]);

subplot(2,2,1);
hold on;
for i = 1:length(zeta_values)
    zeta_test = zeta_values(i);
    omega_n_test = 1/tau_val;
    
    y_test = zeros(size(t_vec));
    for j = 1:length(t_vec)
        if t_vec(j) >= L_val
            t_eff = t_vec(j) - L_val;
            if zeta_test < 1  % Underdamped
                omega_d_test = omega_n_test * sqrt(1 - zeta_test^2);
                sigma_test = zeta_test * omega_n_test;
                y_test(j) = K_val * (1 - exp(-sigma_test*t_eff) * ...
                           (cos(omega_d_test*t_eff) + (sigma_test/omega_d_test)*sin(omega_d_test*t_eff)));
            elseif zeta_test == 1  % Critically damped
                y_test(j) = K_val * (1 - exp(-omega_n_test*t_eff) * (1 + omega_n_test*t_eff));
            else  % Overdamped
                r1 = omega_n_test * (zeta_test + sqrt(zeta_test^2 - 1));
                r2 = omega_n_test * (zeta_test - sqrt(zeta_test^2 - 1));
                y_test(j) = K_val * (1 - (r1*exp(-r2*t_eff) - r2*exp(-r1*t_eff))/(r1-r2));
            end
        end
    end
    
    plot(t_vec, y_test, colors(i), 'LineWidth', 2, ...
         'DisplayName', sprintf('zeta = %.1f', zeta_test));
end

yline(K_val, 'k--', 'LineWidth', 1, 'Alpha', 0.5, 'Label', 'Final Value');
grid on;
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Effect of Damping Ratio on Step Response');
legend('Location', 'best');
xlim([0, 60]);

% Subplot: Overshoot vs Damping Ratio
subplot(2,2,2);
zeta_plot = 0.1:0.05:0.95;
overshoot_plot = exp(-pi*zeta_plot./sqrt(1-zeta_plot.^2)) * 100;

plot(zeta_plot, overshoot_plot, 'b-', 'LineWidth', 2);
hold on;
plot(zeta_val, Mp, 'ro', 'MarkerSize', 10, 'LineWidth', 2, ...
     'DisplayName', sprintf('Current system: zeta=%.1f, Mp=%.1f%%', zeta_val, Mp));

grid on;
xlabel('Damping Ratio (zeta)');
ylabel('Maximum Overshoot (%)');
title('Overshoot vs Damping Ratio');
legend('Location', 'best');

% Subplot: Settling Time vs Damping Ratio
subplot(2,2,3);
zeta_plot2 = 0.1:0.05:2.0;
omega_n_const = 1/tau_val;
ts_plot = 4 ./ (zeta_plot2 * omega_n_const);  % 2% settling time approximation

plot(zeta_plot2, ts_plot, 'g-', 'LineWidth', 2);
hold on;
plot(zeta_val, ts_2_exact-L_val, 'ro', 'MarkerSize', 10, 'LineWidth', 2, ...
     'DisplayName', sprintf('Current system: zeta=%.1f, ts=%.1fs', zeta_val, ts_2_exact-L_val));

grid on;
xlabel('Damping Ratio (zeta)');
ylabel('Settling Time (seconds)');
title('Settling Time vs Damping Ratio (without delay)');
legend('Location', 'best');

% Subplot: Performance criteria
subplot(2,2,4);
axis off;

performance_text = {
    'SOPDT Design Guidelines:';
    '';
    'Damping Ratio Selection:';
    '  zeta < 0.4: High overshoot, fast response';
    '  zeta = 0.4-0.7: Moderate overshoot, good speed';
    '  zeta = 0.707: Optimal compromise (slight overshoot)';
    '  zeta = 1.0: No overshoot, fastest without oscillation';
    '  zeta > 1.0: Sluggish, no overshoot';
    '';
    'Control Performance Trade-offs:';
    '  Low zeta: Fast but oscillatory';
    '  High zeta: Stable but slow';
    '  Optimal zeta: 0.6-0.8 for most applications';
    '';
    'Current System Assessment:';
    sprintf('  zeta = %.1f → %s', zeta_val, damping_str);
    sprintf('  Overshoot: %.1f%% (theory: %.1f%%)', overshoot_percent, Mp);
    sprintf('  Response classification: %s', damping_str);
    '';
    'Recommendations:';
    '  Consider derivative control for overshoot reduction';
    '  Use feedforward for disturbance rejection';
    '  Model predictive control for complex constraints';
};

text(0.05, 0.95, performance_text, 'FontSize', 10, 'VerticalAlignment', 'top', ...
     'FontName', 'FixedWidth');

sgtitle('SOPDT Damping Analysis and Design Guidelines', 'FontSize', 16, 'FontWeight', 'bold');

%% Summary and Educational Notes
fprintf('\nSUMMARY - SOPDT Analysis Complete\n');
fprintf('=================================\n');

fprintf('Key Learning Points:\n');
fprintf('1. SOPDT models complex processes with two energy storage elements\n');
fprintf('2. Damping ratio critically affects response characteristics\n');
fprintf('3. Dead time creates additional control challenges\n');
fprintf('4. Underdamped systems show overshoot and oscillations\n');
fprintf('5. Controller tuning must account for both delay and dynamics\n\n');

fprintf('Mathematical Insights:\n');
fprintf('  Step response: Complex function of zeta, omega_n, and L\n');
fprintf('  Overshoot: Mp = exp(-pi*zeta/sqrt(1-zeta^2)) * 100 percent\n');
fprintf('  Peak time: tp = L + pi/omega_d (for underdamped)\n');
fprintf('  Settling time: ts ≈ L + 4/(zeta*omega_n) for 2 percent\n');
fprintf('  Natural frequency: omega_n = 1/tau rad/s\n');
fprintf('  Damped frequency: omega_d = omega_n*sqrt(1-zeta^2)\n\n');

fprintf('Control Engineering Applications:\n');
fprintf('  Advanced system identification and modeling\n');
fprintf('  Multi-loop and cascade control systems\n');
fprintf('  Model predictive control applications\n');
fprintf('  Process optimization with dynamic constraints\n');
fprintf('  Robust control design for uncertain systems\n\n');

fprintf('Process Industry Examples:\n');
fprintf('  Multi-stage temperature control (reactors, furnaces)\n');
fprintf('  Distillation column dynamics (composition control)\n');
fprintf('  Motor drives with mechanical coupling\n');
fprintf('  Pressure control in complex piping networks\n');
fprintf('  pH control with multiple reagent additions\n\n');

fprintf('Design Recommendations for Current System:\n');
fprintf('  Damping: %s (zeta = %.1f)\n', damping_str, zeta_val);
fprintf('  Control difficulty: %s (L/tau = %.3f)\n', difficulty_str, control_difficulty);

if zeta_val < 0.5
    fprintf('  → Expect significant overshoot (%.1f%%)\n', Mp);
    fprintf('  → Use conservative PID tuning\n');
    fprintf('  → Consider derivative action for damping\n');
elseif zeta_val < 0.9
    fprintf('  → Well-balanced response characteristics\n');
    fprintf('  → Standard PID tuning should work well\n');
    fprintf('  → Good compromise between speed and stability\n');
else
    fprintf('  → Conservative, stable response\n');
    fprintf('  → May be too slow for some applications\n');
    fprintf('  → Consider reducing time constant if possible\n');
end

fprintf('\nAnalysis completed successfully!\n');
fprintf('Use this framework for SOPDT analysis in advanced control courses.\n');
fprintf('Compare with FOPDT to understand the impact of additional dynamics.\n');