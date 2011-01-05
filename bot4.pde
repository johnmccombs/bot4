/*

  This is a self-navigating robot.  It's driven by two DC motors,
  which both drive in the same direction.  Steering is by turning a
  servo, connected to the front wheels.  Object detection uses
  two forward facing Sharp GP2Y0A02YK0F infra-red distance measuring sensors.
  These are postioned pointing slightly outward on the front.  Two microswitches
  attached to a bumper, on the front, detect collisions with objects the 
  IR sensors miss.
  
  If the IR or collision sensor detects something within range, it backs up
  and turns
  
  The motors are controlled by an adafruit.com motorshield.

--
Copyright (C) 2010 by Integrated Mapping Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

#include <Servo.h>
#include <AFMotor.h>


// FORWARD/BACKWARD is relative to how you wire the motors.  change these
// defines to make the motor go the right way and use 
// actualForward/actualBackward in the code
#define actualForward FORWARD
#define actualBackward BACKWARD

// two DC motors connected to M3 and M4 on the motorshield
AF_DCMotor driveMotor1(3);
AF_DCMotor driveMotor2(4);

// object to control the steering servo
Servo steeringServo;

// motor speed - 255=flat out.  DC motors generally don't
// have enough power to move below 50-70
int speed = 225;

// timeout for reversing to avoid an object
unsigned long t = 0;

// connect the Sharp IR sensors to analog pins 1 & 2
int leftSensor = 2;
int rightSensor = 1;

// the collision switches are connected to analog 3 & 4, with the 
// other leads for the switches connected to 5V.  The should probably
// have pull-down resistors, but they work ok without them
int switch1 = A3;
int switch2 = A4;

// direction to turn - angle in degrees, +/- for right/left
int dir;


/*-----------------------------------------------------------------*/
void setup() {
  
  // connect to the servo and set to straight ahead
  steeringServo.attach(9);
  turn(0);
 
  // set DC motor speed
  driveMotor1.setSpeed(speed); 
  driveMotor2.setSpeed(speed);
  
  // set motors to not running
  driveMotor1.run(RELEASE);
  driveMotor2.run(RELEASE);

  // wait 5 sec to give the driver a chance to put the robot down
  // after connecting power
  delay(5000);
  
  // off we go
  goFwd();
  
}


/*-----------------------------------------------------------------*/
void loop() {

  // read the IR sensors
  int left = analogRead(leftSensor);
  int right =  analogRead(rightSensor);
  
  // read the collision switches
  int sw1 = digitalRead(switch1);
  int sw2 = digitalRead(switch2);
  
  // do we need to back up?  really close on either side OR moderately close on 
  // both sides OR either collision switch activated
  if ((left > 425 || right > 425) || (left > 325 && right > 325) || (sw1 == 1 || sw2 == 1) ) {
    
    // pick a direction to turn for the backup.  this if test ensure it
    // keeps turns the same way for 2.5 seconds, before it can make another choice  
    if (millis() - t > 2500) {
    
      // decide based on which IR sensor reports closer.
      if (left+50 > right)
        dir = -25;
      else
        dir = 25;
 
    }
    
    // reset the timer
    t = millis();
    
    // turn the steering and reverse the motor
    turn(dir); 
    goBack();
    
    // drive back for 350 millisec
    delay(350);
    
    
  } else if (left > 225 && right < 225) {
    
    // obstruction on the left - turn right
    turn(-20);
    goFwd();
    delay(150);
  
  } else if (right > 225 && left < 225) {

    // obstruction in the right - turn left
    turn(20);
    goFwd();
    delay(150);
    
  } else {
    
    // all clear from the sensors - straight ahead
    turn(0);
    goFwd();
    
  }

  delay(20);

}



/*-----------------------------------------------------------------*/
void goFwd() {
  
  // set the speed and set the direction fwd.  note the
  // the motors are driven in opposite directions as the
  // are on opposite sides of the vehicle
  
  driveMotor1.setSpeed(speed);
  driveMotor1.run(actualBackward);
  
  driveMotor2.setSpeed(speed);
  driveMotor2.run(actualForward);  
}  


/*-----------------------------------------------------------------*/
void goBack() {

  // set the speed and set the direction back.  note the
  // the motors are driven in opposite directions as the
  // are on opposite sides of the vehicle
  
  driveMotor1.setSpeed(speed);
  driveMotor1.run(actualForward);
  
  driveMotor2.setSpeed(speed);
  driveMotor2.run(actualBackward);
  
}  



/*-----------------------------------------------------------------*/
void turn(int angle) {
  
  // convert turn to servo angle. the servo expects a value of 0-180. 90
  // being centred
  //
  // -ve = turn left
  
 
  steeringServo.write(angle + 90); 
  
}
