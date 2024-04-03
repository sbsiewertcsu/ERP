#include "Wire.h"
#include <Adafruit_NeoPixel.h>
#include <Adafruit_LIS3DH.h>
#include <Adafruit_Sensor.h>
#include <Ticker.h>
#define SECONDS_TO_MEASURE 30
#define S_TO_MS 1000
#define DATARATE_HZ 200


const float DELAY_TIME =  (float)1/(DATARATE_HZ) * S_TO_MS;
const uint64_t measurementTime = (uint64_t)(((float)SECONDS_TO_MEASURE * S_TO_MS) / DELAY_TIME);
const uint16_t data = 0xAAAA;
int on = 0;
uint64_t counter = 0;
Ticker flipper;
Adafruit_NeoPixel led(1, 8, NEO_GRB + NEO_KHZ800);
Adafruit_LIS3DH accel = Adafruit_LIS3DH();


void readAccel()
{
  digitalWrite(10,HIGH);
  accel.read();
  Serial.printf("Accel,%f,%f,%f\n",accel.x_g*9.806,accel.y_g*9.806,accel.z_g*9.806);  
  digitalWrite(10,LOW);
}

void setup() {
  pinMode(10,OUTPUT);
  digitalWrite(10,LOW);
  // put your setup code here, to run once:
  Serial.begin(500000);
  while (!Serial) delay(10);
  led.begin();
  led.setPixelColor(0,led.Color(32,0,0));
  led.setBrightness(25);
  led.show();
  Wire.setPins(5,4);
  Wire.begin();
  accel.begin(0x18);
  accel.setDataRate(LIS3DH_DATARATE_200_HZ);
  accel.setRange(LIS3DH_RANGE_2_G);
  flipper.attach((float)1/200,readAccel);
}


void loop() {
  
  // put your main code here, to run repeatedly

}
