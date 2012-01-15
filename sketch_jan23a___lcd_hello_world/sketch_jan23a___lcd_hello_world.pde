#include <LiquidCrystal.h>

// these constants won't change.  But you can change the size of
 // your LCD using them:
 const int numRows = 4;
 const int numCols = 20;
 // initialize the library with the numbers of the interface pins
 LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
 void setup() {
   // set up the LCD's number of rows and columns: 
   lcd.begin(numRows, numCols);
 }
 void loop() {
   // loop from ASCII 'a' to ASCII 'z':
   for (int thisLetter = 'a'; thisLetter <= 'z'; thisLetter++) {
     // loop over the rows:
     for (int thisRow= 0; thisRow < numRows; thisRow++) {
       // loop over the columns:
       for (int thisCol = 0; thisCol < numCols; thisCol++) {
         // set the cursor position:
         lcd.setCursor(thisCol,thisRow);
         // print the letter:
         lcd.print(thisLetter, BYTE);
         delay(100);
       }
     }
   }
 }
