#include <Servo.h>
#include <AFMotor.h>

/*



*/

// FORWARD/BACKWARD is relative to how you wire the motors.  change these
// defines to make the motor go the right way and use 
// actualForward/actualBackward in the code
#define actualForward FORWARD
#define actualBackward BACKWARD

AF_DCMotor driveMotor1(3);
AF_DCMotor driveMotor2(4);

Servo steeringServo;

// motor speed - 255=flat out
int speed = 225;

// timeout for reversing to avoid an object
unsigned long timeout = 0;

int leftSensor = 2;
int rightSensor = 1;

int switch1 = A3;
int switch2 = A4;

unsigned t = 0;
int dir;


void setup() {
  
  pinMode(switch1, OUTPUT);
  pinMode(switch2, OUTPUT);

  // connect the servos
  steeringServo.attach(9);
  turn(0);
 
  driveMotor1.setSpeed(speed); 
  driveMotor2.setSpeed(speed);
  
  driveMotor1.run(RELEASE);
  driveMotor2.run(RELEASE);

  delay(5000);
  
  goFwd();
  
  Serial.begin(9600);

}



void loop() {

  int left = analogRead(leftSensor);
  int right =  analogRead(rightSensor);
  
  int sw1 = digitalRead(switch1);
  int sw2 = digitalRead(switch2);
  
  Serial.print(left);
  Serial.print(" ");
  Serial.println(right);
  
  // if moderately
  if ((left > 425 || right > 425) || (left > 325 && right > 325) || (sw1 == 1 || sw2 == 1) ) {
    
    // back up and turn  
    if (millis() - t > 2500) {
    
      if (left+50 > right)
        dir = -25;
      else
        dir = 25;
 
    }
    
    t = millis();
    
    turn(dir); 
    goBack();
    
    delay(350);
    
    
  } else if (left > 225 && right < 225) {
    
    // turn right
    turn(-20);
    goFwd();
    delay(150);
  
  } else if (right > 225 && left < 225) {

    // turn left
    turn(20);
    goFwd();
    delay(150);
    
  } else {
    
    turn(0);
    goFwd();
    
  }

  delay(50);

}




void goFwd() {
  
  Serial.println("fwd");
  
  driveMotor1.setSpeed(speed);
  driveMotor1.run(actualBackward);
  
  driveMotor2.setSpeed(speed);
  driveMotor2.run(actualForward);  
}  



void goBack() {
  
  Serial.println("back");
  
  driveMotor1.setSpeed(speed);
  driveMotor1.run(actualForward);
  
  driveMotor2.setSpeed(speed);
  driveMotor2.run(actualBackward);  
}  




void turn(int angle) {
  
  // convert turn to servo angle. -ve = turn left
  steeringServo.write(angle + 90); 
}
