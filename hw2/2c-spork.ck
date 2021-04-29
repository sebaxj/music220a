// globally shared ugens
LPF low => NRev reverb => dac;
.1 => reverb.mix;

// set LPF
0 => float t;
2000 => low.freq;
4 => low.Q;

// function
fun void makeSound( float pitch, float vel, float cutoff, 
dur attack, dur decay, float sustain, dur release )
{
    // ugens "local" to the function
    TriOsc s;
    
    // connect to "global" ugens
    s => low => ADSR e => reverb;
    
    // frequency and gain
    Std.mtof(pitch) => s.freq;
    vel => s.gain;
    
    // open env (e is your envelope
    e.set(attack, decay, sustain, release);
    e.keyOn();
    
    // A through end of S
    e.releaseTime() => now;
    
    // close env
    e.keyOff();
    
    // release
    e.releaseTime() => now;
    
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
    // C
    for(0 => int i; i < 8; i++) {
        spork ~ makeSound( 60, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        spork ~ makeSound( 64, .5, 500, 50::ms, 50::ms, .5, 100::ms ); 
        spork ~ makeSound( 67, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        
        // advance time
        300::ms => now; 
    }
    
    // G
    for(0 => int i; i < 8; i++) {
        spork ~ makeSound( 59, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        spork ~ makeSound( 62, .5, 500, 50::ms, 50::ms, .5, 100::ms ); 
        spork ~ makeSound( 67, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        
        // advance time
        300::ms => now; 
    }
    
    // Am
    for(0 => int i; i < 8; i++) {
        spork ~ makeSound( 60, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        spork ~ makeSound( 64, .5, 500, 50::ms, 50::ms, .5, 100::ms ); 
        spork ~ makeSound( 69, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        
        // advance time
        300::ms => now; 
    }
    
    // F Maj
    for(0 => int i; i < 8; i++) {
        spork ~ makeSound( 60, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        spork ~ makeSound( 65, .5, 500, 50::ms, 50::ms, .5, 100::ms ); 
        spork ~ makeSound( 69, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        
        // advance time
        300::ms => now; 
    }
}