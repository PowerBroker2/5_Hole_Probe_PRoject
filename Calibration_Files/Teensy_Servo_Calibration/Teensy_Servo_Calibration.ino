#include <Servo.h>



#define AOA

#define AOA_PIN 23    //angle of attack servo signal pin
#define SSA_PIN 22    //side slip angle servo signal pin



Servo servo_AOA;
Servo servo_SSA;



void setup()
{
  Serial.begin(115200);

  pinMode(13,OUTPUT);
  digitalWrite(13,HIGH);

  servo_AOA.attach(AOA_PIN);
  servo_AOA.write(90);

  servo_SSA.attach(SSA_PIN);
  servo_SSA.write(90);
}

void loop()
{
  if(Serial.available())
  {
    #ifdef AOA
    servo_AOA.write(Serial.read());
    #else
    servo_SSA.write(Serial.read());
    #endif
  }
}


















