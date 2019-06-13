#include <SD.h>
#include <SPI.h>
#include <Servo.h>



#define WIND_TUNNEL   //comment out for flight testing

#define NUM_SENSORS 5 //number of pressure sensors
#define AOA_PIN 23    //angle of attack servo signal pin
#define SSA_PIN 22    //side slip angle servo signal pin
#define WAIT_TIME 900 //number of 10 ms between servo position adjustments
#define AOA_MAX 115   //AOA servo max angle
#define AOA_MIN 65    //AOA servo min angle
#define SSA_MAX 115   //SSA servo max angle
#define SSA_MIN 65    //SSA servo min angle
#define AOA_INCREM 5  //AOA servo angle increment
#define SSA_INCREM 5  //SSA servo angle increment



Servo servoaoa;       //angle of attack servo
Servo servossa;       //side slip angle servo

File root;
File dataFile;

unsigned long timeStamp = 0;
unsigned long currentTime = millis();
unsigned long timeBench = 0;
unsigned long timePeriod = 10;
unsigned long stepIndex = 0;

byte aoa = AOA_MIN;   //angle of attack servo position
byte ssa = SSA_MIN;   //side slip angle servo position
unsigned int timeIndex = 0;



void setup()
{
  //set ADC resolution to 16 bits
  analogReadResolution(16);

  //turn on debug LED
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);

#ifndef WIND_TUNNEL
  //see if the card is present and can be initialized:
  if (!SD.begin(BUILTIN_SDCARD))
  {
    //don't do anything more:
    return;
  }
#else
  //attach servos
  servoaoa.attach(AOA_PIN);
  servossa.attach(SSA_PIN);

  servoaoa.write(AOA_MIN);
  servossa.write(SSA_MIN);

  Serial.begin(115200);

  while (!Serial);

  /*Serial.print(aoa);
  Serial.print(" ");
  Serial.println(ssa);*/

  printData();
#endif
}



void loop()
{
#ifndef WIND_TUNNEL
  logData();
#else
  currentTime = millis();
  if (currentTime - timeBench >= timePeriod)
  {
    timeBench = currentTime;
    servoControl();
    printData();
  }
#endif
}



void logData()
{
  // make an int array for the data:
  int rawPressure[NUM_SENSORS];

  // index counter
  byte i = 0;

  while (i < NUM_SENSORS)
  {
    rawPressure[i] = analogRead(i);
    i = i + 1;
  }
  i = 0;

  // open file
  dataFile = SD.open("datalog.txt", FILE_WRITE);

  // if the file is available, write to it:
  if (dataFile)
  {
    while (i < NUM_SENSORS)
    {
      dataFile.println(rawPressure[i]);
      i = i + 1;
    }
    timeStamp = micros();
    dataFile.println(timeStamp);
  }
  else
  {
    //do nothing
  }
  
  dataFile.close(); //close file

  return;
}



void printData()
{
  // index counter
  byte i = 0;

  while (i < NUM_SENSORS)
  {
    Serial.print(analogRead(i));
    Serial.print(" ");
    i = i + 1;
  }
  i = 0;

  Serial.print(aoa);
  Serial.print(" ");
  Serial.print(ssa);
  Serial.println();

  return;
}



void servoControl()
{
  timeIndex = timeIndex + 1;

  if (timeIndex == WAIT_TIME)
  {
    timeIndex = 0;

    if (ssa < SSA_MAX)
    {
      ssa = ssa + SSA_INCREM;
    }
    else
    {
      ssa = SSA_MIN;

      if(aoa < AOA_MAX)
      {
        aoa = aoa + AOA_INCREM;
      }
      else
      {
        //aoa = AOA_MIN;
        while(1); //HALT
      }
    }

    //update servo position
    servoaoa.write(aoa);
    servossa.write(ssa);

    /*Serial.print(aoa);
    Serial.print(" ");
    Serial.println(ssa);*/
  }

  return;
}





