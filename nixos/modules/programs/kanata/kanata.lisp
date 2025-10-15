(defsrc
  esc           f1     f2     f3
  grv           1      2      3      4      5      6      7      8      9       0       min     eql
                q      w      e      r      t      y      u      i      o       p       lbrc    rbrc    bksl
  caps          a      s      d      f      g      h      j      k      l       scln    apos
  lsft          z      x      c      v      b      n      m      comm   Period  Slash   rsft)
  
(deflayer qwerty
  @esc-behavior @qf1   @df2   @qf3
  grv           1      2      3      4      5      6      7      8      9       0       min     eql
                q      w      e      r      t      y      u      i      o       p       lbrc    rbrc    bksl
  @cac          a      s      d      f      g      h      j      k      l       scln    apos
  lsft          z      x      c      v      b      n      m      comm   Period  Slash   rsft)

(deflayer raw-qwerty
  esc           @qf1   @df2   @qf3
  grv           1      2      3      4      5      6      7      8      9       0       min     eql
                q      w      e      r      t      y      u      i      o       p       lbrc    rbrc    bksl
  caps          a      s      d      f      g      h      j      k      l       scln    apos
  lsft          z      x      c      v      b      n      m      comm   Period  Slash   rsft)

(deflayer dorvak-programmer
  @esc-behavior @qf1   @df2   @qf3
  @dv1-1        @dv1-2 @dv1-3 @dv1-4 @dv1-5 @dv1-6 @dv1-7 @dv1-8 @dv1-9 @dv1-10 @dv1-11 @dv1-12 @dv1-13
                scln   comm   Period p      y      f      g      c      r       l       Slash   @dv2-13 bksl
  @cac          a      o      e      u      i      d      h      t      n       s       min
  lsft          apos   q      j      k      x      b      m      w      v       z       rsft)

(defalias
  cac (tap-hold 190 190 esc lctrl)
  esc-behavior (tap-hold 190 190 esc caps)

  qf1 (tap-dance 200 (f1 (layer-switch qwerty)))
  df2 (tap-dance 200 (f2 (layer-switch dorvak-programmer)))
  qf3 (tap-dance 200 (f3 (layer-switch raw-qwerty)))

  dv1-1 (fork S-4 S-grv (lsft rsft))
  dv1-2 (fork S-7 S-5 (lsft rsft))
  dv1-3 (fork (un⇧ lbrc) (un⇧ 7) (lsft rsft))
  dv1-4 (fork S-lbrc (un⇧ 5) (lsft rsft))
  dv1-5 (fork S-rbrc (un⇧ 3) (lsft rsft))
  dv1-6 (fork S-9 (un⇧ 1) (lsft rsft))
  dv1-7 (fork eql (un⇧ 9) (lsft rsft))
  dv1-8 (fork S-8 (un⇧ 0) (lsft rsft))
  dv1-9 (fork S-0 (un⇧ 2) (lsft rsft))
  dv1-10 (fork S-eql (un⇧ 4) (lsft rsft))
  dv1-11 (fork (un⇧ rbrc) (un⇧ 6) (lsft rsft))
  dv1-12 (fork S-1 (un⇧ 8) (lsft rsft))
  dv1-13 (fork S-3 (un⇧ grv) (lsft rsft))

  dv2-13 (fork S-2 S-6 (lsft rsft)))
