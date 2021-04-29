SqrOsc sqr => LPF low => dac;

// set sqr osc
1.0 => sqr.gain;

// set LPF
500 => low.freq;
1 => low.Q;
0.1 => low.gain;

// to track next wave number
0.0 => float t;

while(true) {
    // sweep the square wave frequency 30 Hz to 3000 Hz
    30.0 + Std.fabs(Math.sin(t)) * 2970 => sqr.freq;
    
    // move to next wave number
    t + .01 => t;
    
    // advance time
    10::ms => now;
}