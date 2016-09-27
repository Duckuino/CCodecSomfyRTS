//
// Version 1.3
// (C)opyright yoyolb - 18/06/2016
//
// Tested with Arduino MEGA and:
//   - RX module RR3-433 (433.92 MHz) => port A1
//   - TX Telecommande Somfy modifiée (433.42 MHz) => port A0
// Evolution: Programmation condition ==> activation for winter or summer ==> Need ArduinoShutterControl v1.5



#ifndef CCodecSomfyRTS_h
#define CCodecSomfyRTS_h

#include "EEPROM.h"
#include <Ethernet.h>
#include <EthernetUdp.h>

#if ARDUINO >= 100
    #include "Arduino.h"
#else
extern "C" {
    #include "WConstants.h"
}
#endif

// Microseconds
const word k_tempo_wakeup_pulse = 9415;
const word k_tempo_wakeup_silence = 89565;
const word k_tempo_synchro_hw = 2416;
const word k_tempo_synchro_hw_min = 2416*0.7;
const word k_tempo_synchro_hw_max = 2416*1.3;
const word k_tempo_synchro_sw = 4550;
const word k_tempo_synchro_sw_min = 4550*0.7;
const word k_tempo_synchro_sw_max = 4550*1.3;
const word k_tempo_half_symbol = 604;
const word k_tempo_half_symbol_min = 604*0.7;
const word k_tempo_half_symbol_max = 604*1.3;
const word k_tempo_symbol = 1208;
const word k_tempo_symbol_min = 1208*0.7;
const word k_tempo_symbol_max = 1208*1.3;
const word k_tempo_inter_frame_gap = 30415;

const int UDP_SOMFY_TX_PACKET_MAX_SIZE = 54;

// Byte 1 to 3 ==> Remote Address  ==> 3 bytes
// Byte 4 ==> Start EEprom Address ==> 2 bytes to store
typedef char RemoteName[];
typedef char UdpPassWord[8];
typedef uint8_t RemoteControl[4];


class CCodecSomfyRTS {
  public:
    enum t_status {
      k_waiting_synchro,
      k_receiving_data,
      k_complete
    };

  public:
    CCodecSomfyRTS(byte PORT_TX);
    CCodecSomfyRTS(byte PORT_TX, RemoteName, RemoteControl*, UdpPassWord);
    CCodecSomfyRTS(byte PORT_TX, RemoteName, RemoteControl*, UdpPassWord, int);
    void init(byte, byte);
    void Up(RemoteControl);
    void Down(RemoteControl);
    void MyStop(RemoteControl);
    void Gate(RemoteControl, byte);
    void AddProg(RemoteControl);
    void RemoveProg(RemoteControl);
    void GetRC();
    void CheckAndroid(EthernetUDP);
    void CheckProg(byte, byte);
    void CheckProg(byte, byte, byte);

  protected:
    t_status _CheckPulse(word p);
    t_status _status;
    char* _remotename;
    char* _UdpPassWord;
    RemoteControl* _remotecontrol_all;
    uint8_t* _remotecontrol;
    byte _cpt_synchro_hw;
    byte _cpt_bits;
    byte _previous_bit;
    bool _waiting_half_symbol;
    byte _payload[7];
    byte _PORT_TX;
    byte _PORT_RX;
    void _RefreshRollingCode();
    unsigned long _rolling_code;
    char _packetBuffer[ UDP_SOMFY_TX_PACKET_MAX_SIZE ];
    int _AddressProg;
    byte _LastHour;

  private:
    bool decode();
    bool transmit(byte cmd, byte first);
};

#endif
