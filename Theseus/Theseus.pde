/*
    Simulation for Shannon's Theseus
 */


class Punkt {
  int x, y;
  Punkt(int xa, int ya) {
      x = xa;
      y = ya;
  }
}

int movecount = 0;
int raster = 100; 
int fencewidth = 10;
int white=#ffffff, black=#000000, red=#ff0000, green=#00ff00, blue=#0000ff, 
    gray=#080808;
boolean pause = true;
boolean dialogBusy = false;
String fencesFile = null;

// used by maus and fences
char north='N', west='W', south='S', east='E';
char initDir = north;

Maus maus;
Fences fences;
Punkt goal;

char[][] exitDir = new char[6][6];
// Initialisierung
void setup() {
  size(1000, 700);
  frameRate(30);

  // Objekte für die Zäune und die Maus anlegen
  fences = new Fences();
  maus = new Maus();
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
    if (fences.flip(mouseX, mouseY)) 
      return;
    if (maus.setXY(mouseX, mouseY)) 
      pause = true;
      return;
  }
  if (mouseButton == RIGHT) {
    int x = mouseX/raster;
    int y = mouseY/raster;
    if (x > 0 && y > 0 && x < 6 && y < 6) {
      goal.x = mouseX/raster;
      goal.y = mouseY/raster;
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
  movecount = 0;
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
Punkt aktFeld = new Punkt(1,1);
char lastMouseEntry = east;
int fahrZaehler = 0;

void strategie() { 
  // warte, bis Mausbewegung abgeschlossen
  if (maus.busy) return;
  ++movecount;

  // wenn am Zaun, umdrehen und zurück auf Feldmitte
  if (maus.stopcode == 1) {
    suchModus = true;
    maus.mausDir = maus.drehe(maus.drehe(maus.mausDir));
    maus.bewege(0, maus.mausDir);
    return;
  }
  

  // Suchmodus: 
  Punkt xy = maus.whereis();
  if (suchModus) {
    // Ziel erreicht?
    if (maus.trifftZiel()) {
      suchModus = false;
      fahrZaehler = 0;
      return;
    }
    if (xy.x != aktFeld.x || xy.y != aktFeld.y) {
      lastMouseEntry = maus.drehe(maus.drehe(mouseDir));
      // println(lastMouseEntry);
      aktFeld = xy;
      skipEntry = true;
    }
    mouseDir = maus.drehe(exitDir[xy.x][xy.y]);
    // println("last=" + lastMouseEntry + " new=" + mouseDir);
    if (lastMouseEntry == mouseDir && skipEntry == true) {
      mouseDir = maus.drehe(mouseDir);
      skipEntry = false;
    }
    exitDir[xy.x][xy.y] = mouseDir;
    maus.bewege(1, mouseDir);
    return;
  }
  // Fahrmodus
  // Ziel erreicht?
  if (maus.trifftZiel()) {
      pause = true;
      fahrZaehler = 0;
      return;
    }
  if (fahrZaehler > 25) {
    suchModus = true;
    return;
  }
  fahrZaehler += 1;
  println(fahrZaehler);
  maus.bewege(1, exitDir[xy.x][xy.y]);
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
  text("Version 0.1", 650, 50);
  text("Click fence to change", 650, 100);
  text("Click inside to set or turn mouse", 650, 125);
  text("Right click inside to set goal ", 650, 150);
  text("Blank = Pause, Q = Quit", 650, 175);
  text("+ = quicker, - = slower; actual: "+maus.speed, 650, 200);
  text("G = Get, P = Put fences in/from file", 650, 225);
  text("D = direction of turn change", 650, 250);
  text("Initial directions: E(ast), W(est), N(orth), S(outh)", 650, 275);
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
  helptexts();
  textSize(14);
  text(movecount+" moves", 300, 50);
  if (fencesFile != null) {
    if (fences.changed)
      text("Changed: " + fencesFile, 100, 650);
    else
      text("File: " + fencesFile, 100, 650);
  }
  if (pause) text("Pause", 100, 50);
  if (suchModus) 
    text("Explore mode ...      ", 150, 50);
  else
    // text("Goal mode" + fahrZaehler + "  " , 150, 50);
    text("Goal mode" , 150, 50);

  textSize(28);
  if (maus.clockwise) 
    text("\u21b7", 450, 50);
  else
    text("\u21B6", 450, 50);  
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
