/*
 * This sketch recieves distance values from a LIDAR-Lite Sensor, converts these values
 * to velocities, and outputs these values to the serial monitor.
 *
 * It utilizes the 'Arduino I2C Master Library' from DSS Circuits.
 * Also see: https://github.com/PulsedLight3D/LIDARLite_Basics
 */

#include <I2C.h>                             // For I2C communication with the LIDAR
#include "StructDefs.h"                      // For definition of struct type
#define    LIDARLite_ADDRESS   0x62          // Default I2C Address of LIDAR-Lite.
#define    RegisterMeasure     0x00          // Register to write to initiate ranging.
#define    MeasureValue        0x04          // Value to initiate ranging.
#define    RegisterHighLowB    0x8f          // Register to get both High and Low bytes in 1 call.

unsigned long now_avg = 0; // For testing how long it takes to calculate one avg
unsigned long before_avg = 0; // For testing how long it takes to calculate one avg

int distNow = 0; // The current distance value.
unsigned long now = 0; // The current time -> when a distNow is measured.
int distPrev = 9999999; // The previous distance value measured.
unsigned long before = 0; // The previous time a distance value was measured.
unsigned long elapsed = 0; // The time elapsed between measuring distPrev and distNow.
float totalVel = 0; // The last couple velocity values combined (used to take an average)
float totalDist = 0; // The last couple distance values combined (used to take an average)
int counter = 0; // Counter for taking averages
const short AVG_COUNT = 5; // Number of data points that are averaged each loop

const int motorPinLeft = 5; // PWM pin for the left motor
const int motorPinRight = 6; // PWM pin for the right motor
// Map the motorPin from PWM_MIN (when the motor just starts to spin) to PWM_MAX (255)
const int PWM_MIN = 108; // The lowest possible number sent to the motorPins (motor doesn't spin here)
const int PWM_MAX = 255; // The highest possible number sent to the motorPins
const float VEL_MIN = 0.3; // The lowest possible velocity required to send voltage to the motorPin
const float VEL_MAX = 10; // The velocity that maxes out the voltage sent to the motorPin

const int ultraPinRight = 3; // interrupt input for the right ultrasonic -> int.0
const int LEDPinRight = 7; // PW output for the right LED
const int ultraPinLeft = 2; // interrupt input for the left ultrasonic -> int.1
const int LEDPinLeft = 4; // PW output for the left LED
#define MIN_ULTRA_DIST 12.7 // The minimum distance in cm to light the LED to its max
#define MAX_ULTRA_DIST 100.0 // The minimum distance in cm to just light the LED

ultra_state_t rightUltra; // The state of the right ultrasonic sensor
ultra_state_t leftUltra; // The state of the left ultrasonic sensor

void setup() {
  Serial.begin(9600); // Open serial connection at 9600bps
  pinMode(LEDPinRight, OUTPUT);
  pinMode(LEDPinLeft, OUTPUT);
  I2c.begin(); // Open & join the irc bus as master
  delay(100); // Wait to make sure everything is powered up before sending or receiving data
  I2c.timeOut(50); // Set a timeout to ensure no locking up of sketch if I2C communication fails
  analogWrite(motorPinLeft, 0); // Set the motors to not spin
  analogWrite(motorPinRight, 0); // Set the motors to not spin
  attachInterrupt(ultraPinRight - 2, rightInterrupt, CHANGE); // For reading the ultrasonics w/o pausing the code
  attachInterrupt(ultraPinLeft - 2, leftInterrupt, CHANGE); // An interrupt is called every time the left/right
  // ultrasonic has a change in state (rising/falling edge -> 1/0)
}

/* ----------------------------------------------------
 * ----------------------- MAIN -----------------------
 * ---------------------------------------------------- */
void loop() {
  //---------- GET DISTANCE ---------//
  // Write 0x04 to register 0x00
  uint8_t nackack = 100; // Setup variable to hold ACK/NACK resopnses
  while (nackack != 0) { // While NACK keep going (i.e. continue polling until sucess message (ACK) is received )
    nackack = I2c.write(LIDARLite_ADDRESS, RegisterMeasure, MeasureValue); // Write 0x04 to 0x00
    // (I2c.write() returns 0 when successful write)
    delay(1); // Wait 1 ms to prevent overpolling
  }

  byte distanceArray[2]; // array to store distance bytes from read function

  // Read 2byte distance from register 0x8f
  nackack = 100; // Setup variable to hold ACK/NACK resopnses
  while (nackack != 0) { // While NACK keep going (i.e. continue polling until sucess message (ACK) is received )
    nackack = I2c.read(LIDARLite_ADDRESS, RegisterHighLowB, 2, distanceArray); // Read 2 Bytes from LIDAR-Lite Address and store in array
    delay(1); // Wait 1 ms to prevent overpolling
  }
  // Convert bytes to distance values:
  distNow = (distanceArray[0] << 8) + distanceArray[1];  // Shift high byte [0] 8 to the left and add low byte [1] to create 16-bit int
  now = millis(); // The time that distNow was measured.


  //---------- CALCULATE AVERAGE VELOCITY & DISTANCE ----------//
  elapsed = now - before; // Time elapsed between previous read (distPrev) and this read (distNow) -- for velocity calculation
  // Calculate velocity and add it to totalVel:
  totalVel += (((float)(distPrev - distNow)) / ((float)elapsed)) * 10; // Multiply by 10 b/c 1 cm/ms = 10 m/s
  // Note: If the velocity is POSITIVE, then something is coming closer from behind (if negative, then something's moving away)
  totalDist += distNow;
  counter++; // One more data point collected for each distance/velocity
  // if AVG_COUNT data points have been collected, take the average:
  if (counter >= AVG_COUNT) {
    float avgVel = takeAverage(totalVel, counter);
    totalVel = 0; // Reset totalVel for next average
    float avgDist = takeAverage(totalDist, counter);
    totalDist = 0; // Reset totalDist for next average
    // Print to serial to communicate with Processing:
    Serial.print(avgVel); Serial.print('V');
    Serial.print(avgDist); Serial.println('D');


    //---------- ADJUST MOTOR SPEED ----------//
    writeMotorSpeed (motorPinLeft, avgVel, avgDist);
    writeMotorSpeed (motorPinRight, avgVel, avgDist);

    counter = 0; // Reset the counter for taking averages
    before_avg = now_avg; // Update the previous time for the next loop
    now_avg = millis(); // Update the current time
  }

  //---------- CALCULATE LIDAR DISTANCES ----------//
  if (rightUltra.newDt) {
    pulseCalc(&rightUltra, LEDPinRight);
  }
  if (leftUltra.newDt) {
    pulseCalc(&leftUltra, LEDPinLeft);
  }

  //---------- UPDATE VALUES FOR NEXT LOOP ----------//
  before = now;
  distPrev = distNow;

  delay(10);
}

/* ----------------------------------------------------
 * ------------------ HELPER METHODS ------------------
 * ---------------------------------------------------- */

/* Takes the average given the total and a counter */
float takeAverage (float total, int counter) {
  return total / ((float)counter);
}

/* Changes the motor speed based on velocity and distance according to a fuzzy logic
 * approximation function. */
void writeMotorSpeed (int motorPin, float velocity, float distance) {
  if (velocity < VEL_MIN) { // Velocity less than the minimum
    analogWrite(motorPin, 0); // Bottomed out
  } else if (velocity > VEL_MAX) { // Velocity more than the maximum
    analogWrite(motorPin, 255); // Maxed out
  } else {
    // Within range, write fuzzy function:
    float fuzz = (sin(velocity / 20.0 * PI) - sin(distance / 80.0 * PI) + 1.0) * 77.5 + 100.0;
    analogWrite(motorPin, fuzz);
  }
}

/* Calculates distance for the ultrasonics based on pulse length */
void pulseCalc (ultra_state_t *ultra, int ledPin) {
  // Calculate the distance in centimeters:
  ultra->distance = ultra->dt / 147.0 * 2.54; // Convert to cm: pulse/147*2.54 = cm

  //Add the distance to the total distance and then average if needed
  ultra->totalDist += ultra->distance;
  ultra->counter++; // Another distance was calculated

  if (ultra->counter >= AVG_COUNT) {
    // Change the LED intensity:
    writeLED(ledPin, takeAverage(ultra->totalDist, ultra->counter));
    // Reset the counter and total distance for the next average:
    ultra->counter = 0;
    ultra->totalDist = 0;
  }

  // Update pulse flag (no new pulse time value):
  ultra->newDt = 0;
}

/* When the right ultrasonic starts/finishes a pulse, this method will be called */
void rightInterrupt() {
  // If the pulse is high, then save the start time:
  if (digitalRead(ultraPinRight) > 0 && rightUltra.pulseStarted == 0) {
    rightUltra.startTime = micros();
    rightUltra.pulseStarted = 1;
  }
  // If the pulse finishes:
  else if (rightUltra.pulseStarted) {
    // Get the total pulse time:
    rightUltra.dt = micros() - rightUltra.startTime;

    // Clear the flags (pulse hasn't started any more & new pulse time ready):
    rightUltra.pulseStarted = 0;
    rightUltra.newDt = 1;
  }
}

/* When the left ultrasonic starts/finishes a pulse, this method will be called */
void leftInterrupt() {
  // If the pulse is high, then save the start time:
  if (digitalRead(ultraPinLeft) > 0 && leftUltra.pulseStarted == 0) {
    leftUltra.startTime = micros();
    leftUltra.pulseStarted = 1;
  }
  // If the pulse finishes:
  else if (leftUltra.pulseStarted) {
    // Get the total pulse time:
    leftUltra.dt = micros() - leftUltra.startTime;

    // Clear the flags (pulse hasn't started any more & new pulse time ready):
    leftUltra.pulseStarted = 0;
    leftUltra.newDt = 1;
  }
}

/* Changes the intensity of the LED based on the distance provided */
void writeLED (int ledPin, float dist) {
  if (dist < (MIN_ULTRA_DIST + MAX_ULTRA_DIST) / 2)
    digitalWrite(ledPin, HIGH);
  else
    digitalWrite(ledPin, LOW);

  /*
  if (dist <= MIN_ULTRA_DIST) {
    // If very close, light the LED to its maximum
    analogWrite(ledPin, 255);
  } else if (dist >= MAX_ULTRA_DIST) {
    // If far away, don't light the LED
    analogWrite(ledPin, 0);
  } else {
    // If in between max & min distance, map the light intensity
    // between 0 and 150 (difficult to see difference between
    // 150<->255, thus the gradient is better between 0<->150)
    analogWrite(ledPin, map(dist, MIN_ULTRA_DIST, MAX_ULTRA_DIST, 150, 0));
  }
  */
}

