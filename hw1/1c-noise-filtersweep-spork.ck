Noise n => LPF low => dac;

// set initial noise gain
1 => n.gain;

// set filter quality and gain
1 => low.Q;
0.1 => low.gain;

// to tack next wave numbers
0.0 => float t;

// function to spork to oscillate the resonant frequency
fun void sweep() {
    0.0 => float gain;
    
    while(true) {
        // sweep the filter resonant frequency 100 Hz to 800 Hz
        100.0 + Std.fabs(Math.sin(t)) * 700.0 => low.freq;
        
        // move to next wave number
        t + .01  => t;
        
        // wait 10 seconds to change filter resonance
        10::ms => now;
    }
}

spork ~ sweep();

while(true) {
    // advance time
    10::ms => now;
}