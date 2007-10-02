
  sr        =           44100
  kr        =           4410
  ksmps     =           10
  nchnls    =           2

  isin      ftgen       1, 0, 8193, 10, 1

instr 1
        ;; Description of Arguments:
  idur      =           p3                      ; Duration
  iamp      =           p4 * 30000               ; normalised amp (0.0-1.0)
  ifqc      =           440.0 * semitone(p5-69) ; Keynumber

  kamp      linseg      iamp, p3*0.99, iamp, p3*0.01, 0
  a1        pluck       kamp, ifqc, ifqc, 0, 1
            outs        a1, a1
endin 

