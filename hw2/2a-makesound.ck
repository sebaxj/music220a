// globally shared ugens
LPF low => NRev reverb => dac;
.1 => reverb.mix;

0 => float t;
2000 => low.freq;
4 => low.Q;

// function
fun void makeSound()
{
    // ugens "local" to the function
    TriOsc s;
    // connect to "global" ugens
    s => ADSR e => low;
    
    // randomize frequency
    Math.random2f(30,1000) => s.freq;
    // randomize duration
    Math.random2f(50,1500)::ms => now;
    
    0 => t;
}

fun void lfo(LPF low) {
    while(true) {
        1000 + Math.sin(t) * 600 => low.freq;
        t + 0.05 => t;
        5::ms => now;
    }
}

spork ~ lfo(low);

while( true )
{
    // spork a new concurrent shred
    spork ~ makeSound();
    // advance time
    300::ms => now;
}