SinOsc sin => dac;

// set sine wave gain
0.1 => sin.gain;

// to track next wave numbers
0.0 => float t;

while(true) {
    // sweep the sine wave frequency from 30 Hz to 3000 Hz
    30.0 + Std.fabs(Math.sin(t)) * 2970.0 => sin.freq;
    
    // move to next wave number
    t + .01 => t;
    
    // advance time
    10::ms => now;
}