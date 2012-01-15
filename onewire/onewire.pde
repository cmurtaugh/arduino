
#include <LiquidCrystal.h>
#include <OneWire.h>
#include <DallasTemperature.h>



// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
 
int tempPin = 0; 
OneWire ds(8);
DallasTemperature sensors(&ds);


 
void setup(){
     // set up the LCD's number of rows and columns: 
   lcd.begin(20, 4);
   //sensors.begin();
   
   // initialize the serial communications:
   Serial.begin(9600);
}

void loop()
{

  // Get the analog temp
  float temp = getVoltage(tempPin);
  // convert...
  temp = (((temp - .5) * 100 ) *1.8) +32;
    
  // Get the digital temp
  sensors.requestTemperatures();
  
  lcd.clear();
  
  lcd.print("Temp: ");
  lcd.print(temp);
  lcd.print(" F");
  
  lcd.setCursor(0,1);
  lcd.print("-------------------");
  lcd.setCursor(0,2);
  
  lcd.print("Temp (dig.): ");
  lcd.print(sensors.getTempCByIndex(0));
  delay(1000);
}


float getVoltage(int pin) {
  return (analogRead(pin) * .004882814);
}
