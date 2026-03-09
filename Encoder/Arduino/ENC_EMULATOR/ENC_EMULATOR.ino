#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// ================= OLED =================
Adafruit_SSD1306 display(128,64,&Wire,-1);

// ================= PIN =================
#define BTN_UP     2
#define BTN_DOWN   3
#define BTN_START  4
#define BTN_DIR    5
#define BTN_ZERO   6

#define PIN_OC1A   9
#define PIN_OC1B   10

#define PIN_ZERO   7
#define PIN_RESET  8

// ================= PARAMETERS =================
uint32_t frequency = 2;
bool directionForward = true;

const uint16_t debounceTime = 20;

// ================= SYSTEM STATE =================
enum RunState {STOPPED, RESETTING, RUNNING};
RunState runState = STOPPED;

uint32_t resetStartTime = 0;

// ================= ZERO =================
volatile bool triggerZero=false;
volatile uint32_t zeroOffTime=0;

bool zeroOnDisplay=false;
uint32_t zeroDisplayTimer=0;

// ================= BUTTON STRUCT =================
struct Button{
  uint8_t pin;
  bool lastState;
  uint32_t pressTime;
  uint32_t lastRepeat;
  bool shortHandled;
};

Button btnUp   ={BTN_UP,HIGH,0,0,false};
Button btnDown ={BTN_DOWN,HIGH,0,0,false};
// ================= DEBOUNCE VAR =================
bool dirState=HIGH;
bool lastDirReading=HIGH;
uint32_t lastDirDebounce=0;

bool startState=HIGH;
bool lastStartReading=HIGH;
uint32_t lastStartDebounce=0;

bool zeroState=HIGH;
bool lastZeroReading=HIGH;
uint32_t lastZeroDebounce=0;

// ================= TIMER =================
void stopTimer()
{
  TCCR1A=0;
  TCCR1B=0;
}

void setupTimer1(uint32_t freq)
{
  TCCR1A=0;
  TCCR1B=0;

  pinMode(PIN_OC1A,OUTPUT);
  pinMode(PIN_OC1B,OUTPUT);

  if(directionForward)
      TCCR1A|=(1<<COM1A0);
  else
      TCCR1A|=(1<<COM1B0);

  TCCR1B|=(1<<WGM12);

  uint32_t prescaler;
  uint16_t bits;

  if(freq>=2000){prescaler=1;bits=(1<<CS10);}
  else if(freq>=200){prescaler=8;bits=(1<<CS11);}
  else if(freq>=30){prescaler=64;bits=(1<<CS11)|(1<<CS10);}
  else if(freq>=4){prescaler=256;bits=(1<<CS12);}
  else {prescaler=1024;bits=(1<<CS12)|(1<<CS10);}

  uint32_t ocr=(16000000UL/(2UL*prescaler*freq))-1;

  OCR1A=ocr;
  OCR1B=ocr;

  TIMSK1=(1<<OCIE1A);

  TCCR1B|=bits;
}

// ================= TIMER ISR =================
ISR(TIMER1_COMPA_vect)
{
  if(triggerZero)
  {
    digitalWrite(PIN_ZERO,HIGH);

    zeroOffTime=micros()+(500000UL/frequency);

    triggerZero=false;
  }

  if(zeroOffTime && micros()>=zeroOffTime)
  {
    digitalWrite(PIN_ZERO,LOW);
    zeroOffTime=0;
  }
}

// ================= DISPLAY =================
void drawUI()
{
  display.clearDisplay();

  display.drawRect(0,2,128,62,SSD1306_WHITE);

  display.setTextSize(1);

  int16_t x1,y1;uint16_t w,h;
  display.getTextBounds("ENCODER-EMU",0,0,&x1,&y1,&w,&h);

  display.fillRect((128-w)/2-2,0,w+4,h,SSD1306_BLACK);

  display.setCursor((128-w)/2,0);
  display.print("ENCODER-EMU");

  display.setCursor(4,18);
  display.print("Freq:");
  display.print(frequency);
  display.print("Hz");

  display.setCursor(4,32);
  display.print("Dir:");
  display.print(directionForward?"Forward":"Backward");

  display.setCursor(4,46);
  display.print("State:");
  display.print(runState==RUNNING?"RUN":"STOP");

  display.setCursor(80,46);
  display.print("Z:");
  display.print(zeroOnDisplay?"ON":"OFF");

  display.display();
}

// ================= STEP =================
uint16_t stepValue(uint32_t t)
{
  if(t<500)return 1;
  else if(t<1500)return 10;
  else if(t<3000)return 100;
  else return 1000;
}

// ================= FREQ BUTTON =================
void handleFreqButton(Button &b,bool increase)
{
  bool state=digitalRead(b.pin);

  if(state==LOW && b.lastState==HIGH)
  {
    b.pressTime=millis();
    b.lastRepeat=millis();
    b.shortHandled=false;
  }

  if(state==LOW)
  {
    uint32_t t=millis()-b.pressTime;

    if(t<500 && !b.shortHandled)
    {
      if(increase)frequency++;
      else if(frequency>1)frequency--;

      b.shortHandled=true;
    }

    else if(t>=500)
    {
      if(millis()-b.lastRepeat>500)
      {
        uint16_t step=stepValue(t);

        if(increase)frequency+=step;
        else if(frequency>step)frequency-=step;

        if(frequency>10000)frequency=10000;

        b.lastRepeat=millis();
      }
    }

    if(runState==RUNNING)
      setupTimer1(frequency);
  }

  b.lastState=state;
}

// ================= DIR BUTTON =================
void handleDirButton()
{
  bool reading=digitalRead(BTN_DIR);

  if(reading!=lastDirReading)
    lastDirDebounce=millis();

  if(millis()-lastDirDebounce>debounceTime)
  {
    if(reading!=dirState)
    {
      dirState=reading;

      if(dirState==LOW)
      {
        directionForward=!directionForward;

        if(runState==RUNNING)
          setupTimer1(frequency);
      }
    }
  }

  lastDirReading=reading;
}

// ================= ZERO BUTTON =================
void handleZeroButton()
{
  bool reading=digitalRead(BTN_ZERO);

  if(reading!=lastZeroReading)
    lastZeroDebounce=millis();

  if(millis()-lastZeroDebounce>debounceTime)
  {
    if(reading!=zeroState)
    {
      zeroState=reading;

      if(zeroState==LOW)
      {
        triggerZero=true;

        zeroOnDisplay=true;
        zeroDisplayTimer=millis();
      }
    }
  }

  lastZeroReading=reading;

  if(zeroOnDisplay)
  {
    if(!digitalRead(PIN_ZERO) && millis()-zeroDisplayTimer>=500)
      zeroOnDisplay=false;
  }
}

// ================= START BUTTON =================
void handleStartButton()
{
  bool reading=digitalRead(BTN_START);

  if(reading!=lastStartReading)
    lastStartDebounce=millis();

  if(millis()-lastStartDebounce>debounceTime)
  {
    if(reading!=startState)
    {
      startState=reading;

      if(startState==LOW)
      {
        if(runState==RUNNING)
        {
          stopTimer();
          runState=STOPPED;
        }
        else if(runState==STOPPED)
        {
          stopTimer();

          digitalWrite(PIN_RESET,HIGH);

          resetStartTime=millis();

          runState=RESETTING;
        }
      }
    }
  }

  lastStartReading=reading;
}

// ================= RESET SEQUENCE =================
void handleResetSequence()
{
  if(runState==RESETTING)
  {
    if(millis()-resetStartTime>=100)
    {
      digitalWrite(PIN_RESET,LOW);

      setupTimer1(frequency);

      runState=RUNNING;
    }
  }
}

// ================= SETUP =================
void setup()
{
  pinMode(BTN_UP,INPUT_PULLUP);
  pinMode(BTN_DOWN,INPUT_PULLUP);
  pinMode(BTN_START,INPUT_PULLUP);
  pinMode(BTN_DIR,INPUT_PULLUP);
  pinMode(BTN_ZERO,INPUT_PULLUP);

  pinMode(PIN_ZERO,OUTPUT);
  pinMode(PIN_RESET,OUTPUT);

  digitalWrite(PIN_ZERO,LOW);

  display.begin(SSD1306_SWITCHCAPVCC,0x3C);
  display.setTextColor(SSD1306_WHITE);

  digitalWrite(PIN_RESET,HIGH);
  delay(100);
  digitalWrite(PIN_RESET,LOW);

  drawUI();
}

// ================= LOOP =================
void loop()
{
  handleFreqButton(btnUp,true);
  handleFreqButton(btnDown,false);

  handleDirButton();
  handleZeroButton();
  handleStartButton();

  handleResetSequence();

  drawUI();
}
