
/*
  Web  Server
 
 A simple web server that shows the value of the analog input pins.
 using an Arduino Wiznet Ethernet shield.
 
 Circuit:
 * Ethernet shield attached to pins 10, 11, 12, 13
 * Analog inputs attached to pins A0 through A5 (optional)
 
 created 18 Dec 2009
 by David A. Mellis
 modified 4 Sep 2010
 by Tom Igoe
 
 */

#include <Servo.h>
//#include <max6675.h>

#include <SPI.h>
#include <Ethernet.h>

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 
    0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 
    192,168,101, 202 };


//servo stuff
Servo myservo;
int pos = 0;


int ledPin = 8;
int ledstate=0;

int relayPin = 7;
String relayState =0;

// Initialize the Ethernet server library
// with the IP address and port you want to use
// (port 80 is default for HTTP):
Server server(80);

void setup()
{
    Serial.begin(115200);
    //Serial.println("Setup");

    pinMode(ledPin, OUTPUT);   

    pinMode(relayPin, OUTPUT);

    myservo.attach(9);



    // start the Ethernet connection and the server:
    Ethernet.begin(mac, ip);
    server.begin();

    delay(1000);

}

void loop()
{
    // listen for incoming clients
    Client client = server.available();
    if (client) {
        Serial.println("Client is here.");

        // an http request ends with a blank line
        boolean currentLineIsBlank = true;
        String line = "";
        String url = "";
        while (client.connected()) {
            if (client.available()) {
                char c = client.read();
                Serial.print(c);        

                // if you've gotten to the end of the line (received a newline
                // character) and the line is blank, the http request has ended,
                // so you can send a reply
                if (c == '\n' && currentLineIsBlank) {

                    // this is where we generate the response

                    // send a standard http response header
                    client.println("HTTP/1.1 200 OK");
                    client.println("Content-Type: application/json");
                    client.println("Access-Control-Allow-Origin: *");         
                    client.println();

                    String content = handleURL(url); 

                    client.println(content);
                    client.println();
                    
                    break;
                }
                if (c == '\n') {
                    // you're starting a new line
                    currentLineIsBlank = true;
                    // check to see if the previous line is the GET line
                    if ( line.startsWith("GET") ){
                        // pull out the url
                        int firstSpace = line.indexOf(' ');
                        int secondSpace = line.indexOf(' ', firstSpace+1);
                        url = line.substring(firstSpace+1, secondSpace);  
                    }
                    line = "";
                }
                else if (c != '\r') {
                    // you've gotten a character on the current line
                    currentLineIsBlank = false;
                    line += c;
                }
            }
        }
        // give the web browser time to receive the data
        delay(1);
        // close the connection:
        Serial.println("Stopping the connection.");
        client.stop();
    }
}


String handleURL(String url) {
    Serial.println("Got URL: " + url);
    String temp = getTempString();
    String msg;

    if ( url.equals( "/led/on" )  ) {
        if (ledstate== 0 ) {
            digitalWrite(ledPin, HIGH);
            ledstate = 1;
            msg = "Turned the LED on!";
        }
        else {
            msg = "Led was already on.";
        }
    }
    else if ( url.equals("/led/off" ) ) {
        if ( ledstate == 1) {
            digitalWrite(ledPin, LOW);
            msg = "Turned the LED off!";
            ledstate=0;
        }
        else {
            msg = "LED was already off.";
        }
    }

    else if ( url.equals( "/relay/on" )  ) {
        if (relayState == 0 ) {
            digitalWrite(relayPin, HIGH);
            relayState = 1;
            msg = "Turned the relay on!";
        }
        else {
            msg = "relay was already on.";
        }
    }

    else if ( url.equals("/relay/off" ) ) {
        if ( relayState == 1 ) {
            digitalWrite(relayPin, LOW);
            msg = "Turned the relay off!";
            relayState=0;
        }
        else {
            msg = "relay was already off.";
        }
    }


    else if ( url.equals("/temp" ) ) {
        msg = "retrieved the temperature";

    }

    else if ( url.startsWith("/servo/" ) ) {
        if ( url.length() > 7 ) {
            char carray[6];
            url.substring(7).toCharArray(carray, sizeof(carray));

            int newpos = constrain( atoi(carray), 0, 180);
            if ( newpos > pos ) {
                for ( int tpos = pos; tpos <= newpos; tpos +=1 ) {
                    myservo.write(tpos);
                    pos = tpos;
                    delay(2);
                }   
            }
            else if ( newpos < pos ) {
                for ( int tpos = pos; tpos >= newpos; tpos -=1 ) {
                    myservo.write(tpos);
                    pos =tpos;
                    delay(2);
                }   
            }
            msg = "set the servo";
        }

    }
    else {
        msg =  "URL (" + url + ") doesn't look like a known url.";  
    }

    String json ="{ \"arduino\": { \n ";

    json += "\"msg\": \"";
    json +=msg;
    json += "\", \n";

    json += "\"servo\": ";
    json += pos;
    json += ",\n";

    json += "\"relayState\": \"";
    json += relayState;
    json +="\",\n";


    json += "\"ledstate\": \"";
    json = json.concat(ledstate);      
    json += "\" \n } }";

    Serial.println("msg: " + msg);
    Serial.println("ledstate: " + ledstate);
    Serial.println("relayState: " + relayState);
    Serial.println("Returning: ");
    Serial.println(json);
    Serial.println("(done)");
    
    return json;
}



