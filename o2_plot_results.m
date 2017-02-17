% Authors: Jan Kral <kral.j@lit.cz>
% Date: 20.1.2017

clear all;
close all;

addpath('Utils');
addpath('sig_sync');

load('TB_SMU200A_FSVR/nosync.mat');

% sample synchronization
[c,lags]=xcorr(Sig_Tx,Sig_Rx);
[val,pos]=max(abs(c));
lags(pos)

Rx2 = vector_shift(Sig_Rx,-lags(pos));
[Tx2, Rx2] = sync_length(Sig_Tx, Rx2);

G = lscov(Sig_Tx.',Rx2);
Rx2 = (1/G).*Rx2;

Rx2 = Rx2./max(abs(Rx2));
Tx2 = Tx2./max(abs(Tx2));

% sample synchronization for DPD signal
[c,lags]=xcorr(Sig_Tx2,Sig_Rx2);
[val,pos]=max(abs(c));
lags(pos)

Rx3 = (vector_shift(Sig_Rx2,-lags(pos)));
[Tx3,Rx3] = sync_length(Sig_Tx2, Rx3);

G = lscov(Sig_Tx.',Rx3);
Rx3 = (1/G).*Rx3;

Rx3=Rx3./max(abs(Rx3));

%% plot results

am_fig = figure();
plot(abs(Sig_Tx),abs(Rx2),'.', 'DisplayName','PA without fractional synchronisation');
hold on;
plot(abs(Sig_Tx),abs(Rx3),'.', 'DisplayName','Linearised PA without fractional synchronisation');
hold off;

pm_fig = figure();
% pm = mod(angle(Sig_Tx)-angle(Rx2.'), 2*pi);
% pm = pm - (pm > pi)*2*pi;
% plot(abs(Sig_Tx), pm,'.');
% hold on;
pm = mod(angle(Sig_Tx)-angle(Rx3.'), 2*pi);
pm = pm - (pm > pi)*2*pi;
plot(abs(Sig_Tx), pm,'.', 'DisplayName','Without fractional synchronisation');
hold off;

%% synced signals
load('TB_SMU200A_FSVR/sync.mat');

% sample synchronization
[c,lags]=xcorr(Sig_Tx,Sig_Rx);
[val,pos]=max(abs(c));
lags(pos)

Rx2 = vector_shift(Sig_Rx,-lags(pos));
[Tx2, Rx2] = sync_length(Sig_Tx, Rx2);

params.debug = false;
params.trim = true;
[~, fract_delay] = fract_sync_fft(abs(Tx2), abs(Rx2.'), params);
Rx2 = sig_delay_fft(Rx2, -fract_delay);

G = lscov(Sig_Tx.',Rx2);
Rx2 = (1/G).*Rx2;

Rx2 = Rx2./max(abs(Rx2));
Tx2 = Tx2./max(abs(Tx2));

% sample synchronization for DPD signal
[c,lags]=xcorr(Sig_Tx2,Sig_Rx2);
[val,pos]=max(abs(c));
lags(pos)

Rx3 = (vector_shift(Sig_Rx2,-lags(pos)));
[Tx3,Rx3] = sync_length(Sig_Tx2, Rx3);

params.debug = true;
params.trim = true;
[~, fract_delay] = fract_sync_fft(abs(Tx3), abs(Rx3.'), params);
Rx3 = sig_delay_fft(Rx3, -fract_delay);

G = lscov(Sig_Tx.',Rx3);
Rx3 = (1/G).*Rx3;

Rx3=Rx3./max(abs(Rx3));

%% plot results

figure(am_fig);
hold on;
plot(abs(Sig_Tx),abs(Rx2),'.', 'DisplayName','PA with fractional synchronisation');
plot(abs(Sig_Tx),abs(Rx3),'.', 'DisplayName','Linearised PA with fractional synchronisation');
hold off;

figure(pm_fig);
hold on;
pm = mod(angle(Sig_Tx)-angle(Rx3.'), 2*pi);
pm = pm - (pm > pi)*2*pi;
plot(abs(Sig_Tx), pm,'.', 'DisplayName','With fractional synchronisation');
hold off;

%% plot labels
figure(am_fig);
set(gcf, 'Position', [0 0 600 400]);

title('\textbf{Measured AM/AM characteristics of the PA}');
xlabel('Relative input magnitude (-)');
ylabel('Relative output magnitude (-)');
legend('show', 'Location', 'southeast');
grid on;

ApplyFigureSettings(am_fig);
% saveas(gcf, 'figures/am_am-measurement.pdf');

figure(pm_fig);
set(gcf, 'Position', [0 0 600 300]);

title('\textbf{Measured linearised AM/PM characteristics of the PA}');
xlabel('Relative input magnitude (-)');
ylabel('Phase difference (rad)');
legend('show');
grid on;
axis([0 1, -pi pi]);

ApplyFigureSettings(pm_fig);
% saveas(gcf, 'figures/am_pm-measurement.pdf');


% spect_fig = figure(4);
% set(gcf, 'Position', [0 0 600 400]);
% 
% title('\textbf{Phase difference of the synchronised signals}');
% xlabel('Frequency ($F_S$)');
% ylabel('Phase difference (rad)');
% grid on;
% 
% ApplyFigureSettings(spect_fig);
% % saveas(gcf, 'figures/spect-measurement.pdf');

