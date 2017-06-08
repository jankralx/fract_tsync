# Fractional Synchronisation

The time fractional synchronisation based on spectra phase difference
between signals for digital predistortion systems.

The scripts provided supplements a research paper Analytical Method of
Fractional Sample Period Synchronisation for Digital Predistortion
Systems by Jan KRAL, Tomas GOTTHANS, and Michal HARVANEK.

[sig_sync/fract_sync_fft.m](sig_sync/fract_sync_fft.m) - function
 which detects time delay between two signals and compensates this
 delay

[sig_sync/sig_delay_fft.m](sig_sync/sig_delay_fft.m) - function which
  shifts a signal in spectrum domain by given delay

[o1_delay_influence.m](o1_delay_influence.m) - scritp which generates
  figures of the research paper indicating the influence of time delay
  on digital predistortion systems

[o2_plot_results.m](o2_plot_results.m) - script which implements
  fract_sync_fft and sig_delay_fft functions on measured data of the
  digital predistortion system

# Citation
If used for research, plese cite our paper
[http://ieeexplore.ieee.org/abstract/document/7937603/](http://ieeexplore.ieee.org/abstract/document/7937603/)
or download the [bibtex citation](citation.bib).
