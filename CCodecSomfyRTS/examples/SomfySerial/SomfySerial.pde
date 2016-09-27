//
// (C)opyright aymeric - 25/06/2015
// Version 1.0
// 
// Tested with Arduino MEGA and:
//   port A1 - RX module XY-MK-5V (433.92 MHz)
//   port A0 - TX Module FS1000A modifiée (433.42 MHz - Réf : RO3112 Murata TO92)
//
// Write Command in serial Monitor
// Ex: u1 ==> Button up of first Remote control
// Ex: d2 ==> Button down of second Remote control

// Command
// u= up
// d= down
// m= my/stop
// A= Add Remote Control to Roller Blind
// R= Remove Remote Control to Roller Blind

#include <SPI.h>
#include <EEPROM.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <CCodecSomfyRTS.h>

// RR3-433 PIN
byte PORT_TX = A0;

// New Remote Control
// Index 0 to 2 ==> Remote Control Address (3 bytes)
// Byte 3       ==> Start EEprom Address ==> 2 bytes to store
static RemoteControl RC[] = {
                    {0xAB, 0xCD, 0xEF, 200}, // Strore Rollling in adress 200 and 201
                    {0x00, 0x00, 0x01, 202}, // Strore Rollling in adress 202 and 203
                    {0x00, 0x00, 0x02, 204}  // Strore Rollling in adress 204 and 205
                      };
                              
// Create Object
static CCodecSomfyRTS codecSomfyRTS(PORT_TX);

                      
void setup () {
    // init Library
    // Argument 1 : 0 Serial Off - 1 Serial On 115200 bauds
    // Argument 2 : 0 RX Off - 1 RX On 
    // Becareful ==> RX module switch All analog voltage reference to 1.1V
    codecSomfyRTS.init(1, 1);
}


void loop() {
  // Check incoming Remote Control
  codecSomfyRTS.GetRC();
  
  // Send Remote Control Request by Serial
  if (Serial.available() > 0) {
    
    char inByte[2];
    Serial.readBytes(inByte, 2);
    byte idx = inByte[1]-48;
    Serial.print((char)inByte[0]);Serial.println(idx);
    
    if (idx >= 0 & idx < 2){
         // Up
          if ((char)inByte[0]=='u'){
            codecSomfyRTS.Up(RC[idx]);
          }
          // Down
          if ((char)inByte[0]=='d'){  
            codecSomfyRTS.Down(RC[idx]);
          }
          // MyStop
          if ((char)inByte[0]=='m'){
            codecSomfyRTS.MyStop(RC[idx]);  
          }
          // Gate button 1
          if ((char)inByte[0]=='g'){
            codecSomfyRTS.Gate(RC[idx], 0);  
          }
          // Gate button 2
          if ((char)inByte[0]=='G'){
            codecSomfyRTS.Gate(RC[idx], 1);  
          }
          // Add Remote Control
          if ((char)inByte[0]=='A'){
            codecSomfyRTS.AddProg(RC[idx]); 
          }
          // Delete Remote Control
          if ((char)inByte[0]=='R'){ 
            codecSomfyRTS.RemoveProg(RC[idx]); 
          }
     }  
  }
}

