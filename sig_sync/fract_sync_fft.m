function [ sig_d, delay ] = fract_sync_fft( ref, sig, params )
%sig_sync Synchronises a given signal to the reference signal within subsample precision.
%   ref - is reference signal to be synchronised to
%   sig - is given signal to be synchronised, it has to be presynchronised
%         with precision of the whole Time period, e.g. by
%         cross-correlation
%   params - is an optional structure of function parameters
%   params.debug - if true, frequency and other plots are enabled.
%                  Default: false
%   params.trim - if true, the signals are trimmed to be the same length
%                 before synchronisation
%                 Default: false
%   params.freq_lim - limits to be used for delay calculation. If single
%                     number is given, then the spectrum used for the
%                     calculation is from -freq_lim to freq_lim. Otherwise
%                     expects two-parameter array as [-freq_lim freq_lim].
%                     The unit of freq_lim is Fs. Can be set as 'auto' to
%                     determine the interval based on the signal energy.
%                     Default: 'auto'
%                     
%   returns:
%   sig_d - is sig synchronised with reference signal
%   delay - is delay in number of samples

% Authors: Jan Kral <kral.j@lit.cz>
% Date: 14.01.2017

% default input arguments
if nargin < 3
    params.trim = false;
end
    
if ~isfield(params, 'trim')
    params.trim = false;
end
    
if ~isfield(params, 'debug')
    params.debug = false;
end

if ~isfield(params, 'freq_lim')
    params.freq_lim = 'auto';
end

if numel(params.freq_lim) == 1
    params.freq_lim = [-params.freq_lim; params.freq_lim];
end

% transpose input signals if needed
if size(sig,2) ~= 1
    if size(sig,1) ~= 1
        error('fract_sync_fft can work only with 1-D signals');
    end
    
    sig = sig.';
    is_transpose = 1;
else
    is_transpose = 0;
end

if size(ref,2) ~= 1
    if size(ref,1) ~= 1
        error('fract_sync_fft can work only with 1-D signals');
    end
    
    ref = ref.';
end

% check if input signal is real so output will be real as well
if isreal(sig)
    is_real = 1;
else
    is_real = 0;
end

% trim signals to be the same length
is_sig_orig = 0;
if length(ref) < length(sig)
    if params.trim == false
        sig_orig = sig;                 % save for output signal in full length
        is_sig_orig = 1;
    end
    sig = sig(1:length(ref));
else
    ref = ref(1:length(sig));
end

% convert to fft
Ref_fft = fft(ref-mean(ref));
Sig_fft = fft(sig-mean(sig));

% continue only with phase as there is information about time
ref_phase = angle(fftshift(Ref_fft));
sig_phase = angle(fftshift(Sig_fft));

phase_diff = mod(ref_phase - sig_phase, 2*pi);
phase_diff = phase_diff - 2*pi*(phase_diff > pi);

freq_axis = (-length(ref_phase)/2+1:length(ref_phase)/2).';


% check if the frequency limits are to be determined or are given
if params.freq_lim == 'auto'
    % use reference signal for interval extraction
    ref_fft_abs = abs(fftshift(Ref_fft));
    freq_selection = ref_fft_abs > mean(ref_fft_abs);
else
    freq_selection = params.freq_lim(1)*length(phase_diff)+length(phase_diff)/2+1 : ...
        params.freq_lim(2)*length(phase_diff)+length(phase_diff)/2;
end

% use only part of signal to calculate the least squares
phase_diff_sel = phase_diff(freq_selection);
freq_axis_sel = freq_axis(freq_selection);

% calculate the delay using the least squares
delay = sum(freq_axis_sel.*phase_diff_sel)/sum(freq_axis_sel.^2);

if params.debug
    figure();
    ax(1) = subplot(3,1,1);
    plot(freq_axis/length(ref_phase), 20*log10(abs(fftshift(Sig_fft))),...
        'DisplayName','sig');
    hold on;
    plot(freq_axis/length(ref_phase), 20*log10(abs(fftshift(Ref_fft))),...
        'DisplayName','reference');
    hold off;
    title('Magnitude signal spectra');
    xlabel('Frequency (Fs)');
    ylabel('Magnitude (dB)');
    legend('show');

    ax(2) = subplot(3,1,2);
    plot(freq_axis/length(ref_phase), phase_diff, '.');
    hold on;
    plot(freq_axis/length(ref_phase), delay*freq_axis, 'LineWidth', 3);
    if params.freq_lim == 'auto'
        % plot lines on top and bottom to show the points of selection
        plot(freq_axis_sel/length(ref_phase),...
            repmat(3.9,length(freq_axis_sel),1), 'm','LineWidth', 3);
        plot(freq_axis_sel/length(ref_phase),...
            repmat(-3.9,length(freq_axis_sel),1), 'm','LineWidth', 3);
    else
        % plot the lines of frequency limits
        plot([params.freq_lim(1) params.freq_lim(1)], [-4 4], 'm');
        plot([params.freq_lim(2) params.freq_lim(2)], [-4 4], 'm');
    end
    hold off;
    title('Phase difference of signals being synchronised');
    xlabel('Frequency (Fs)');
    ylabel('Phase difference (rad)');
end

% if there is original signal that has to be shifted in time
if is_sig_orig
    % if sig_orig exists, it is needed to shift this signal
    % calculate its spectrum
    Sig_fft = fft(sig_orig);
end

% delay the given signal by time given by the parameter delay
Sig_fft = ifftshift(fftshift(Sig_fft) ...
    .* exp(1j*delay*(-length(Sig_fft)/2+1:length(Sig_fft)/2).'));
sig_d = ifft(Sig_fft);

if params.debug
    sig_phase = angle(fftshift(Sig_fft));
    phase_diff = mod(ref_phase - sig_phase, 2*pi);
    phase_diff = phase_diff - 2*pi*(phase_diff > pi);
    
    ax(3) = subplot(3,1,3);
    hold on;
    plot(freq_axis/length(ref_phase),phase_diff, '.');
    hold off;
    title('Phase difference of synchronised signals');
    xlabel('Frequency (Fs)');
    ylabel('Phase difference (rad)');
    linkaxes(ax, 'x');
    
%     figure();
%     if length(ref) < 1000
%         disp_len = length(ref);
%     else
%         disp_len = 1000;
%     end;
%     ref_abs = abs(ref(1:disp_len));
%     ref_abs = ref_abs/max(ref_abs);
%     plot(ref_abs, 'DisplayName','reference');
%     hold on;
%     sig_abs = abs(sig(1:disp_len));
%     sig_abs = sig_abs/max(sig_abs);
%     plot(sig_abs, 'DisplayName','original');
%     sig_d_abs = abs(sig_d(1:disp_len));
%     sig_d_abs = sig_d_abs/max(sig_d_abs);
%     plot(sig_d_abs, 'DisplayName','shifted');
%     hold off;
%     title('Synchronised signals in time domain');
%     xlabel('Sample index (-)');
%     ylabel('Signal magnitude (-)');
%     legend('show');    
end

% if the signal was real put only real component at output
if is_real
    sig_d = real(sig_d);
end

% if the signal was transposed on input transpose it back
if is_transpose
    sig_d = sig_d.';
end

% give the delay out in correct unit
delay = 1/(2*pi)*delay*length(Sig_fft);

end

