Noise n => dac;
.1 => n.gain;

// time loop for 10 seconds
10000 => float t;
while(t > 0)
{
    1::ms => now;
    t - 1 => t;
}