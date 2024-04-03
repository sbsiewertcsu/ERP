#include <Adafruit_NeoPixel.h>
#include <SPI.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/timers.h"
#include "freertos/event_groups.h"
#include "sdkconfig.h"
#include "esp_system.h"

#define SECONDS_TO_MEASURE 16
#define S_TO_MS 1000
#define DATARATE_HZ 8000
#define BUFFER_SIZE DATARATE_HZ * SECONDS_TO_MEASURE
// const float DELAY_TIME =  (float)1/(DATARATE_HZ) * S_TO_MS;
// const uint64_t measurementTime = (uint64_t)(((float)SECONDS_TO_MEASURE * S_TO_MS) / DELAY_TIME);
const uint16_t data = 0xAAAA;
int on = 0;
uint64_t counter = 0;
uint16_t adcValue = 0;
// Ticker flipper;
static SemaphoreHandle_t mutex;
uint16_t samples[BUFFER_SIZE] = {0};
union {
  uint8_t bytes[2];
  uint16_t word;
} ADC_DATA;
static portMUX_TYPE my_spinlock = portMUX_INITIALIZER_UNLOCKED;
// uint8_t buf[3] = {0x55,0,0xAA};
Adafruit_NeoPixel led(1, 8, NEO_GRB + NEO_KHZ800);
uint32_t sampleCounter = 0;
TaskHandle_t xHandle = NULL;
hw_timer_t *Timer1_Cfg = NULL;

void IRAM_ATTR Timer1_ISR()
{
  if (sampleCounter < BUFFER_SIZE)
  {
    digitalWrite(4,HIGH);
    SPI.beginTransaction(SPISettings(8000000, MSBFIRST, SPI_MODE0));
    digitalWrite(3,LOW);
    ADC_DATA.word = SPI.transfer16(data);
    digitalWrite(3,HIGH);
    SPI.endTransaction(); 
    ADC_DATA.word >>= 2;
    ADC_DATA.word &= 0xFFF;
    samples[sampleCounter] = ADC_DATA.word;
    sampleCounter++;
    digitalWrite(4,LOW);
  }
}

void sendData(void* param)
{
  while(1)
  {

    vTaskDelay(SECONDS_TO_MEASURE * S_TO_MS/portTICK_PERIOD_MS);
    timerStop(Timer1_Cfg);
    timerAlarmDisable(Timer1_Cfg);
    timerWrite(Timer1_Cfg,0);
    // digitalWrite(4,HIGH);
    while(xSemaphoreTakeRecursive(mutex, portMAX_DELAY) != pdTRUE)
    {
        vTaskDelay(1/portTICK_PERIOD_MS);
    }
    // taskENTER_CRITICAL(&my_spinlock);
    

    led.setBrightness(25);
    led.setPixelColor(0,led.Color(32,0,0));
    led.show();
    // uint8_t lsb;
    // uint8_t msb;
    // for (sampleCounter = 0; sampleCounter < BUFFER_SIZE; sampleCounter++)
    // {
    //   lsb = samples[sampleCounter] & 0xFF;
    //   msb = samples[sampleCounter]>>8;

    //   Serial.write(&lsb,1);
    //   Serial.write(&msb,1);
    // }
    Serial.write((uint8_t*)&samples,sizeof(samples));
    // taskEXIT_CRITICAL(&my_spinlock);
    led.setBrightness(0);
    led.show();  
    xSemaphoreGiveRecursive(mutex);
    timerAlarmEnable(Timer1_Cfg);
    timerStart(Timer1_Cfg);
    sampleCounter = 0;
    // digitalWrite(4,LOW);
  }
  // vTaskDelay(1000/portTICK_PERIOD_MS);
}


void setup() {
  pinMode(3,OUTPUT);
  pinMode(4,OUTPUT);
  digitalWrite(4,LOW);
  digitalWrite(3,HIGH);
    led.begin();
 led.setPixelColor(0,led.Color(0,32,0));
  led.setBrightness(25);
  led.show();
  // put your setup code here, to run once:
  Serial.begin(921600);
  delay(50000);
  Serial.printf("start");
  led.setBrightness(0);
  led.show();
  setupADC();
  for (int i = 0; i < BUFFER_SIZE + 1; i++)
  {
    samples[i] = ',';
  }
  // for(int i = 0; i < BUFFER_SIZE; i++)
  // {
  //   if (i % 2 == 0)
  //   {
  //     samples[i] = 0xDEAD;
  //   }
  //   else
  //   {
  //     samples[i] = 0xBEEF;
  //   }
  // }
  mutex = xSemaphoreCreateMutex();
    Timer1_Cfg = timerBegin(0, 81, true);
    timerAttachInterrupt(Timer1_Cfg, &Timer1_ISR, true);
    timerAlarmWrite(Timer1_Cfg, 122, true);
    timerAlarmEnable(Timer1_Cfg);

  xTaskCreate( &sendData, "serial", 16384, NULL, 5, NULL); // assign all to core 1, WiFi in use.
}



void setupADC()
{
  SPI.begin(1,0,2,3); //setup SPI bus
} 


void loop() {
  // Serial.write((uint8_t*)&samples,(size_t)BUFFER_SIZE*2);
  // delay(0.01);
  // digitalWrite(10,HIGH);
  // digitalWrite(10,LOW);
  // Serial.write((uint8_t*)&samples,BUFFER_SIZE+1);
  // delay(10);
  
}


