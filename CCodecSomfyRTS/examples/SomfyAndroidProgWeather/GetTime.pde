
///////////////////// Get Time ////////////////////////////////////
void RefreshTime()
  {
    if (timeStatus() != timeNotSet) {
      if (now() != prevDisplay) { //update the display only if time has changed
        //prevDisplay = now();
        timeZone = adjustDstEurope();
        Serial.print(F("TimeZone = "));Serial.println(timeZone);
        prevDisplay = now();
        
        // get the hour, minute and second:
        float tmp = hour() * 100;
        tmp += minute();
        tmp /= 10; // 8h50 ==> 85
        
        if (tmp > 0){
          // Get Valide Time
          CurTime[0] = tmp;
          
          // get Day of Week (0 ==> Lundi)
          int wd = weekday() - 2;
          if (wd == -1){
            wd = 6;
          }
          CurTime[1] = wd;
        }
      }
    }
  }
  
/*-------- NTP code ----------*/

const int NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets

time_t getNtpTime()
{
  UdpTime.begin(localPort);
  while (UdpTime.parsePacket() > 0) ; // discard any previously received packets
  Serial.println("Transmit NTP Request");
  sendNTPpacket(timeServer);
  uint32_t beginWait = millis();
  while (millis() - beginWait < 1500) {
    int size = UdpTime.parsePacket();
    if (size >= NTP_PACKET_SIZE) {
      Serial.println("Receive NTP Response");
      UdpTime.read(packetBuffer, NTP_PACKET_SIZE);  // read packet into the buffer
      unsigned long secsSince1900;
      // convert four bytes starting at location 40 to a long integer
      secsSince1900 =  (unsigned long)packetBuffer[40] << 24;
      secsSince1900 |= (unsigned long)packetBuffer[41] << 16;
      secsSince1900 |= (unsigned long)packetBuffer[42] << 8;
      secsSince1900 |= (unsigned long)packetBuffer[43];
      UdpTime.stop();
      return secsSince1900 - 2208988800UL + timeZone * SECS_PER_HOUR;
    }
  }
  Serial.println("No NTP Response :-(");
  UdpTime.stop();
  return 0; // return 0 if unable to get the time
}

// send an NTP request to the time server at the given address
void sendNTPpacket(IPAddress &address)
{
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49;
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;
  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:                 
  UdpTime.beginPacket(address, 123); //NTP requests are to port 123
  UdpTime.write(packetBuffer, NTP_PACKET_SIZE);
  UdpTime.endPacket();
}

int adjustDstEurope()
{
 // last sunday of march
 int beginDSTDate=  (31 - (5* year() /4 + 4) % 7);
 //Serial.println(beginDSTDate);
 int beginDSTMonth=3;
 //last sunday of october
 int endDSTDate= (31 - (5 * year() /4 + 1) % 7);
 //Serial.println(endDSTDate);
 int endDSTMonth=10;
 // DST is valid as:
 if (((month() > beginDSTMonth) && (month() < endDSTMonth))
     || ((month() == beginDSTMonth) && (day() >= beginDSTDate)) 
     || ((month() == endDSTMonth) && (day() <= endDSTDate)))
 return 2;  // DST europe = utc +2 hour
 else return 1; // nonDST europe = utc +1 hour
}
