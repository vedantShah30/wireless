%% MASTER SCRIPT — Run All 3 IRS Improvements
%
% Based on: Ozdogan, Bjornson, Larsson,
% "Intelligent Reflecting Surfaces: Physics, Propagation, and Pathloss Modeling"
% IEEE Wireless Communications Letters, Vol. 9, No. 5, May 2020.
% DOI: 10.1109/LWC.2019.2963960
%
% ═══════════════════════════════════════════════════════
%  IMPROVEMENTS OVER ORIGINAL PAPER
% ═══════════════════════════════════════════════════════
%
%  IMPROVEMENT 1 — improvement1_rectangular_IRS.m
%    Non-Square Rectangular IRS Geometry
%    • Part A: Fixed area, varying aspect ratio (a≠b)
%    • Part B: -3dB Beamwidth vs b-dimension (with theory curve)
%    • Part C: Peak gain heatmap over (a,b) parameter space
%
%  IMPROVEMENT 2 — improvement2_multifrequency.m
%    Multi-Frequency Band Analysis (0.7 GHz → 60 GHz)
%    • Part A: Beam patterns for all 5G/mmWave bands, fixed physical size
%    • Part B: Bar charts — Peak gain and beamwidth per band
%    • Part C: Fixed electrical size (a=b=λ) — confirms scaling law
%    • Part D: Far-field (Rayleigh) distance table per band
%
%  IMPROVEMENT 6 — improvement6_pathloss_distance.m
%    End-to-End Pathloss vs Distance (Eq. 20 from paper)
%    • Part A: 3D surface — pathloss vs di and dr
%    • Part B: IRS vs Direct path — crossover distance
%    • Part C: 2D heatmap — breakeven region in (di,dr) space
%    • Part D: Balanced geometry (IRS at midpoint) d^-4 vs d^-2 law
%
% ═══════════════════════════════════════════════════════
%  HOW TO RUN
% ═══════════════════════════════════════════════════════
%  Option 1: Run this master script (runs all 3 sequentially)
%  Option 2: Run each .m file individually for focused analysis
%
% ═══════════════════════════════════════════════════════
%  KEY EQUATIONS USED
% ═══════════════════════════════════════════════════════
%  Eq. 4  (Scattering Gain):
%    S(r,θs) = (ab)²/λ² · cos²(θi) · [sin(y)/y]²
%    where y = (k0·b/2)·(sin(θs) - sin(θi))
%
%  Eq. 20 (End-to-End Pathloss):
%    Pr/Pt = Gt·Gr·(ab)²·cos²(θi)·cos²(θr) / [(4π)²·di²·dr²]
%
%  Beamwidth approximation:
%    BW ≈ λ / (b·cos(θi))   [radians]

clear; close all; clc;

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════╗\n');
fprintf('║  IRS Pathloss Paper — 3 Research Improvements        ║\n');
fprintf('║  Ozdogan, Bjornson, Larsson (IEEE WCL 2020)          ║\n');
fprintf('╚══════════════════════════════════════════════════════╝\n\n');

%% Run Improvement 1
fprintf('▶ Running Improvement 1: Rectangular IRS Geometry...\n');
run('improvement1_rectangular_IRS.m');
fprintf('✓ Improvement 1 complete. (3 figures generated)\n\n');

%% Run Improvement 2
fprintf('▶ Running Improvement 2: Multi-Frequency Analysis...\n');
run('improvement2_multifrequency.m');
fprintf('✓ Improvement 2 complete. (4 figures generated)\n\n');

%% Run Improvement 6
fprintf('▶ Running Improvement 6: End-to-End Pathloss vs Distance...\n');
run('improvement6_pathloss_distance.m');
fprintf('✓ Improvement 6 complete. (4 figures generated)\n\n');

fprintf('═══════════════════════════════════════════════════════\n');
fprintf('All improvements complete! Total figures: 11\n');
fprintf('═══════════════════════════════════════════════════════\n\n');
fprintf('SUMMARY OF KEY FINDINGS:\n');
fprintf('─────────────────────────────────────────────────────\n');
fprintf('Impr. 1: Only b (not a) controls beamwidth.\n');
fprintf('         Doubling both a,b → +12dB peak gain.\n');
fprintf('         BW ≈ λ/(b·cos(θi)) — verified vs simulation.\n\n');
fprintf('Impr. 2: At 60GHz, a 0.5m panel is 100λ wide:\n');
fprintf('         gain is ~40dB higher than at 0.7GHz.\n');
fprintf('         Electrical-size-normalized pattern is frequency-invariant.\n\n');
fprintf('Impr. 6: IRS pathloss ∝ d⁻⁴ vs direct link d⁻².\n');
fprintf('         Larger IRS extends the regime where IRS > direct.\n');
fprintf('         Breakeven distance visible in (di,dr) heatmap.\n');
