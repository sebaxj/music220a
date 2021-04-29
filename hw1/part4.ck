// sound file
me.sourceDir() + "/wav/part3.wav" => string filename;
if(me.args()) me.arg(0) => filename;

// patch SndBuf to dac and load the file
SndBuf buf => dac;
filename => buf.read;

while(true) {
    0 => buf.pos;
    
    // randomize the gain and rate of the sample.
    Math.random2f(0.001, 10.0) => buf.gain;
    Math.random2f(0.01, 4.0) => buf.rate;
    
    100::ms => now;
}