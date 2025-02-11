


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

int Orient = 0; //nel mio 3

// Number of columns and rows in the grid
int cols = 12;
int rows = 12;


// Window dimension
int ScrDimX = 700; //nel mio 800
int ScrDimY = 700; //nel mio 800

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

int vCols; //Visual Cols
int vRows; //Visual Rows

import processing.serial.*;


Serial myPort;

void setup() {
  vRows=rows;
  vCols=cols;

  if (Orient == 0 || Orient == 2 || Orient == 5 || Orient == 7) {
    //size(ScrDimX, ScrDimY);
    surface.setSize(ScrDimX, ScrDimY);
  } else {
    // size(ScrDimY, ScrDimX);
    surface.setSize(ScrDimY, ScrDimX);
    // era così: ma non aveva senso l'if!
    //surface.setSize(ScrDimX, ScrDimY);
  }
  PixDimX=ScrDimX/cols;
  PixDimY=ScrDimY/rows;
  ScrDimMUX=ScrDimX-PixDimX;
  ScrDimMUY=ScrDimY-PixDimY;

  // List all the available serial ports
  //println(Serial.list());

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
  int valore;

  exitloop = false;
  while ((myPort.available() > 0) && !exitloop) {
    if (State < 0) {
      inByte = myPort.read();
      //println(inByte, State, myPort.available());
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
        colorMode(HSB, 350, 300, 255);

        String[] stringArray = new String[myArray.length];
        for (int i = 0; i < myArray.length; i++) {
          stringArray[i] = str(myArray[i]);
        }
        // Stampa l'array di valori ricevuti in una sola riga
         //println("Valori ricevuti: " + join(stringArray, " "));
     
        for (int i = 0; i < vRows; i++) {
          for (int j = 0; j < vCols; j++) {
            valore=myArray[(i*vCols)+j];
            if (valore<210) {
              stroke(valore, 300, 255);
              fill(valore, 300, 255);
            } else {
              stroke(valore, 300+((210-valore)*8), 255);
              fill(valore, 300+((210-valore)*8), 255);
            }

            float x = 0;
            float y = 0;

            // Calcola x e y in base all'orientamento
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

            // Disegna il rettangolo
            rect(x, y, PixDimX, PixDimY);

            // Imposta il colore del testo
            fill(0); // Testo nero (o scegli un colore che contrasti con il rettangolo)
            textAlign(CENTER, CENTER); // Allinea il testo al centro del rettangolo

            // Calcola la posizione del testo al centro del rettangolo
            float textX = x + PixDimX / 2;
            float textY = y + PixDimY / 2;

            // Disegna il valore come testo
            text(valore, textX, textY);
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
