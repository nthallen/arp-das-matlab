This directory addresses two different issues relating to thermistors:

1. Deciding what pullup value to use with a given thermistor in order to obtain a desired resolution over a desired temperature range.

2. Given a thermistor configuration, generate a TMC calibration.

  gencal.m  Attempt at simplifying the interface
    pickpts.m These could use tweaking to produce better graphics
    allpts.m
  flowt.m   Example invoking gencal.m
  pumpt.m   Another example (T30K pulled up by 200K)
  T10m.m    Reads T10m.dat, write calib.tmc
  T30K75.m  T30K pulled up by 75K

  gencal2.m     Newer version of gencal, etc. that automatically determines
    pickpts2.m  threshold values
    allpts2.m
  T30K30KD.m T30K pulled down by 30.1K
  T30K1MU.m  T30K pulled up by 1M
  T30KXKU.m  T30K pulled up by specified resistor (default 75K)
  T10KXKU.m  T10K pulled up by specified resistor (default 100K)
  T30K475K.m T30K pulled up by 475K, 16-bit conversion.
  T100K475K.m T100K pulled up by 475K read into DMM32
  AD16_RTD.m  RTD used on CIMS
  AD16_SkP.m  Skimmer Pressure Cal
  
  gencal3.m  Even newer version, candidate to move into library

3. Data Files

  T30K.dat  Temp(C) Resistance(Ohms)
  T30K.mat  T, Rt
  T10m.dat  Temp(C) Ratio R/R0 where R0 = 10^7
  T10kold.mat  To => Temperature(C)  Co => Counts
  TM4.mat   Thermometrics Curve 4 T, Rrat (good for 10K)
  TM457.mat Thermometrics Curves 4 (10K), 5 (30K & 50K) and 7 (100K)
  C00385.dat RTD Resistance curve (AD16_RTD)
  CRflow.txt Steinhart-hart coefficients and pullup resistances for CRflow studies
  