SqrOsc sqr => LPF low => dac;

// set sqr osc
0.4 => sqr.gain;
220 => sqr.freq;

// set LPF
100 => low.freq;
1 => low.Q;
0.8 => low.gain;

0.0 => float t;

while(true) {
    // sweep the filter resonant frequency 100 Hz to 800 Hz
    100 + Std.fabs(Math.sin(t)) * 800.0 => low.freq;
    
    t + .01 => t;
    
    // advance time
    10::ms => now;
}