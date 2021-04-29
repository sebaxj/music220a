Noise n => LPF low => dac;

// set intial noise gain
1 => n.gain;


// set filter quality and gain
1 => low.Q;
0.1 => low.gain;

// to track next wave numbers
0.0 => float t;

while(true) {
    // sweep the filter resonant frequency from 100 Hz to 800 Hz
    100.0 + Std.fabs(Math.sin(t)) * 700.0 => low.freq;
    
    // move to next wave number
    t + .01 => t;
    
    // advance time
    10::ms => now;
}