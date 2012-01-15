
//#include <Servo.h>
#include <LiquidCrystal.h>
#include <OneWire.h>
#include <DallasTemperature.h>



// initialize the library with the numbers of the interface pins
#include "WProgram.h"
void setup();
void loop();
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

int tempPin = 0; 
OneWire ds(8);
DallasTemperature sensors(&ds);
int lightPin = 10;

int level = 255;


void setup(){
    // set up the LCD's number of rows and columns: 
    lcd.begin(20, 4);
    sensors.begin();
    pinMode(lightPin,OUTPUT);
    analogWrite(lightPin,level);
}


void loop()
{


    // Get the digital temp
    sensors.requestTemperatures();


    lcd.clear();

    lcd.print("Temp (0): ");
    lcd.print( sensors.getTempFByIndex(0));
    lcd.setCursor(0,1);
    lcd.print("Temp (1): ");
    lcd.print( sensors.getTempFByIndex(1) ); 
    delay(1000);


}




int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

