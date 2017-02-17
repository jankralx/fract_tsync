% Authors: Jan Kral <kral.j@lit.cz>
% Date: 20.1.2017

clear all;
close all;

addpath('Utils');
addpath('sig_sync');


% -------------------------------------------------------------------------
% parameters
% -------------------------------------------------------------------------

% PA
par.PA.coef = [ 0.509360227527429 + 1.09524853022532i;...
               -0.0992873613403637 - 0.170261849774516i;...
               -0.0347754375003473 - 0.0247212149015436i;...
               -0.00353320874772281 - 0.00211119148781448i;...
               0.00260430842062743 - 0.00429101487393531i;...
               0.00320810224865987 - 0.000580829859014498i;...
               -0.000816817963483357 + 0.000357784194921971i];

par.PA.K = 7;
par.PA.Q = 0;

% plot settings
par.outs.is_AM_plot = 1;

% load testing signal
load('qam16.mat');
tx_signal = (Real+1j*Imag);
tx_signal = 0.9*tx_signal./max(abs(tx_signal));
clear Real;
clear Imag;

% Calculate PA model output
pa_signal = PA_Model(tx_signal.',par.PA.coef, par.PA.K, par.PA.Q).';

if (par.outs.is_AM_plot)
    am_fig = figure();
    pm_fig = figure();
end

for del = [0.5 0.2 0]
    
    fb_signal = sig_delay_fft(pa_signal, del);

    if (par.outs.is_AM_plot)
        tx_signal = tx_signal./max(abs(tx_signal));
        
        % plot AM-AM characteristics
        figure(am_fig);
        hold on;
        plot(abs(tx_signal), abs(fb_signal), '.', ...
            'DisplayName', sprintf('$\\tau / T_S = %.1f$',del));
        hold off;
        
        figure(pm_fig);
        hold on;
        plot(abs(tx_signal), mod(angle(tx_signal)-angle(fb_signal),2*pi),...
            '.', 'DisplayName', sprintf('$\\tau / T_S = %.1f$',del));
        hold off;
    end
end

% modification and export of AM-AM plot
figure(am_fig);
set(gcf, 'Position', [0 0 600 400]);

title('\textbf{Influence of time delay on AM/AM characteristics}');
xlabel('Relative input magnitude (-)');
ylabel('Relative output magnitude (-)');
grid on;
legend('show', 'Location', 'southeast');

ApplyFigureSettings(am_fig);
% saveas(gcf, 'figures/am_am-delay_influence.pdf');

figure(pm_fig);
set(gcf, 'Position', [0 0 600 300]);

title('\textbf{Influence of time delay on AM/PM characteristics}');
xlabel('Relative input magnitude (-)');
ylabel('Phase difference (rad)');
grid on;
axis([0 1 3 7]);
legend('show');

ApplyFigureSettings(pm_fig);
% saveas(gcf, 'figures/am_pm-delay_influence.pdf');







