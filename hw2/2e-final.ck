5 => float DENSITY;

// global UGen
NRev rev => dac;

// mix reverb
.05 => rev.mix;

// function
fun void makeSound(float pitch, float vel, dur T)
{
    // ugens "local" to the function
    TriOsc s => ADSR e => rev;
    
    // frequency and gain
    Std.mtof(pitch) => s.freq;
    vel => s.gain;
    
    // open env
    e.set(50::ms, 50::ms, .08, 50::ms);
    e.keyOn();
    
    // A to S
    T-e.releaseTime() => now;
    
    // close env
    e.keyOff();
    
    // release
    e.releaseTime() => now;
    
}

fun void modulateDensity() {
    while(true) {
        1 + ((Math.sin(now/second * .75) + 1) / 2) * 9 => DENSITY;
        10::ms => now;
    }
}

spork ~ modulateDensity();  

while(true) {
    
    // check density parameter, adjust if needed
    if(DENSITY < 1) 1 => DENSITY;
    if(DENSITY > 10) 10 => DENSITY;
    
    // Density and wait time between notes are inversely related
    // computer inverse of density and set to wait time
    10/DENSITY * 80 => float min;
    
    (min + 1 * Math.random2f(0, min/2))::ms => dur minT;
    
    // spork sound
    spork ~ makeSound(60, .1, DENSITY * Math.random2f(.2, .4)::second);
    spork ~ makeSound(64, .1, DENSITY * Math.random2f(.2, .4)::second);
    spork ~ makeSound(Math.random2f(50, 70), .1, DENSITY * Math.random2f(.2, .4)::second);
    
    
    minT => now;
}