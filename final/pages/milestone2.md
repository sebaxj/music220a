# Final Project - Sebastian James | Music 220A | Spring 2021  

## Milestone 2:  
### My Final Project: Using **frame differentiation** on **video input in Processing** and piping the measure of difference to **ChucK over OSC** to generate **audio with corresponding density**  
#
In the `/final/` repository, run `sh make.sh` to to execute program. 
#
### Processing side:  
As of now, I am determining the best algorithm to process video using frame differentiation. Below I have included screenshots of the two algorithms I am toying with. In one, red contours are used to visualize the motion that the program interprets against a background. This is known as **background subtraction**. This is built upon the OpenCV library for Processing using image subtraction and filtering (blur, gray-scale) to mitigate noise. 

The second algorithm uses pure **frame differentiation** using a mask of the prev movie frame over the current frame and displaying the result in gray-scale.  

In both instances, the program outputs an integer *frame difference variable* as the scale of variability between frames. It is from this value that I am going to build a *level of motion density* variable which will be sent to ChucK over OSC.  

Background Subtraction with OpenCV Example:  
![alt text](../assets/background_sub_pic.png "Background Subtraction with OpenCV")  
Frame Differentiation without OpenCV Example:  
![alt text](../assets/framdiff_pic.png "Frame Differentiation without OpenCV")  
[Background Subtraction with OpenCV Code](../lib/BackgroundSubtraction/BackgroundSubtraction.pde)  
[Frame Differentiation without OpenCV Code](../lib/FrameDiff/FrameDiff.pde)    
#
### OSC server communication: 
[Processing OSC Broadcast Server Code](../lib/oscp5_broadcast/oscp5_broadcast.pde)  
#
### ChucK side:  
ChucK receives an OSC message containing an integer which corresponds to the gain of the output sound.  
**TODO:**  
ChucK needs to sweep cleanly between *density* values which come with each OSC message.  
ChucK needs to output more, better sound.   
[ChucK OSC Receiver and Sound Generation Code](../lib/OSC_recv.ck)  