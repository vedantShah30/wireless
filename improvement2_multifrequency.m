%% IMPROVEMENT 2: Multi-Frequency Band Analysis (Sub-6GHz to mmWave)
%
% Extension of Figure 2 from:
% Ozdogan, Bjornson, Larsson, "Intelligent Reflecting Surfaces: Physics,
% Propagation, and Pathloss Modeling," IEEE WCL, 2020.
%
% NEW CONTRIBUTION:
%   The original paper uses only 3 GHz. This script sweeps across all major
%   5G/6G candidate bands and shows how frequency dramatically changes the
%   IRS behavior for the SAME physical surface size.
%
%   Key insight: At higher frequencies, a fixed physical surface becomes
%   electrically LARGER (more wavelengths fit), giving a much narrower beam
%   and much higher gain — but also stricter far-field requirements.

clear; close all; clc;

%% ============================================================
%  SYSTEM PARAMETERS
%% ============================================================
c           = 3e8;
THETA_I_DEG = 30;
theta_i     = deg2rad(THETA_I_DEG);

% Frequency bands to compare
freq_list   = [0.7e9, 3.5e9, 10e9, 28e9, 60e9];  % Hz
freq_labels = {'0.7 GHz (Sub-1)', '3.5 GHz (5G NR)', ...
               '10 GHz (X-band)', '28 GHz (mmWave)', '60 GHz (mmWave)'};
freq_short  = {'0.7GHz','3.5GHz','10GHz','28GHz','60GHz'};
N_freq      = length(freq_list);

% Observation angles
theta_s_deg = 0:0.01:90;
theta_s_rad = deg2rad(theta_s_deg);
N_angles    = length(theta_s_rad);

% Fixed PHYSICAL surface size: 0.5m x 0.5m
A_phys = 0.5;   % meters
B_phys = 0.5;   % meters

%% ============================================================
%  PART A: Fixed physical size, varying frequency
%  Shows that higher frequency → narrower beam + higher gain
%% ============================================================
fprintf('=== PART A: Fixed Physical Size (%.1fm x %.1fm) ===\n', A_phys, B_phys);

S_freq    = zeros(N_angles, N_freq);
BW_3dB    = zeros(1, N_freq);
peak_gain = zeros(1, N_freq);
lambda_v  = c ./ freq_list;
k0_v      = 2*pi ./ lambda_v;

for fi = 1:N_freq
    lam = lambda_v(fi);
    k0  = k0_v(fi);

    y       = ((k0 * B_phys) / 2) .* (sin(theta_s_rad) - sin(theta_i));
    sinc_sq = ones(1, N_angles);
    nz      = (y ~= 0);
    sinc_sq(nz) = (sin(y(nz)) ./ y(nz)).^2;

    % Eq. 4
    S_freq(:,fi) = ((A_phys * B_phys)^2 / lam^2) * cos(theta_i)^2 .* sinc_sq';

    peak_gain(fi) = max(S_freq(:,fi));

    % -3dB beamwidth
    S_norm = S_freq(:,fi) / peak_gain(fi);
    above  = theta_s_deg(S_norm' >= 0.5);
    if length(above) >= 2
        BW_3dB(fi) = above(end) - above(1);
    end
end

% Normalize for beam shape comparison
S_freq_norm_dB = zeros(size(S_freq));
for fi = 1:N_freq
    s_db = 10*log10(S_freq(:,fi));
    S_freq_norm_dB(:,fi) = s_db - max(s_db);
end

% --- Plot Part A: Beam patterns ---
figure('Position',[50 520 800 460]);
hold on; box on; grid on;
styles = {'k-','b--','r-.','m:','c-'};
lw     = [2 2 2 2.5 2];
for fi = 1:N_freq
    plot(theta_s_deg, S_freq_norm_dB(:,fi), styles{fi}, 'LineWidth', lw(fi));
end
xline(THETA_I_DEG,'g--','LineWidth',1.5,...
    'Label',sprintf('\\theta_i=%d°',THETA_I_DEG),...
    'LabelVerticalAlignment','bottom','FontSize',12);
xlabel('Observation angle $\theta_s$ [degrees]','Interpreter','latex','FontSize',13);
ylabel('Normalized $S(r,\theta_s)$ [dB]','Interpreter','latex','FontSize',13);
title({'Improvement 2A: Scattering Pattern vs Frequency';...
       sprintf('Fixed physical IRS size: %.1fm $\\times$ %.1fm',A_phys,B_phys)},...
       'Interpreter','latex','FontSize',12);
legend(freq_labels,'Location','NorthEast','FontSize',11);
ylim([-60 5]); xlim([0 90]);
set(gca,'FontSize',13);

%% ============================================================
%  PART B: Summary bars — peak gain and beamwidth per band
%% ============================================================
peak_gain_dB = 10*log10(peak_gain);

figure('Position',[50 30 900 400]);

subplot(1,2,1);
bar(1:N_freq, peak_gain_dB, 'FaceColor',[0.2 0.5 0.8]);
set(gca,'XTickLabel',freq_short,'FontSize',11);
xlabel('Frequency Band','FontSize',12);
ylabel('Peak Gain [dB]','FontSize',12);
title('Peak Scattering Gain vs Frequency','FontSize',12);
grid on;
for fi = 1:N_freq
    text(fi, peak_gain_dB(fi)+1, sprintf('%.0fdB',peak_gain_dB(fi)),...
        'HorizontalAlignment','center','FontSize',10);
end

subplot(1,2,2);
bar(1:N_freq, BW_3dB, 'FaceColor',[0.8 0.3 0.2]);
set(gca,'XTickLabel',freq_short,'FontSize',11);
xlabel('Frequency Band','FontSize',12);
ylabel('$-3\,$dB Beamwidth [degrees]','Interpreter','latex','FontSize',12);
title('Beamwidth vs Frequency','FontSize',12);
grid on;
for fi = 1:N_freq
    text(fi, BW_3dB(fi)+0.3, sprintf('%.1f°',BW_3dB(fi)),...
        'HorizontalAlignment','center','FontSize',10);
end
sgtitle({'Improvement 2B: IRS Performance vs Frequency';...
         sprintf('Fixed %.1fm × %.1fm panel',A_phys,B_phys)},...
         'FontSize',13,'Interpreter','none');

%% ============================================================
%  PART C: Electrically-equivalent comparison
%  Fix surface size = 1λ x 1λ (always 1 wavelength) per band
%  Removes wavelength scaling — compares same electrical size
%% ============================================================
fprintf('\n=== PART C: Fixed Electrical Size (a=b=1λ) per Band ===\n');

S_elec    = zeros(N_angles, N_freq);
for fi = 1:N_freq
    lam = lambda_v(fi);
    k0  = k0_v(fi);
    a_e = 1 * lam;
    b_e = 1 * lam;

    y       = ((k0 * b_e) / 2) .* (sin(theta_s_rad) - sin(theta_i));
    sinc_sq = ones(1, N_angles);
    nz      = (y ~= 0);
    sinc_sq(nz) = (sin(y(nz)) ./ y(nz)).^2;

    S_elec(:,fi) = ((a_e * b_e)^2 / lam^2) * cos(theta_i)^2 .* sinc_sq';
end

S_elec_norm_dB = zeros(size(S_elec));
for fi = 1:N_freq
    s_db = 10*log10(S_elec(:,fi));
    S_elec_norm_dB(:,fi) = s_db - max(s_db);
end

figure('Position',[870 30 750 460]);
hold on; box on; grid on;
for fi = 1:N_freq
    plot(theta_s_deg, S_elec_norm_dB(:,fi), styles{fi}, 'LineWidth', lw(fi));
end
xline(THETA_I_DEG,'g--','LineWidth',1.5,...
    'Label',sprintf('\\theta_i=%d°',THETA_I_DEG),...
    'LabelVerticalAlignment','bottom','FontSize',12);
xlabel('Observation angle $\theta_s$ [degrees]','Interpreter','latex','FontSize',13);
ylabel('Normalized $S(r,\theta_s)$ [dB]','Interpreter','latex','FontSize',13);
title({'Improvement 2C: Fixed Electrical Size ($a=b=\lambda$)';...
       'All frequencies → identical pattern (confirms frequency-independent scaling)'},...
       'Interpreter','latex','FontSize',12);
legend(freq_labels,'Location','NorthEast','FontSize',11);
ylim([-60 5]); xlim([0 90]);
set(gca,'FontSize',12);

%% ============================================================
%  PART D: Far-field distance (Rayleigh distance) per band
%  Critical for deployment planning
%% ============================================================
fprintf('\n=== PART D: Far-Field (Rayleigh) Distance ===\n');
fprintf('%-15s %-12s %-12s %-18s %-15s\n',...
    'Frequency','Lambda(m)','Size(lambda)','Phys. Size(m)','Rayleigh d(m)');
fprintf('%s\n',repmat('-',1,72));

for fi = 1:N_freq
    lam     = lambda_v(fi);
    D_phys  = max(A_phys, B_phys);
    D_lam   = D_phys / lam;
    d_rayleigh = 2 * D_phys^2 / lam;
    fprintf('%-15s %-12.4f %-12.1f %-18.2f %-15.1f\n',...
        freq_labels{fi}, lam, D_lam, D_phys, d_rayleigh);
end

fprintf('\n--- Key Findings ---\n');
fprintf('1. At 60GHz, same 0.5m panel is 100λ wide → gain is ~40dB higher than at 0.7GHz\n');
fprintf('2. At 60GHz, beamwidth shrinks to <1° → precise alignment critical\n');
fprintf('3. For a=b=λ (electrical), ALL frequencies give the same normalized pattern.\n');
fprintf('4. Far-field distance grows quadratically with freq for fixed physical size.\n');
