/*
 * Sensor orientation: corner 0,0
 * Face up:
 * 0 = top right
 * 1 = bottom right
 * 2 = bottom left
 * 3 = top left
 * Face down:
 * 4 = top right
 * 5 = bottom right
 * 6 = bottom left
 * 7 = top left
 */

int Orient = 0; // Variable to store the sensor orientation // Original value =3

// Number of columns and rows in the grid
int cols = 12;
int rows = 12;

// Window dimension (in pixels)
int ScrDimX = 700; // Original value 800
int ScrDimY = 700; // Original value 800

int PixDimX; // Pixel dimension in X direction
int PixDimY; // Pixel dimension in Y direction
int ScrDimMUX; // Maximum X dimension for screen
int ScrDimMUY; // Maximum Y dimension for screen

// Declare 2D array to store sensor data
int[] myArray = new int[cols * rows];
byte[] BuffArray = new byte[cols * rows];

// Binary receive state
int State; // -1 = waiting for 1st start pattern hAA
// -2 = waiting for 2nd start pattern h55
// -3 = waiting for 1st end pattern hF0
// -4 = waiting for 2nd end pattern h0F
// >0 = character to be received to fill the frame

// Hexadecimal values for patterns
int hAA = unhex("AA");
int h55 = unhex("55");
int hF0 = unhex("F0");
int h0F = unhex("0F");

int ArrIndex; // Index for the array
boolean exitloop; // Flag to exit the loop
int lastTime, now; // Timing variables

int vCols; // Visual columns
int vRows; // Visual rows

import processing.serial.*;

Serial myPort;

void setup() {
  if (Orient == 0 || Orient == 2 || Orient == 5 || Orient == 7) {
    //size(ScrDimX, ScrDimY);
    surface.setSize(ScrDimX, ScrDimY);
  } else {
    // size(ScrDimY, ScrDimX);
    //surface.setSize(ScrDimX, ScrDimY); //original line  
    surface.setSize(ScrDimY, ScrDimX);
  }
  PixDimX=ScrDimX/cols;
  PixDimY=ScrDimY/rows;
  ScrDimMUX=ScrDimX-PixDimX;
  ScrDimMUY=ScrDimY-PixDimY;
  
  //**Troubleshooting Serial Connection (if needed)**
  //List all the available serial ports and note the index of your arduino serial port
  //println(Serial.list());

  // If you have more than one serial port busy, it's possible that arduino is not the first serial port in the array.
  //Change the index of the array from [0] to the needed one.
  myPort = new Serial(this, Serial.list()[0], 38400); // Connect to the first available serial port at 38400 baud
  // myPort = new Serial(this, Serial.list()[0], 115200); // Example alternative baud rate
  // myPort = new Serial(this, Serial.list()[0], 9600); // Example alternative baud rate
  // myPort = new Serial(this, Serial.list()[1], 57600); // Example connecting to a different serial port

  State = -1; // Initial state: waiting for the first start pattern
  ArrIndex = 0; // Initialize array index
  exitloop = false; // Initialize exit loop flag
  
}

void draw() {
  int inByte=0;
  exitloop = false;
  while ((myPort.available() > 0) && !exitloop) {
    if (State < 0) {
      inByte = myPort.read();
      println(inByte, State, myPort.available());
    }
    if (State == -1) {
      if (inByte == hAA ) {
        State = -2; //first pattern OK - Wait for the second
      }
    } else if (State == -2) {
      if (inByte == h55 ) {
        State = cols * rows; //second pattern OK - byte to get
      }
    } else if (State == -3) {
      if (inByte == hF0 ) {
        State = -4; //first pattern OK - Wait for the second
      } else
      {
        print("-");
      }
    } else if (State == -4) {
      if (inByte == h0F ) {
        exitloop = true;
        now = millis();
        //println(now- lastTime);
        lastTime = now;
        State = -1; //wait for next frame
        ArrIndex = 0;

        //show data on screen
        for (int i = 0; i < rows; i++) {
          for (int j = 0; j < cols; j++) {
            stroke(255);
            //              println("valori i=" + i + " j="+ j + "val=" + int(myArray[(i*rows)+j]));
            fill(int(myArray[(i*cols)+j]));
            switch(Orient) {
            case 0:
              //rect(x, y, width, height);
              rect(j*PixDimX, ScrDimMUY-(i*PixDimY), PixDimX, PixDimY);
              break;
            case 1:
              rect(i*PixDimY, j*PixDimX, PixDimY, PixDimX);
              break;
            case 2:
              rect(ScrDimMUX-(j*PixDimX), i*PixDimY, PixDimX, PixDimY);
              break;
            case 3:
              rect(ScrDimMUY-(i*PixDimY), ScrDimMUX-(j*PixDimX), PixDimY, PixDimX);
              break;
            case 4:
              rect(i*PixDimY, ScrDimMUX-(j*PixDimX), PixDimY, PixDimX);
              break;
            case 5:
              rect(j*PixDimX, i*PixDimY, PixDimX, PixDimY);
              break;
            case 6:
              rect(ScrDimMUY-(i*PixDimY), j*PixDimX, PixDimY, PixDimX);
              break;
            case 7:
              rect(ScrDimMUX-(j*PixDimX), ScrDimMUY-(i*PixDimY), PixDimX, PixDimY);
              break;
            }
          }
        }
      }
    }
    if (State > 0) {
      if (myPort.available() >= State)    //wait for a complete frame
      {
        myPort.readBytes(BuffArray);
        for (int i = 0; i < State; i++) {
          myArray[i]=int(BuffArray[i]);
        }
        State = -3;
      } else {
        print(".", myPort.available());
        exitloop = true;
      }
    }
  }
}
