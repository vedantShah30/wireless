%% IMPROVEMENT 6: End-to-End IRS Pathloss vs Distance
%
% Extension of Figure 5 from:
% Ozdogan, Bjornson, Larsson, "Intelligent Reflecting Surfaces: Physics,
% Propagation, and Pathloss Modeling," IEEE WCL, 2020.
%
% NEW CONTRIBUTION:
%   The paper derives the pathloss formula (Eq. 20) but only plots it
%   vs angle for a single geometry. Here we:
%   (A) Plot pathloss as a 3D surface vs both source distance di and
%       receiver distance dr — revealing the full spatial regime.
%   (B) Compare IRS-reflected path vs direct path to find the crossover.
%   (C) Show how IRS size affects the breakeven distance.
%   (D) Plot pathloss vs total path (di + dr) for balanced/unbalanced cases.
%
% Pathloss formula (Eq. 20 from paper):
%   PL = (4*pi*di*dr)^2 / (Gt * Gr * (ab)^2 * cos^2(theta_i) * cos^2(theta_r))
%
% Equivalently, received power ratio:
%   Pr/Pt = Gt*Gr*(ab)^2 * cos^2(θi)*cos^2(θr) / (4π)^2 / di^2 / dr^2

clear; close all; clc;

%% ============================================================
%  SYSTEM PARAMETERS
%% ============================================================
c           = 3e8;
fc          = 3e9;           % 3 GHz
lambda      = c / fc;
k0          = 2*pi / lambda;

THETA_I_DEG = 30;            % Angle of incidence
THETA_R_DEG = 30;            % Angle of reflection (specular = theta_i)
theta_i     = deg2rad(THETA_I_DEG);
theta_r     = deg2rad(THETA_R_DEG);

Gt          = 1;             % Transmit antenna gain (isotropic)
Gr          = 1;             % Receive antenna gain (isotropic)

% IRS sizes for comparison
size_labels = {'$a=b=\lambda$', '$a=b=5\lambda$', '$a=b=10\lambda$'};
size_factors= [1, 5, 10];

%% ============================================================
%  PART A: 3D Surface Plot — Pathloss vs di and dr
%  For a fixed IRS size (10λ x 10λ)
%% ============================================================
fprintf('=== PART A: 3D Pathloss Surface vs di and dr ===\n');

a_val = 10 * lambda;
b_val = 10 * lambda;

% Distance ranges
di_vec = logspace(0, 3, 80);  % 1m to 1000m
dr_vec = logspace(0, 3, 80);  % 1m to 1000m
[DI, DR] = meshgrid(di_vec, dr_vec);

% Pathloss (Eq. 20) — received power / transmit power
PL_3D = (Gt * Gr * (a_val*b_val)^2 * cos(theta_i)^2 * cos(theta_r)^2) ...
        ./ ((4*pi)^2 .* DI.^2 .* DR.^2);

PL_3D_dB = 10*log10(PL_3D);

figure('Position',[30 500 800 520]);
surf(log10(di_vec), log10(dr_vec), PL_3D_dB, 'EdgeColor','none');
colorbar;
xlabel('$\log_{10}(d_i)$ [m]','Interpreter','latex','FontSize',13);
ylabel('$\log_{10}(d_r)$ [m]','Interpreter','latex','FontSize',13);
zlabel('Pathloss [dB]','FontSize',13);
title({'Improvement 6A: End-to-End IRS Pathloss (Eq. 20)';...
       sprintf('$a=b=10\\lambda$, $\\theta_i=\\theta_r=%d°$',THETA_I_DEG)},...
       'Interpreter','latex','FontSize',12);
colormap(jet);
view([-40 30]);
set(gca,'FontSize',11,...
    'XTickLabel',{'1m','10m','100m','1km'},...
    'YTickLabel',{'1m','10m','100m','1km'});

%% ============================================================
%  PART B: IRS vs Direct Path — Crossover Distance
%  Direct path pathloss (free space):
%    PL_direct = (4*pi*d_direct/lambda)^2 / (Gt*Gr)
%
%  IRS helps when PL_IRS < PL_direct
%  i.e., when (ab)^2 * cos^2(θi)*cos^2(θr) / (di*dr)^2 > lambda^2/d_direct^2
%% ============================================================
fprintf('\n=== PART B: IRS vs Direct Path Comparison ===\n');

% Scenario: Source fixed, receiver moves away
% Source at distance di from IRS, receiver at distance dr
% Direct distance d_direct = di + dr (worst-case geometry, collinear)

di_fixed   = 50;    % Source is 50m from IRS (fixed)
dr_range   = logspace(0, 3, 500);  % Receiver moves 1m to 1000m from IRS
d_direct   = di_fixed + dr_range;  % Total source-to-receiver distance

% Free-space direct path
PL_direct  = (lambda ./ (4*pi*d_direct)).^2 * Gt * Gr;

figure('Position',[30 30 800 460]);
hold on; box on; grid on;

colors_b = {'b-','r--','k-.'};
for si = 1:length(size_factors)
    a_s  = size_factors(si) * lambda;
    b_s  = size_factors(si) * lambda;

    PL_IRS = (Gt * Gr * (a_s*b_s)^2 * cos(theta_i)^2 * cos(theta_r)^2) ...
             ./ ((4*pi)^2 * di_fixed^2 .* dr_range.^2);

    plot(dr_range, 10*log10(PL_IRS), colors_b{si}, 'LineWidth', 2);
end

% Direct path
plot(dr_range, 10*log10(PL_direct), 'm-', 'LineWidth', 2.5);

xlabel('Receiver distance from IRS, $d_r$ [m]','Interpreter','latex','FontSize',13);
ylabel('$P_r/P_t$ [dB]','FontSize',13);
title({sprintf('Improvement 6B: IRS vs Direct Path  ($d_i = %dm$, $\\theta_i=\\theta_r=%d°$)',...
       di_fixed, THETA_I_DEG)},'Interpreter','latex','FontSize',12);
legend([size_labels, {'Direct path (free space)'}],...
       'Location','SouthWest','Interpreter','latex','FontSize',12);
set(gca,'XScale','log','FontSize',12);
xlim([1 1000]);

% Find crossover distances
for si = 1:length(size_factors)
    a_s  = size_factors(si) * lambda;
    b_s  = size_factors(si) * lambda;
    PL_IRS = (Gt * Gr * (a_s*b_s)^2 * cos(theta_i)^2 * cos(theta_r)^2) ...
             ./ ((4*pi)^2 * di_fixed^2 .* dr_range.^2);
    diff_dB = 10*log10(PL_IRS) - 10*log10(PL_direct);
    cross_idx = find(diff_dB < 0, 1, 'first');
    if ~isempty(cross_idx)
        fprintf('  %s: IRS worse than direct path beyond dr = %.1fm\n',...
            size_labels{si}, dr_range(cross_idx));
    else
        fprintf('  %s: IRS better than direct path for all dr\n', size_labels{si});
    end
end

%% ============================================================
%  PART C: Pathloss contour map — breakeven region
%  Shows WHERE in the (di, dr) space IRS outperforms direct path
%% ============================================================
fprintf('\n=== PART C: Breakeven Region Map ===\n');

di_vec2 = logspace(0.5, 3, 150);   % 3m to 1000m
dr_vec2 = logspace(0.5, 3, 150);
[DI2, DR2] = meshgrid(di_vec2, dr_vec2);

figure('Position',[850 30 750 500]);

for si = 1:length(size_factors)
    subplot(1,3,si);
    a_s = size_factors(si) * lambda;
    b_s = size_factors(si) * lambda;

    PL_IRS2 = (Gt*Gr*(a_s*b_s)^2*cos(theta_i)^2*cos(theta_r)^2) ...
              ./ ((4*pi)^2 .* DI2.^2 .* DR2.^2);

    D_direct2 = DI2 + DR2;
    PL_dir2   = (lambda ./ (4*pi*D_direct2)).^2 * Gt * Gr;

    gain_over_direct = 10*log10(PL_IRS2 ./ PL_dir2);

    imagesc(log10(di_vec2), log10(dr_vec2), gain_over_direct);
    colorbar;
    caxis([-40 40]);
    colormap(redblue_map(256));
    hold on;
    contour(log10(di_vec2), log10(dr_vec2), gain_over_direct, [0 0],...
            'w-','LineWidth',2);

    xlabel('$\log_{10}(d_i)$ [m]','Interpreter','latex','FontSize',11);
    ylabel('$\log_{10}(d_r)$ [m]','Interpreter','latex','FontSize',11);
    title(size_labels{si},'Interpreter','latex','FontSize',11);
    set(gca,'FontSize',10,...
        'XTick',[1 2 3],'XTickLabel',{'10','100','1k'},...
        'YTick',[1 2 3],'YTickLabel',{'10','100','1k'},'YDir','normal');
end
sgtitle({'Improvement 6C: IRS Gain over Direct Path [dB]';...
         '(White = breakeven, Blue = IRS worse, Red = IRS better)'},...
         'FontSize',12,'Interpreter','none');

%% ============================================================
%  PART D: Pathloss vs Total Path Length for balanced geometry
%  di = dr = d/2 (IRS placed halfway between Tx and Rx)
%% ============================================================
fprintf('\n=== PART D: Balanced Geometry (di=dr=d/2) ===\n');

d_total   = logspace(1, 3.5, 500);  % Total path 10m to ~3km
di_bal    = d_total / 2;
dr_bal    = d_total / 2;

figure('Position',[870 530 780 440]);
hold on; box on; grid on;

for si = 1:length(size_factors)
    a_s = size_factors(si) * lambda;
    b_s = size_factors(si) * lambda;

    PL_IRS_bal = (Gt*Gr*(a_s*b_s)^2*cos(theta_i)^2*cos(theta_r)^2) ...
                 ./ ((4*pi)^2 .* di_bal.^2 .* dr_bal.^2);

    plot(d_total, 10*log10(PL_IRS_bal), colors_b{si}, 'LineWidth', 2);
end

% Direct path (same total distance)
PL_dir_bal = (lambda ./ (4*pi*d_total)).^2 * Gt * Gr;
plot(d_total, 10*log10(PL_dir_bal), 'm-', 'LineWidth', 2.5);

xlabel('Total path length $d_i + d_r$ [m]','Interpreter','latex','FontSize',13);
ylabel('$P_r/P_t$ [dB]','FontSize',13);
title({'Improvement 6D: Pathloss vs Total Path (Balanced, $d_i=d_r$)';...
       sprintf('IRS at midpoint, $\\theta_i=\\theta_r=%d°$, $f_c=%.0fGHz$',...
       THETA_I_DEG, fc/1e9)},'Interpreter','latex','FontSize',12);
legend([size_labels, {'Direct path'}],...
       'Location','SouthWest','Interpreter','latex','FontSize',12);
set(gca,'XScale','log','FontSize',12);

% Add slope annotations
text(15, -40,'Direct: $d^{-2}$','Interpreter','latex','FontSize',11,'Color','m');
text(15, -90,'IRS: $d^{-4}$','Interpreter','latex','FontSize',11,'Color','k');

%% ============================================================
%  HELPER: Red-Blue colormap
%% ============================================================
function cmap = redblue_map(n)
    % Red-white-blue diverging colormap
    r = [linspace(0,1,n/2), ones(1,n/2)];
    g = [linspace(0,1,n/2), linspace(1,0,n/2)];
    b = [ones(1,n/2), linspace(1,0,n/2)];
    cmap = [r(:), g(:), b(:)];
end
