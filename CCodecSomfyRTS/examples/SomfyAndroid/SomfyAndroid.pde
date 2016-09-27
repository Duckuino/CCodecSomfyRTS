//
// (C)opyright aymeric - 24/08/2015
// Version 1.0
// 
// Tested with Arduino MEGA and:
//   port A1 - RX module XY-MK-5V (433.92 MHz)
//   port A0 - TX Module FS1000A modifiée (433.42 MHz - Réf : RO3112 Murata TO92)
//
// Command by Udp : Android Connection

#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <EEPROM.h>
#include <CCodecSomfyRTS.h>

// RR3-433 PIN
byte PORT_TX = A0;

// New Remote Control
// Syntax by remote control : "indice + Remote Control Name + "_"
// indice ==> 1 : Roller Blind - 2 : Portal or Garage Gate
RemoteName    RN =  "1All_"
                    "1North_"
                    "1South_"
                    "2Portal"
                    "2Garage";
                    
// Secure Udp Connection with password (7 char)                    
UdpPassWord  PW = "Somfyno";

// Index 0 to 2 ==> Remote Control Address (3 bytes)
// Byte 3       ==> Start EEprom Address ==> 2 bytes to store
RemoteControl RC[] = {
                    {0xAB, 0xCD, 0xEF, 200}, // Strore Rollling in adress 200 and 201
                    {0x00, 0x00, 0x01, 202}, // Strore Rollling in adress 202 and 203
                    {0x00, 0x00, 0x02, 204},  // Strore Rollling in adress 204 and 205
                    {0x00, 0x00, 0x03, 206},  // Strore Portal   in adress 206 to 209 ==> 2 button
                    {0x00, 0x00, 0x05, 210}
                      };
                              
// Create Object
static CCodecSomfyRTS codecSomfyRTS(PORT_TX, // Transitter Port
                                     RN, RC, // Remote Control
                                     PW);    // Password

// Network   
EthernetUDP SomfyUdp;

                      
void setup () {
    Serial.begin(9600);

    // start Ethernet
    byte mac[6] = {0x90, 0xA2, 0xDA, 0x00, 0x65, 0x6F};
    Serial.println(F("Connect Network..."));
    if (Ethernet.begin(mac) == 0) {
      Serial.println(F("...Failed to configure Ethernet using DHCP"));

    }else{
      Serial.println(F("...Connection OK"));
    } 
    
    // init : Start UDP connection
      SomfyUdp.begin(8031);
      
    // init Library
    // Argument 1 : 0 Serial Off - 1 Serial On 115200 bauds
    // Argument 2 : 0 RX Off - 1 RX On 
    // Becareful ==> RX module switch All analog voltage reference to 1.1V
      codecSomfyRTS.init(0, 0);
}


void loop() {
  
  // Check Android Connection
  codecSomfyRTS.CheckAndroid(SomfyUdp);
  delay(200);
  
}

