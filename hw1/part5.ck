// First, spork function (use yield) to play voicemail as ambient
// soundscape.
// using a UGen patched through an ADSR e, create a chord progression
// Then, use the sample to create a melody on top, spork it
// Use a sweeping LPF at random freq to create swelling chords

// setup ADSR envelope
// set A D S R
// attack = 10 ms
// decay = 40 ms
// sustain = .5
// release = 100 ms
ADSR e;
e.set(500::ms, 40::ms, .5, 100::ms);

// setup SqrOsc
SqrOsc v1 => e;
SqrOsc v2 => e;
SqrOsc v3 => e;
0.08 => v1.gain;
0.08 => v2.gain;
0.08 => v3.gain;

// chuck ADSR to reverb to LPF to dac
e => JCRev r => dac;
0.4 => r.mix;

// set LPF
LPF low;
100 => low.freq;
1 => low.Q;
0.8 => low.gain;

// note length
4::second => dur quarter;

// functions to set the frequency of each "voice" to the notes
// in their respective triad
// I = C E G
// iv = F A C
// V = G B D
// I = C E G
fun void setam() {
    Std.mtof(70) => v1.freq;
    Std.mtof(73) => v2.freq;
    Std.mtof(77) => v3.freq;
}

fun void setf() {
    Std.mtof(78) => v1.freq;
    Std.mtof(82) => v2.freq;
    Std.mtof(73) => v3.freq;
}

fun void setc() {
    Std.mtof(73) => v1.freq;
    Std.mtof(77) => v2.freq;
    Std.mtof(80) => v3.freq;    
}

fun void setem() {
    Std.mtof(77) => v1.freq;
    Std.mtof(80) => v2.freq;
    Std.mtof(72) => v3.freq;
}

fun void play(dur t) {
    e.keyOn();
    t - e.releaseTime() => now;
}

fun void off(dur t) {
    e.keyOff();
    t - e.releaseTime() => now;
}

// function to play voicemail wave file
fun void playMail() {
    // sound file
    me.sourceDir() + "/wav/voicemail.wav" => string filename;
    if(me.args()) me.arg(0) => filename;
    
    // patch SndBuf to dac and load the file
    SndBuf buf1 => dac;
    filename => buf1.read;
    
    while(true) {
        0 => buf1.pos;
        0.4 => buf1.gain;
        30::second => now;
    }
}

// function to play handmade sample as an impulse train
fun void playSamp() {
    // sound file
    me.sourceDir() + "/wav/part3.wav" => string filename;
    if(me.args()) me.arg(0) => filename;
    
    // patch SndBuf to dac and load the file
    SndBuf buf2 => low => dac;
    filename => buf2.read;
    
    // to track next wave number for sweeping LPF
    0.0 => float t;
    
    while(true) {
        // sweep the filter resonant frequency 100 Hz to 800 Hz
        100 + Std.fabs(Math.sin(t)) * 3000.0 => low.freq;
        t + .01 => t;
        0 => buf2.pos;
        
        // randomize the gain and rate of the sample.
        Math.random2f(1.0, 5.0) => buf2.gain;
        
        // consonant pitch with the chord progression
        0.6 => buf2.rate;
        
        1::second => now;
    }
}

// spork function to play the voicemail and give it priority
spork ~ playMail();
me.yield();

// spork function to play the handmade sample
spork ~ playSamp();

// infinite loop to play chord structure
while(true) {
    
    // advance chord progression
    setam();
    play(quarter);
    off(quarter / 4);
    
    setf();
    play(quarter);
    off(quarter / 4);

    setc();
    play(quarter);
    off(quarter / 4);
    
    setem();
    play(quarter);
    off(quarter / 4);
}

