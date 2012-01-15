
//#include <Servo.h>
#include <LiquidCrystal.h>
#include <OneWire.h>
#include <DallasTemperature.h>



// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(13, 12, 7,6,5, 4);

int tempPin = 0; 
OneWire ds(10);
DallasTemperature sensors(&ds);

volatile int target = 110;
int heat = 0;
int curtemp;
int downbtn = 2;
int upbtn = 3;

void setup(){
    // set up the LCD's number of rows and columns: 
    lcd.begin(20, 4);
    sensors.begin();
    pinMode(downbtn, INPUT);
    pinMode(upbtn, INPUT);
    attachInterrupt(0, tempdn, FALLING);
    attachInterrupt(1, tempup, FALLING);
}

void tempup() {
    target++;
    lcd.setCursor(13,0);
    lcd.print( target );    
    lcd.print( " ");
}

void tempdn() {
    target--;
    lcd.setCursor(13,0);
    lcd.print( target );    
    lcd.print( " ");
}

void loop()
{

    // check the button state, increase or decrease target as necessary
//    if ( digitalRead(upbtn) == LOW ) {
//        target++;
//    }
//    if ( digitalRead(downbtn) == LOW ) {
//        target--;
//    }
    

    // Get the digital temp
    sensors.requestTemperatures();
    
    if ( target > sensors.getTempFByIndex(0) ) {
        heat = 1;
    }
    else {
        heat = 0;
    }
    

    //lcd.clear();
    lcd.setCursor(0,0);
    lcd.print("Target temp: ");
    lcd.print( target );
    lcd.print( " ");
    lcd.setCursor(0,1);
    lcd.print("Current Temp: ");
    lcd.print( sensors.getTempFByIndex(0) );
    lcd.setCursor(0,2);
    lcd.print("Heat is ");
   if ( heat ) {
          lcd.print("on ");
   }
  else {
     lcd.print("off");
  } 
    delay(1000);


}



