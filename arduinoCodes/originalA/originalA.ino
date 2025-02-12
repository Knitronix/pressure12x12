/*
  This example reads the output of a 12x12 matrix resistive sensor
 and sends its values serially. The Processing program at the bottom
 take those values and use them to change the background grey level of a 
 matrix on the screen.
 
The circuit:
Arduino digital outputs attached to 12 rows of sensor. 
Arduino analog inputs attached to 12 columns of sensor with 4.7k pull down resistors.

Sensor orientation: row 0, column 0 are the ones near the connectors.
     
 */
const int Cols = 12;   //Define cols number ( 1 >= Cols >= 16 )
const int Rows = 12;   //Define rows number

//declaration of the INPUT pins we will use; i is the position within the array;
//int Pin[]= {A10, A8, A6, A4, A2, A0, A1, A3, A5, A7, A9, A11};
int Pin[] = { A14, A12, A10, A8, A6, A4, A5, A7, A9, A11, A13, A15 };  //configurazione per cavi con riduzione da 16 a 12 e connettori inseriti 'in linea' con il cavi. 

//declaration of the OUTPUT pins we will use; i is the position within the array;
//int dPin[] = {33, 31, 29, 27, 25, 23, 22, 24, 26, 28, 30, 32};  // Pins 22-37 used to supply current to sensor
int dPin[] = { 36, 34, 32, 30, 28, 26, 27, 29, 31, 33, 35, 37 };  // configurazione per cavi con riduzione da 16 a 12 e connettori inseriti 'in linea' con il cavi. 

// Define various ADC prescaler
const unsigned char PS_16 = (1 << ADPS2);
const unsigned char PS_32 = (1 << ADPS2) | (1 << ADPS0);
const unsigned char PS_64 = (1 << ADPS2) | (1 << ADPS1);
const unsigned char PS_128 = (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);


void setup() {

  for (int k = 0; k < Rows; k++) {
    pinMode(dPin[k], OUTPUT);
  }

  for (int j = 0; j < Cols; j++) {
    pinMode(Pin[j], INPUT);
  }
  // Serial.begin(57600);   //turn serial on
  // Serial.begin(115200);   //turn serial on
  Serial.begin(38400);  //turn serial on
  // Serial.begin(9600);   //turn serial on

  // set up the ADC
  ADCSRA &= ~PS_128;  // remove bits set by Arduino library

  // you can choose a prescaler from above.
  // PS_16, PS_32, PS_64 or PS_128
  ADCSRA |= PS_32;  // set our own prescaler to 32
}

void loop() {

  //Send start pattern
  Serial.write(0xAA);
  Serial.write(0x55);

   for (int i = 0; i < Rows; i++) {

    digitalWrite(dPin[i], HIGH);  //turn row i on

    for (int m = 0; m < Cols; m++) {
      int sensorValue = analogRead(Pin[m]);  //read value column m
      if (sensorValue < 1) {  // this is to eliminate noise
        sensorValue = 0;
      }
      int mappedValue = map(sensorValue, 0, 1023, 255, 0);  //map all values read to a new range from 255 to 0

      Serial.write(mappedValue);
    }
    digitalWrite(dPin[i], LOW);  //turn row i off
  }
  //Send end frame pattern
  Serial.write(0xF0);
  Serial.write(0x0F);
}
