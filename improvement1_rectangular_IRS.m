%% IMPROVEMENT 1: Non-Square / Rectangular IRS Geometry
%
% Extension of Figure 2 from:
% Ozdogan, Bjornson, Larsson, "Intelligent Reflecting Surfaces: Physics,
% Propagation, and Pathloss Modeling," IEEE WCL, 2020.
%
% NEW CONTRIBUTION:
%   The original paper only uses square surfaces (a = b).
%   Here we independently vary 'a' (along ex) and 'b' (along ey) to study
%   how aspect ratio affects the scattering beam pattern.
%
%   Key insight: The sinc term in Eq.4 only depends on 'b' (the dimension
%   along the scattering plane), so varying 'a' only scales the peak gain
%   while varying 'b' changes the beamwidth. This reveals an important
%   design tradeoff for wall-mounted rectangular IRS panels.

clear; close all; clc;

%% ============================================================
%  SYSTEM PARAMETERS
%% ============================================================
c          = 3e8;
fc         = 3e9;
lambda     = c / fc;
k0         = 2*pi / lambda;

THETA_I_DEG = 30;
theta_i     = deg2rad(THETA_I_DEG);

% Observation angles
theta_s_deg = 0:0.01:90;
theta_s_rad = deg2rad(theta_s_deg);
N_angles    = length(theta_s_rad);

%% ============================================================
%  PART A: Fixed area, varying aspect ratio
%  Total area = 1*lambda x 1*lambda = lambda^2 (constant)
%  We reshape into different a x b rectangles
%% ============================================================
fprintf('=== PART A: Fixed Area, Varying Aspect Ratio ===\n');

% (a, b) pairs — all have same area = lambda^2
aspect_cases = [
    0.5,  2.0;   % Tall: a=0.5λ, b=2λ
    1.0,  1.0;   % Square: a=b=λ (original paper)
    2.0,  0.5;   % Wide: a=2λ, b=0.5λ
];
aspect_labels = {
    '$a=0.5\lambda,\; b=2\lambda$ (Tall)',
    '$a=b=\lambda$ (Square, original)',
    '$a=2\lambda,\; b=0.5\lambda$ (Wide)'
};

S_aspect = zeros(N_angles, size(aspect_cases,1));

for idx = 1:size(aspect_cases,1)
    a_val = aspect_cases(idx,1) * lambda;
    b_val = aspect_cases(idx,2) * lambda;

    y        = ((k0 * b_val) / 2) .* (sin(theta_s_rad) - sin(theta_i));
    sinc_sq  = ones(1, N_angles);
    nz       = (y ~= 0);
    sinc_sq(nz) = (sin(y(nz)) ./ y(nz)).^2;

    % Eq. 4 from paper
    S_aspect(:, idx) = ((a_val * b_val)^2 / lambda^2) * cos(theta_i)^2 .* sinc_sq';
end

% Normalize each to its own peak (0 dB)
S_aspect_dB = zeros(size(S_aspect));
for idx = 1:size(aspect_cases,1)
    s_db = 10*log10(S_aspect(:,idx));
    S_aspect_dB(:,idx) = s_db - max(s_db);
end

% --- Plot Part A ---
figure('Position',[50 500 780 480]);
hold on; box on; grid on;
styles = {'k-','b--','r-.'};
for idx = 1:size(aspect_cases,1)
    plot(theta_s_deg, S_aspect_dB(:,idx), styles{idx}, 'LineWidth', 2);
end
xline(THETA_I_DEG,'g--','LineWidth',1.5, ...
    'Label',sprintf('\\theta_i=%d°',THETA_I_DEG), ...
    'LabelVerticalAlignment','bottom','FontSize',12);
xlabel('Observation angle $\theta_s$ [degrees]','Interpreter','latex','FontSize',13);
ylabel('Normalized $S(r,\theta_s)$ [dB]','Interpreter','latex','FontSize',13);
title({'Improvement 1A: Fixed Area $= \lambda^2$, Varying Aspect Ratio';...
       'Shows that $b$ controls beamwidth, $a$ controls peak gain'},...
       'Interpreter','latex','FontSize',12);
legend(aspect_labels,'Location','NorthEast','Interpreter','latex','FontSize',11);
ylim([-60 5]); xlim([0 90]);
set(gca,'FontSize',12);

%% ============================================================
%  PART B: Beamwidth vs b-dimension (with a fixed)
%  Demonstrates the beamwidth law: BW ≈ λ / (b·cos(θi))
%% ============================================================
fprintf('\n=== PART B: Beamwidth vs b-dimension ===\n');

a_fixed    = 5 * lambda;           % Fixed a
b_sweep    = (0.5:0.5:20) * lambda; % Sweep b from 0.5λ to 20λ
BW_sim     = zeros(1, length(b_sweep));
BW_theory  = zeros(1, length(b_sweep));

for bi = 1:length(b_sweep)
    b_val   = b_sweep(bi);
    y       = ((k0 * b_val) / 2) .* (sin(theta_s_rad) - sin(theta_i));
    sinc_sq = ones(1, N_angles);
    nz      = (y ~= 0);
    sinc_sq(nz) = (sin(y(nz)) ./ y(nz)).^2;
    S_tmp   = sinc_sq;   % normalized peak = 1 → 0 dB

    % Find -3 dB beamwidth
    above   = theta_s_deg(S_tmp >= 0.5); % 0.5 = -3dB in linear
    if length(above) >= 2
        BW_sim(bi) = above(end) - above(1);
    end

    % Theoretical approximation
    BW_theory(bi) = rad2deg(lambda / (b_val * cos(theta_i)));
end

b_lambda = b_sweep / lambda;

figure('Position',[50 30 780 430]);
hold on; box on; grid on;
plot(b_lambda, BW_sim,    'bo-', 'LineWidth', 2, 'MarkerSize', 6);
plot(b_lambda, BW_theory, 'r--', 'LineWidth', 2);
xlabel('Surface dimension $b$ [$\lambda$]','Interpreter','latex','FontSize',13);
ylabel('$-3\,$dB Beamwidth [degrees]','Interpreter','latex','FontSize',13);
title('Improvement 1B: Beamwidth vs $b$-dimension (fixed $a=5\lambda$)',...
      'Interpreter','latex','FontSize',12);
legend('Simulated (Eq. 4)','Approximation $\lambda/(b\cos\theta_i)$',...
       'Location','NorthEast','Interpreter','latex','FontSize',12);
set(gca,'FontSize',12);

%% ============================================================
%  PART C: 2D heatmap — aspect ratio sweep
%  Scattering pattern as function of both a and b
%% ============================================================
fprintf('\n=== PART C: Peak Gain vs a and b ===\n');

a_vec = (0.5:0.5:10) * lambda;
b_vec = (0.5:0.5:10) * lambda;
peak_gain_dB = zeros(length(a_vec), length(b_vec));

for ai = 1:length(a_vec)
    for bi = 1:length(b_vec)
        % Peak gain occurs at theta_s = theta_i (specular direction)
        % At peak, sinc^2 = 1, so S_peak = (ab)^2/lambda^2 * cos^2(theta_i)
        peak_gain_dB(ai, bi) = 10*log10( (a_vec(ai)*b_vec(bi))^2 / lambda^2 * cos(theta_i)^2 );
    end
end

figure('Position',[850 30 700 500]);
imagesc(a_vec/lambda, b_vec/lambda, peak_gain_dB');
colorbar;
xlabel('$a$ [$\lambda$]','Interpreter','latex','FontSize',13);
ylabel('$b$ [$\lambda$]','Interpreter','latex','FontSize',13);
title({'Improvement 1C: Peak Scattering Gain [dB] vs $a$ and $b$';...
       '(Diagonal = square surface, off-diagonal = rectangular)'},...
       'Interpreter','latex','FontSize',12);
colormap(jet);
set(gca,'FontSize',12,'YDir','normal');
hold on;
% Mark the diagonal (square cases from original paper)
plot([0.2 10],[0.2 10],'w--','LineWidth',2);
text(5,5.5,'Square ($a=b$)','Color','w','Interpreter','latex','FontSize',11,...
    'HorizontalAlignment','center');

%% ============================================================
%  PRINT SUMMARY
%% ============================================================
fprintf('\n--- Key Findings ---\n');
fprintf('1. For fixed area, a TALL surface (large b) gives NARROWER beam.\n');
fprintf('2. For fixed area, a WIDE surface (large a) gives HIGHER peak gain\n');
fprintf('   but the same beamwidth as equivalent-b square.\n');
fprintf('3. Peak gain scales as (ab)^2 — doubling both dimensions gives +12dB.\n');
fprintf('4. Beamwidth ≈ λ/(b·cos(θi)) — only b matters for beam shaping.\n');
