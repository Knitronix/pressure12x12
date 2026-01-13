# KNITRONIX SRL Pressure 12x12 sensor 

This directory contains Arduino and Processing sketches designed to interface with the Pressure 12x12 sensor patented by Knitronix srl.
These sketches facilitate data visualization and analysis of the sensor readings.

## Processing Installation

1. **Processing IDE**: Ensure you have the [Processing IDE](https://processing.org/download/) installed on your system.
2. **Libraries**: The sketches MAY require additional libraries. To install them:
   - Open the Processing IDE.
   - Navigate to `Sketch` > `Import Library` > `Add Library`.
   - In the Library Manager, search for the required library and click `Install`.

## Usage

1. **Open a Sketch**:
   - Launch the Processing IDE.
   - Open the desired `.pde` file from this directory (download it, or copy and paste it as a new sketch in the Processing IDE)

2. **Configure Settings**:
   - Some sketches might have configurable parameters at the beginning of the code. Adjust them as needed.

3. **Connect Arduino Mega**:
   - Plug the **Arduino Mega** into your PC using the provided USB cable.
   - The Arduino should already have the required firmware uploaded, so no need to upload it again.

4. **Run the Sketch**:
   - Click the `Run` button (triangle icon) in the Processing IDE.
   - If everything is working correctly, the sketch should start and the pressure map should be visibile.

5. **Troubleshooting Serial Connection (if needed)**:
   - If Processing error is 'ArrayIndexOutOfBoundsException': check the connection cable between Arduino and your PC. If the error persists it is possible that the PC assigned a different serial port to the Arduino.
   - To check the assigned port:
     1. **Open the Arduino IDE**.
     2. Go to `Tools` > `Port` and note the name of the port (e.g., `COM3` on Windows, `/dev/ttyUSB0` on Linux, `/dev/tty.usbmodemXXXX` on macOS).
   - **Update the Processing Sketch**:
     - Open the `.pde` file in Processing.
     - Uncomment the line:      
         // println(Serial.list());
     - Save and run the sketch to read the list of the serial ports available.
     - Stop the code, comment back  the line:   
         println(Serial.list());
     - If necessary, replace `[0]` with the correct index in 
         myPort = new Serial(this, Serial.list()[0], 38400);
   - Save the file and try running the sketch again.

6. **More troubleshooting**
   - If Processing error is 'Error opening serial port COMX: Port busy' the serial port is busy: close other app that are using the same serial port.


## Contributing

We welcome contributions! If you'd like to contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a Pull Request.

Please ensure your code adheres to the project's coding standards and includes appropriate documentation.

## License

This project is licensed under the [MIT License](../LICENSE). Feel free to use, modify, and distribute this software as per the terms of the license.
