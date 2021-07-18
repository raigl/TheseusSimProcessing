/*
    Simulation for Shannon's Theseus
 */

String VersionString = "Version 1.0a";
boolean showButtons = false;
class Punkt {
  int x, y;
  Punkt(int xa, int ya) {
      x = xa;
      y = ya;
  }
}
PImage startImg, stopImg;
int xOffset, yOffset; 
int movecount = 0;
int fieldcount = 0;
int raster = 120; 
int fencewidth = 12;
int white=#ffffff, black=#000000, red=#ff0000, green=#00ff00, blue=#0000ff, 
    gray=#080808;
boolean pause = true;
boolean dialogBusy = false;
String fencesFile = null;
Punkt aktFeld = new Punkt(1,1);

// used by maus and fences
char north='N', west='W', south='S', east='E';
char initDir = east;

Maus maus;
Fences fences;
Punkt goal;

char[][] exitDir = new char[6][6];
// Initialisierung
void setup() {
  fullScreen();
  xOffset = (width-raster*7-200)/2;
  yOffset = (height-raster*7)/2;
  frameRate(20);

  startImg = loadImage("start.png");
  stopImg = loadImage("stop.png"); 

  // Objekte für die Zäune und die Maus anlegen
  fences = new Fences();
  maus = new Maus();
  maus.speed = 8;
  goal = new Punkt(5,5);
  for (int i = 1; i < 6; ++i)
    for (int j = 1; j < 6; ++j)
      exitDir[i][j] = initDir;
}

// Zielmarkierung anzeigen
void showGoal() {
  fill(green);
  int x1 = goal.x*raster + raster/2;
  int y1 = goal.y*raster + raster/2;
  circle(x1, y1, raster/3);
}

// Mausklick auswerten;
// je nach Koordinate zum Setzen und Löschen der Zäune oder zum Setzen der Maus
void mouseClicked() {
  if (mouseButton == LEFT) {
    if (fences.flip(mouseX-xOffset, mouseY-yOffset)) 
      return;
    if (maus.setXY(mouseX-xOffset, mouseY-yOffset)) {
      pause = true;
      Punkt xy = maus.whereis();
      maus.mausDir = exitDir[xy.x][xy.y];
      maus.show();
      movecount = 0;
      fieldcount = 0;
      aktFeld = xy;
      return;
    }
    if ((mouseX-xOffset- raster*7) > 0 && (mouseX-xOffset- raster*7) < 100) 
      pause = !pause;
  }
  if (mouseButton == RIGHT) {
    int x = (mouseX-xOffset)/raster;
    int y = (mouseY-yOffset)/raster;
    if (x > 0 && y > 0 && x < 6 && y < 6) {
      goal.x = (mouseX-xOffset)/raster;
      goal.y = (mouseY-yOffset)/raster;
    }
    return;
  }
}

// toggle pause if key pressed
void keyPressed() {
  // Quit
  if (key == 'q' || key == 'Q') 
    exit();

  // Pause
  if (key == ' ') {
    if (pause) pause = false;
    else pause = true;
  }

  // Drehrichtung / turn direction
  if (key == 'd' || key == 'D') {
    if (maus.clockwise) maus.clockwise = false;
    else maus.clockwise = true;
  }

  // Save and Load 
  if (key == 'p' || key == 'P') {
    selectOutput("Put to file:", "fileSelected");
    dialogWait();
    fences.saveFences(fencesFile);
  }
  if (key == 'g' || key == 'G') {
    selectInput("Get from file:", "fileSelected");
    dialogWait();
    fences.loadFences(fencesFile);
    key = 'r';
  }
  
  // reset 
  if (key == 'n' || key == 'N') {
    for (int i=0; i< 6; ++i)
      for (int j=0; j < 6; ++j)
        exitDir[i][j] = north;
    suchModus = true;
  }
  if (key == 'o' || key == 'O' || key == 'e' || key == 'E') {
    for (int i=0; i< 6; ++i)
      for (int j=0; j < 6; ++j)
        exitDir[i][j] = east;
    suchModus = true;
  }
  if (key == 's' || key == 'S') {
    for (int i=0; i< 6; ++i)
      for (int j=0; j < 6; ++j)
        exitDir[i][j] = south;
    suchModus = true;
  }
  if (key == 'w' || key == 'W') {
    for (int i=0; i< 6; ++i)
      for (int j=0; j < 6; ++j)
        exitDir[i][j] = west;
    suchModus = true;
  }
  if (key == '+' && maus.speed < 10)
    ++maus.speed;
  if (key == '-' && maus.speed > 1)
    --maus.speed;
} 

void dialogWait() {
    dialogBusy = true;
    while (dialogBusy) {
        delay(100);
        text(" waiting for dialog", 400, 50);
    }
}

void fileSelected(File selection) {
  if (selection != null) {
    fencesFile = selection.getPath();
    println(fencesFile);
  }
  dialogBusy = false;
}


// Suchstrategie
boolean suchModus = true;
boolean skipEntry = true;
char mouseDir = east;
char lastMouseEntry = east;

void strategie() { 
  // warte, bis Mausbewegung abgeschlossen
  if (maus.busy) return;
  

  Punkt xy = maus.whereis();

  // Ziel erreicht?
  if (maus.trifftZiel()) {
      if (suchModus)
        suchModus = false;
      pause = true;
      return;
    }

  // wenn am Zaun, umdrehen und zurück auf Feldmitte
  if (maus.stopcode == 1) {
    maus.bewege(0, maus.drehe(maus.drehe(maus.mausDir)));
    if (suchModus) 
       return;
    // Zaunberührung im Zielmodus: drehen
    exitDir[xy.x][xy.y] = maus.drehe(exitDir[xy.x][xy.y]);
    return;
  }
  ++movecount;
  if (!suchModus && fieldcount > 23)
    suchModus = true;

  // Eingangrichtung merken
  if (xy.x != aktFeld.x || xy.y != aktFeld.y) {
    lastMouseEntry = maus.drehe(maus.drehe(mouseDir));
    // println(lastMouseEntry);
    aktFeld = xy;
    skipEntry = true;
    fieldcount++;
  }
  
  // Suchmodus: bei Eintritt drehen
  if (suchModus) 
    mouseDir = maus.drehe(exitDir[xy.x][xy.y]);
  else
    mouseDir = exitDir[xy.x][xy.y];
    
  // println("last=" + lastMouseEntry + " new=" + mouseDir);
  
  // Zunächst nicht über den Eingang wieder verlassen
  if (lastMouseEntry == mouseDir && skipEntry == true) {
    mouseDir = maus.drehe(mouseDir);
    skipEntry = false;
  }
  
  exitDir[xy.x][xy.y] = mouseDir;
  maus.bewege(1, mouseDir);

}

void showExitDirs() {
  fill(127);
  int d = fencewidth/2;
  for (int i = 1; i < 6; ++i) 
    for (int j = 1; j < 6; ++j) {
      char ed = exitDir[i][j];
      int pixX = i*raster + raster/2;
      int pixY = j*raster + raster/2;
      if (ed == east)
        triangle(pixX-d, pixY-d, pixX-d, pixY+d, pixX+2*d, pixY);
      if (ed == west)
        triangle(pixX+d, pixY+d, pixX+d, pixY-d, pixX-2*d, pixY);
      if (ed == north)
        triangle(pixX-d, pixY+d, pixX+d, pixY+d, pixX, pixY-2*d);
      if (ed == south)
        triangle(pixX-d, pixY-d, pixX+d, pixY-d, pixX, pixY+2*d);
    }
}
// Hilfetexte
void helptexts() {
  text(VersionString, raster*7, 50);
  text("Click fence to change", raster*7, 100);
  text("Click inside to set or turn mouse", raster*7, 125);
  text("Right click inside to set goal ", raster*7, 150);
  text("Blank = Pause, Q = Quit", raster*7, 175);
  text("+ = quicker, - = slower; actual: "+maus.speed, raster*7, 200);
  text("G = Get, P = Put fences in/from file", raster*7, 225);
  text("D = direction of turn change", raster*7, 250);
  text("Initial directions: E(ast), W(est), N(orth), S(outh)", raster*7, 275);
}

/* 
 Zentrale Schleife.
 Zunächst wird die Anzeige aktualisiert.
 Sodann wird die aktuelle Mausbewegung ausgeführt;
 bzw. die nächste Mausbeweung bestimmt
 */

void draw() {
  // Bildschirm aktualisieren
  background(white);
  translate(xOffset, yOffset);      // applies not on mouse coordinates
  helptexts();
  textSize(14);
  text(movecount+" moves " + fieldcount+" fields", 350, 50);
  if (fencesFile != null) {
    if (fences.changed)
      text("Changed: " + fencesFile, 100, 800);
    else
      text("File: " + fencesFile, 100, 800);
  }

  if (showButtons) {
    if (pause) { 
      text("Pause", 150, 50);
      image(startImg, raster*7, 400, 100, 100);
    } else {
      image(stopImg, raster*7, 400, 100, 100);
    }
  }
  
  if (suchModus) 
    text("Explore mode ...      ", 200, 50);
  else
    text("Goal mode" , 200, 50);

  textSize(28);
  if (maus.clockwise) 
    text("\u21b7", 500, 50);
  else
    text("\u21B6", 500, 50);  
  textSize(14);
  // Reihenfolge wg. verbergen //<>//
  fences.draw();
  showExitDirs();
  showGoal();
  maus.show();


  if (pause) return;

  /* Zwei prozesse werden simuliert:
   Einer für die Mausbewegung,
   der andere, um die Maus neu zu starten.
   */
  maus.voran();
  strategie();
}
