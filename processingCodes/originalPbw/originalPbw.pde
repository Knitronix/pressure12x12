
/*Sensor orientation: corner 0,0
 face up
 0=top right
 1=bottom right
 2=bottom left
 3=top left
 
 face down
 4=top right
 5=bottom right
 6=bottom left
 7=top left
 
 */
int Orient = 0;

// Number of columns and rows in the grid
int cols = 12;
int rows = 12;
// Window dimension
int ScrDimX = 700;
int ScrDimY = 700;

int PixDimX;
int PixDimY;
int ScrDimMUX;
int ScrDimMUY;

// Declare 2D array
//float[] myArray = new float[cols*rows];
int[] myArray = new int[cols*rows];
byte[] BuffArray = new byte[cols*rows];

// binary receive
int State; //-1 = waiting for 1 start pattern hAA
//-2 = waiting for 2 start pattern h55
//-3 = waiting for 1 end pattern hF0
//-4 = waiting fot 2 end pattern h0F
//>0 caracter to be received to fill the frame

int hAA = unhex("AA");
int h55 = unhex("55");
int hF0 = unhex("F0");
int h0F = unhex("0F");

int ArrIndex;
boolean exitloop;
int lastTime, now;

import processing.serial.*;


Serial myPort;

void setup() {
  if (Orient == 0 || Orient == 2 || Orient == 5 || Orient == 7) {
    //size(ScrDimX, ScrDimY);
    surface.setSize(ScrDimX, ScrDimY);
  } else {
    // size(ScrDimY, ScrDimX);
    surface.setSize(ScrDimX, ScrDimY);
  }
  PixDimX=ScrDimX/cols;
  PixDimY=ScrDimY/rows;
  ScrDimMUX=ScrDimX-PixDimX;
  ScrDimMUY=ScrDimY-PixDimY;
  // List all the available serial ports
  println(Serial.list());
  // I know that the first port in the serial list on my mac
  // is always my  Arduino, so I open Serial.list()[0].
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[0], 38400);
  //  myPort = new Serial(this, Serial.list()[0], 115200);
  //  myPort = new Serial(this, Serial.list()[0], 9600);
  //  myPort = new Serial(this, Serial.list()[1], 57600);
  // don't generate a serialEvent() unless you get a newline character:
  // myPort.bufferUntil('\n');
  State = -1; //waiting for 1 start pattern
  ArrIndex = 0;
  exitloop = false;
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
        println(now- lastTime);
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
