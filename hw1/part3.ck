// create an array to store digital sample values (between 0.0 and 1.0)
// These numbers are based on the Fibonacci sequence. 
[0.0, 1.0, 1.0, 0.2, 0.3, 0.5, 0.8, 0.13, 0.21, 
0.34, 0.55, 0.89, 0.144, 0.233, 0.377, 0.610, 0.987, 
0.1597, 0.2584, 0.4181, 0.6765, 0.10946, 0.17711, 0.28657, 
0.46368, 0.75025, 0.121393, 0.196418, 0.317811, 0.514229, 
0.832040, 0.1346269, 0.2178309, 0.3524578, 0.5702887,
0.9227465, 0.14930352, 0.24157817, 0.39088169, 0.63245986,
0.102334155, 0.165580141, 0.267914296, 0.433494437] @=> float samples[];

// sample feeder
Impulse feeder => dac;
0.2 => dac.gain;

while(true) {
    for(int i; i < samples.size(); i++) {
        samples[i] => feeder.next;
        1::samp => now;
    }
    
    1::ms => now;
}

