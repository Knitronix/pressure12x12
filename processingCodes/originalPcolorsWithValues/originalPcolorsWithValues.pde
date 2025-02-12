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
  vRows=rows;
  vCols=cols;

  // Adjust screen size based on orientation
  if (Orient == 0 || Orient == 2 || Orient == 5 || Orient == 7) {
    //size(ScrDimX, ScrDimY);
    surface.setSize(ScrDimX, ScrDimY);
  } else {
    // size(ScrDimY, ScrDimX);
    surface.setSize(ScrDimY, ScrDimX);
    //surface.setSize(ScrDimX, ScrDimY);
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
  int pressureValue;

  exitloop = false;
  while ((myPort.available() > 0) && !exitloop) {
    if (State < 0) {
      inByte = myPort.read();
      //println(inByte, State, myPort.available());
    }
   if (State == -1) {
      if (inByte == hAA) {
        State = -2; // First start pattern received, wait for the second
      }
    } else if (State == -2) {
      if (inByte == h55) {
        State = cols * rows; // Second start pattern received, now receive the data bytes
      }
    } else if (State == -3) {
      if (inByte == hF0) {
        State = -4; // First end pattern received, wait for the second
      } else {
        print("-"); // Print "-" if an unexpected byte is received (for debugging)
      }
    } else if (State == -4) {
      if (inByte == h0F){
        exitloop = true; // Second end pattern received, exit the reading loop
        now = millis(); // Record current time
        //println(now - lastTime); // Print time elapsed since the last frame (for debugging)
        lastTime = now; // Update last time
        State = -1; // Reset state to wait for the next frame
        ArrIndex = 0; // Reset array index

        // Display data on the screen
        colorMode(HSB, 350, 300, 255); // Set color mode to HSB

      // Convert the integer array to a string array for printing (for debugging)
        String[] stringArray = new String[myArray.length];
        for (int i = 0; i < myArray.length; i++) {
          stringArray[i] = str(myArray[i]);
        }
        // Print all received values in one line (for debugging)
        //println("All values: " + join(stringArray, " "));

        for (int i = 0; i < vRows; i++) {
          for (int j = 0; j < vCols; j++) {
            pressureValue=myArray[(i*vCols)+j];
            if (pressureValue<210) {
              stroke(pressureValue, 300, 255);
              fill(pressureValue, 300, 255);
            } else {
              stroke(pressureValue, 300+((210-pressureValue)*8), 255);
              fill(pressureValue, 300+((210-pressureValue)*8), 255);
            }

            float x = 0;
            float y = 0;

           // Calculate x and y coordinates based on sensor orientation
            switch (Orient) {
            case 0:
              x = j * PixDimX;
              y = ScrDimMUY - (i * PixDimY);
              break;
            case 1:
              x = i * PixDimY;
              y = j * PixDimX;
              break;
            case 2:
              x = ScrDimMUX - (j * PixDimX);
              y = i * PixDimY;
              break;
            case 3:
              x = ScrDimMUY - (i * PixDimY);
              y = ScrDimMUX - (j * PixDimX);
              break;
            case 4:
              x = i * PixDimY;
              y = ScrDimMUX - (j * PixDimX);
              break;
            case 5:
              x = j * PixDimX;
              y = i * PixDimY;
              break;
            case 6:
              x = ScrDimMUY - (i * PixDimY);
              y = j * PixDimX;
              break;
            case 7:
              x = ScrDimMUX - (j * PixDimX);
              y = ScrDimMUY - (i * PixDimY);
              break;
            }

            // Draw rect
            rect(x, y, PixDimX, PixDimY);

            // Text color options
            fill(0); // black
            textAlign(CENTER, CENTER); // align to center

            // text positioning
            float textX = x + PixDimX / 2;
            float textY = y + PixDimY / 2;

            text(pressureValue, textX, textY);
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
        //print(".", myPort.available());
        exitloop = true;
      }
    }
  }
}
