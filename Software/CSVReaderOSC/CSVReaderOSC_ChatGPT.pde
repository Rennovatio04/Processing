// Importación de librerías necesarias para el funcionamiento del programa.
import java.io.FileReader;
import java.io.FileNotFoundException;
import oscP5.*; // Para comunicación OSC.
import netP5.*; // Para redes en proyectos OSC.
import controlP5.*; // Para crear interfaces gráficas de usuario.

// Declaración de variables globales para la interfaz de usuario y la comunicación OSC.
ControlP5 cp5;
Textlabel titulo, logo;
Chart barraAF3, myChart;
ControlTimer c;
Textlabel t;
OscP5 oscP5; 
NetAddress direccionRemota; 
String portValue = "";

BufferedReader mBr = null;
int lastFileRead;
String filename;

int puerto;
String ip;
// Direcciones OSC para enviar datos específicos.
String[] direccionOsc = {"/csv/T1", "/csv/T2", "/csv/T3", "/csv/T4", "/csv/T5", "/csv/T6", "/csv/T7", "/csv/T8"};

void setup() {
  size(410, 300); // Tamaño de la ventana de la aplicación.
  background(0); // Color de fondo.

  // Configuración inicial de la comunicación OSC.
  ip = "localhost"; // Dirección IP para la comunicación OSC.
  puerto = 6448; // Puerto para la comunicación OSC.
  
  oscP5 = new OscP5(this, puerto); // Inicialización de la comunicación OSC.
  direccionRemota = new NetAddress(ip, puerto); // Dirección remota para enviar los mensajes OSC.
  cp5 = new ControlP5(this); // Inicialización de la interfaz de usuario.

  // Configuración de elementos de la interfaz: logo y título.
  logo = cp5.addTextlabel("logo")
    .setText("CSV TO OSC")
    .setFont(createFont("Roboto", 20))
    .setPosition(98, 57)
    .setColorValue(color(5, 252, 35));

  titulo = cp5.addTextlabel("titulo")
    .setText("DATA TO OSC FROM CSV/TSV FILE")
    .setPosition(98, 80)
    .setColorValue(color(5, 252, 35));

  // Botones para la selección de archivos y conexión a puertos OSC.
  Button b1 = cp5.addButton("Select a file to process:")
    .setValue(0)
    .setPosition(100, 100)
    .setSize(200, 19)
    .setColorBackground(color(5, 252, 35))
    .setColorForeground(color(20, 224, 45))
    .setColorActive(color(20, 224, 45))
    .setColorLabel(color(0))
    .activateBy(ControlP5.PRESSED);

  // Más botones para conectar a diferentes puertos OSC. Repetir para b2, b3, b4 con diferentes puertos.
  Button b2 = cp5.addButton("* Conect to port: 1113:")
    .setValue(0)
    .setPosition(100, 120)
    .setSize(100, 19)
    .setColorBackground(color(5, 252, 35))
    .setColorForeground(color(20, 224, 45))
    .setColorActive(color(20, 224, 45))
    .setColorLabel(color(0))
    .activateBy(ControlP5.PRESSED);

  // Campo de texto para ingresar valor de puerto y botón para limpiar este campo.
  cp5.addTextfield("portValue")
    .setPosition(100, 181)
    .setSize(100, 19)
    .setFont(createFont("arial", 9))
    .setColorBackground(color(0))
    .setColorForeground(color(20, 224, 45))
    .setColorActive(color(20, 224, 45))
    .setAutoClear(false);

  cp5.addBang("clear")
    .setPosition(200, 181)
    .setSize(100, 19)
    .setColorBackground(color(5, 252, 35))
    .setColorForeground(color(20, 224, 45))
    .setColorActive(color(142, 17, 17))
    .setColorLabel(color(0))
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  // Callback para el botón de selección de archivo.
  b1.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_PRESSED): 
          selectInput("Select a file to process:", "fileSelected");  
          println("User selected " + filename);
          break;
        case(ControlP5.ACTION_RELEASED):
          c = new ControlTimer();
          t = new Textlabel(cp5, "--", 100, 100);        
          c.setSpeedOfTime(1); 
          break;
      }
    }
  });

  lastFileRead = millis(); // Registro del último archivo leído.
}

void draw() {
  // Dibujo de elementos de la interfaz.
  titulo.draw(this); 
  logo.draw(this); 

  if (mBr == null) return; // Si no hay archivo seleccionado, no hacer nada.

  // Leer y enviar datos cada 5ms.
  if (millis() - lastFileRead > 5) {
    try {
      String line = mBr.readLine(); // Leer una línea del archivo.
      if (line == null) { // Si se llega al final del archivo, reiniciar la lectura.
        mBr.close();
        mBr = new BufferedReader(new FileReader(filename));
        mBr.readLine(); // Omitir la primera línea si es necesario.
      }

      String[] valArray = line.trim().split("\\s*,\\s*"); // Separar valores por coma.
      // Enviar cada valor como mensaje OSC.
      for (int i = 0; i < valArray.length; i++) {
        float f = Float.valueOf(valArray[i]);
        OscMessage mensaje = new OscMessage(direccionOsc[i]);
        mensaje.add(f); // Añadir valor al mensaje OSC.
        oscP5.send(mensaje, direccionRemota); // Enviar mensaje OSC.
      }
      t.setValue(c.toString()); // Actualizar temporizador.
      t.draw(this); // Dibujar temporizador.
      t.setPosition(210, 205); // Posición del temporizador.
    } catch(Exception e) {
      // Manejo de excepciones al leer el archivo.
    }

    lastFileRead = millis(); // Actualizar tiempo del último archivo leído.
  }
}

// Función para limpiar el campo de texto del puerto.
public void clear() {
  cp5.get(Textfield.class, "portValue").clear();
}

// Manejo de eventos de la interfaz de usuario.
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
      + theEvent.getName() + "': "
      + theEvent.getStringValue());
  }
}

// Recepción
