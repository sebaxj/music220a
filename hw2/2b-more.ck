// globally shared ugens
NRev reverb => dac;
.1 => reverb.mix;

// function
fun void makeSound( float pitch, float vel, float cutoff, 
dur attack, dur decay, float sustain, dur release )
{
    // ugens "local" to the function
    TriOsc s;
    
    // connect to "global" ugens
    s => LPF low => ADSR e => reverb;
    
    // set LPF
    cutoff => low.freq;
    1 => low.Q;
    0.5 => low.gain;
    
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
}

while( true )
{
    spork ~ makeSound( 60, .5, 500, 50::ms, 50::ms, .5, 100::ms );
        
    // advance time
    300::ms => now; 
}