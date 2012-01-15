

/* Web_Demo.pde -- sample code for Webduino server library */

/*
 * To use this demo,  enter one of the following USLs into your browser.
 * Replace "host" with the IP address assigned to the Arduino.
 *
 * http://host/
 * http://host/json
 *
 * This URL brings up a display of the values READ on digital pins 0-9
 * and analog pins 0-5.  This is done with a call to defaultCmd.
 * 
 * 
 * http://host/form
 *
 * This URL also brings up a display of the values READ on digital pins 0-9
 * and analog pins 0-5.  But it's done as a form,  by the "formCmd" function,
 * and the digital pins are shown as radio buttons you can change.
 * When you click the "Submit" button,  it does a POST that sets the
 * digital pins,  re-reads them,  and re-displays the form.
 * 
 */

#include "SPI.h"
#include "Ethernet.h"
#include <max6675.h>
#include "WebServer.h"

#include <OneWire.h>
#define DS18S20_ID 0x10
#define DS18B20_ID 0x28
byte addr[8];

#define NAMELEN 32
#define VALUELEN 32

// no-cost stream operator as described at 
// http://sundial.org/arduino/?page_id=119
template<class T>
inline Print &operator <<(Print &obj, T arg)
{ 
    obj.print(arg); 
    return obj; 
}


// CHANGE THIS TO YOUR OWN UNIQUE VALUE
static uint8_t mac[] = { 
    0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

// CHANGE THIS TO MATCH YOUR HOST NETWORK
static uint8_t ip[] = { 
    192, 168, 101, 202 };

#define PREFIX ""

WebServer webserver(PREFIX, 80);



static int relayPin = 7;
static int ledPin = 8;
static int relay2Pin = 9;
static int owTempPin = 3;


// thermocouple stuff
//int thermoDO = 4;
//int thermoCS = 5;
//int thermoCLK = 6;
//MAX6675 thermocouple(thermoCLK, thermoCS, thermoDO);

//OneWire setup
OneWire ds(owTempPin);

long ledOnTime;
long relayOnTime;
long relay2OnTime;

long ledinterval = 5000;
long relayinterval = 300000;
long relay2interval = 300000;

// commands are functions that get called by the webserver framework
// they can read any posted data from client, and they output to server




void tempCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
    if (type == WebServer::POST)
    {
        server.httpFail();
        return;
    }

    //server.httpSuccess(false, "application/json");
    server.httpSuccess("application/json");

    if (type == WebServer::HEAD)
        return;

    outputStatus(server, "Got the temperature.");
}



void relayCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
    URLPARAM_RESULT rc;
    char name[NAMELEN];
    int  name_len;
    char value[VALUELEN];
    int value_len;
    String msg;
    if (strlen(url_tail)) 
    {
        rc = server.nextURLparam(&url_tail, name, NAMELEN, value, VALUELEN); 
        if ( rc != URLPARAM_EOS ) 
        {
            if ( strcmp(name, "cmd") ==0 ) 
            {
                if ( strcmp(value ,"on") ==0 ) {
                    if ( digitalRead( relayPin ) == HIGH ) {
                        msg = "Relay was already on.";
                    }
                    else {
                        digitalWrite(relayPin, HIGH);
                        relayOnTime = millis();
                        msg = "Turned the Relay on.";
                    }

                }
                else {
                    if ( digitalRead( relayPin ) == LOW ) {
                        msg = "Relay was already off.";
                    }
                    else {
                        digitalWrite(relayPin, LOW);
                        msg = "Turned the Relay off.";
                    }

                }
            } 
        } 
    }

    server.httpSuccess("application/json");

    if (type == WebServer::HEAD)
        return;

    outputStatus(server, msg);

}

void relay2Cmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
    URLPARAM_RESULT rc;
    char name[NAMELEN];
    int  name_len;
    char value[VALUELEN];
    int value_len;
    String msg;
    if (strlen(url_tail)) 
    {
        rc = server.nextURLparam(&url_tail, name, NAMELEN, value, VALUELEN); 
        if ( rc != URLPARAM_EOS ) 
        {
            if ( strcmp(name, "cmd") ==0 ) 
            {
                if ( strcmp(value ,"on") ==0 ) {
                    if ( digitalRead( relay2Pin ) == HIGH ) {
                        msg = "Relay was already on.";
                    }
                    else {
                        digitalWrite(relay2Pin, HIGH);
                        relay2OnTime = millis();
                        msg = "Turned the Relay on.";
                    }

                }
                else {
                    if ( digitalRead( relay2Pin ) == LOW ) {
                        msg = "Relay was already off.";
                    }
                    else {
                        digitalWrite(relay2Pin, LOW);
                        msg = "Turned the Relay off.";
                    }

                }
            } 
        } 
    }

    server.httpSuccess("application/json");

    if (type == WebServer::HEAD)
        return;

    outputStatus(server, msg);

}

void ledCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
    URLPARAM_RESULT rc;
    char name[NAMELEN];
    int  name_len;
    char value[VALUELEN];
    int value_len;
    String msg;
    if (strlen(url_tail)) 
    {
        rc = server.nextURLparam(&url_tail, name, NAMELEN, value, VALUELEN); 
        if ( rc != URLPARAM_EOS ) 
        {
            if ( strcmp(name, "cmd") ==0 ) 
            {
                if ( strcmp(value ,"on") ==0 ) {
                    if ( digitalRead( ledPin ) == HIGH ) {
                        msg = "LED was already on.";
                    }
                    else {
                        digitalWrite(ledPin, HIGH);
                        ledOnTime = millis();
                        msg = "Turned the LED on.";
                    }

                }
                else {
                    if ( digitalRead( ledPin ) == LOW ) {
                        msg = "LED was already off.";
                    }
                    else {
                        digitalWrite(ledPin, LOW);
                        msg = "Turned the LED off.";
                    }

                }
            } 
        } 
    }

    server.httpSuccess("application/json");

    if (type == WebServer::HEAD)
        return;

    outputStatus(server, msg);



}

void outputStatus(WebServer &server, String msg)
{
    // gather the data
    //String tempf = getTemp();
    String owtempf = getOwTemp();

    int ledVal = digitalRead(ledPin);
    int relayVal = digitalRead(relayPin);
    int relay2Val = digitalRead(relay2Pin);



    // output the json content
    server << "{ \"arduino\": { ";	
    //server << "\"temp\": \"" << tempf << "\", ";
    server << "\"owtemp\": \"" << owtempf << "\", ";
    server << "\"led\": \"" << ledVal << "\", ";
    server << "\"relay\": \"" << relayVal << "\", ";
    server << "\"relay2\": \"" << relay2Val << "\", ";
    server << "\"msg\": \"" << msg << "\" ";	
    server << "} }";
}




void defaultCmd(WebServer &server, WebServer::ConnectionType type, char *url_tail, bool tail_complete)
{
    outputStatus(server,"");  
}

void setup()
{
    // set pins 0-8 for digital input
    //for (int i = 0; i <= 7; ++i)
    //    pinMode(i, INPUT);
    Serial.begin(115200);
    pinMode(relayPin, OUTPUT);
    pinMode(relay2Pin, OUTPUT);
    pinMode(ledPin, OUTPUT);

    //find a onewire device
    if (!ds.search(addr)) {
        ds.reset_search();
        //return false;
    }

    Ethernet.begin(mac, ip);
    webserver.begin();

    webserver.setDefaultCommand(&defaultCmd);


    webserver.addCommand("temp", &tempCmd);
    webserver.addCommand("relay2", &relay2Cmd);
    webserver.addCommand("led", &ledCmd);
    webserver.addCommand("relay", &relayCmd);
}

void loop()
{
    // process incoming connections one at a time forever
    webserver.processConnection();

    // if you wanted to do other work based on a connecton, it would go here

    // see if we need to turn off the LED
    unsigned long currTime = millis();
    if ( digitalRead( ledPin ) == HIGH ) {
        unsigned long diffTime =  currTime - ledOnTime;
        if ( diffTime > ledinterval || ledOnTime > currTime ) {
            digitalWrite( ledPin, LOW );
        }
    }
    if ( digitalRead( relayPin ) == HIGH ) {
        unsigned long diffTime =  currTime - relayOnTime;
        if ( diffTime > relayinterval || relayOnTime > currTime ) {
            digitalWrite( relayPin, LOW );
        }
    }
    if ( digitalRead( relay2Pin ) == HIGH ) {
        unsigned long diffTime =  currTime - relay2OnTime;
        if ( diffTime > relay2interval || relay2OnTime > currTime ) {
            digitalWrite( relay2Pin, LOW );
        }
    }



}

/*
String getTemp() {
 Serial.println("getting temp...");
 String degFstring;
 float degF = thermocouple.readFarenheit();
 int degFdec = (degF - int(degF))*100;
 degFstring = String( int(degF)) + "." + String(degFdec);
 
 Serial.println("got temp " +degFstring);
 return degFstring;    
 }
 */

String getOwTemp() {
    String strtemp;
    float temp;

    byte i;
    byte present = 0;
    byte data[12];



    if (OneWire::crc8( addr, 7) != addr[7]) {
        return false;
    }
    if (addr[0] != DS18S20_ID && addr[0] != DS18B20_ID) {
        return false;
    }
    ds.reset();
    ds.select(addr);
    // Start conversion
    ds.write(0x44, 1);
    // Wait some time...
    delay(850);
    present = ds.reset();
    ds.select(addr);
    // Issue Read scratchpad command
    ds.write(0xBE);
    // Receive 9 bytes
    for ( i = 0; i < 9; i++) {
        data[i] = ds.read();
    }
    // Calculate temperature value
    temp = ( (data[1] << 8) + data[0] )*0.0625;
    temp=temp*1.8+32;
    int degFdec = (temp - int(temp))*100;
    strtemp = String( int(temp)) + "." + String(degFdec);    

    return strtemp;    
}






