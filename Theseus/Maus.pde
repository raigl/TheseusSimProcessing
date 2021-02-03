/*
  The Maus Class encapsulates the Maze-mouse movement 
  similar to the hardware module
 */

class Maus {

  // Bildschirmkoordinaten
  int pixX=0, pixY=0;
  
  // Richtung und Geschwindigkeit der Bewegung
  char mausDir = north;
  int speed = 4;  // Teiler von 10 wg. Feldmittenerkennung ?
  int fieldLimit = 1;  
  
  // Ursache des Anhaltens:
  int stopcode = 0;   // Zaun = 1  Mitte = 2
  
  // In Bewegung?
  boolean busy = false;
  // in der Mitte anhalten
  boolean wasFence = false;
  // Drehrichtung
  boolean clockwise = false;

  // Initialisieren
  Maus() {
   pixX = raster + raster/2;
   pixY = pixX;
  }

  // neue Richtung entgegen dem Uhrzeigersinn
  char drehe(char alt) {
    if (clockwise) {
      if (alt == north) return east;
      if (alt == east) return south;
      if (alt == south) return west;

    } else {
      if (alt == north) return west;
      if (alt == west) return south;
      if (alt == south) return east;
    }
    return north;
  }
 
/* Maus setzen, wenn die Bildschirmkoordinaten in der Mitte 
   eines Feldes sind. 
   Wenn schon dort, drehen
*/
boolean setXY(int x, int y) {
  int x1 = x - raster/4;
  int y1 = y - raster/4;
  if (x1%raster < raster/2 && y1%raster < raster/2) {
    x1 = x - x%raster + raster/2;
    y1 = y - y%raster + raster/2;
    if (x1 < 100 || x1 > 600 || y1 < 100 || y1 > 600)
      return false;
    println(y1);
    if (pixX == x1 && pixY == y1) 
       mausDir = drehe(mausDir);
    // setzen, auch wenn schon gleich
    pixX = x1;
    pixY = y1;

    return true;
  }
  return false;
}

  // zeige aktuelle Position der Maus
  void show() {
    fill(blue);
    int d = fencewidth;
    if (mausDir == east)
      triangle(pixX-d, pixY-d, pixX-d, pixY+d, pixX+2*d, pixY);
    if (mausDir == west)
      triangle(pixX+d, pixY+d, pixX+d, pixY-d, pixX-2*d, pixY);
    if (mausDir == north)
      triangle(pixX-d, pixY+d, pixX+d, pixY+d, pixX, pixY-2*d);
    if (mausDir == south)
      triangle(pixX-d, pixY-d, pixX+d, pixY-d, pixX, pixY+2*d);
  }

  // Maus auf Feldmitte ausichten (für schnelle Bewegung)
  void alignMouse() {
      pixX = (pixX / raster) * raster + raster/2;
      pixY = (pixY / raster) * raster + raster/2;
  }
  
  /* Bewege die Maus um einen Schritt in die aktuelle Richtung.
     Halte an, wenn ein Zaun erreicht ist oder die Maximalzahl 
     Befindet sich die Maus in Feldmitte und ist die Maximalzahl
     noch nicht verbraucht, wird erst die Feldmitte verlassen.
   */
  void voran() {

    if (inFeldmitte()) {
        // Anzahl Schritte bei Erreichen der Feldmitte erschöpft?
        if (fieldLimit == 0) {
           // ja, Ende der Reise
           busy = false;
           stopcode = 2;
           alignMouse();
           return;
        }
        // Wenn in Feldmitte und noch Schritte übrig, 
        // Feld von Feldmitte aus verlassen
        advance();
        if (!inFeldmitte())
          fieldLimit -= 1;
        // neue runde
        return;
    }
   
     // Falls am Zaun, 
     advance();
     // Zaun erreicht? dann Anhalten
     if (trifftZaun()) {
       stopcode = 1;
       // alignMouse();
       busy = false;
     }
 

     return;
  }
/*  Prüfe, ob in Feldmitte
    Berechne den Abstand zur Feldmitte
    und vergleiche mit Geschwindigkeitsinkement
*/

boolean inFeldmitte() {
    int deltax = abs(pixX % raster - raster/2);
    int deltay = abs(pixY % raster - raster/2);

    if (deltax <= 2*speed && deltay <= 2*speed) 
      return true;
    
    return false;
}
  /* ****************
   Mausbewegungen
   **************
   */

void advance() {
      // Maus in die passende Richtung bewegen
    if (mausDir == north) pixY -= speed;
    if (mausDir == south) pixY += speed;
    if (mausDir == west)  pixX -= speed;
    if (mausDir == east)  pixX += speed;
}

/* Prüfe auf Zaunberührung
   Eine Berühung ist gegeben, wenn die Maus in Laufrichtung weniger als
   ein halbes Raster von einem Zaun entfernt ist. 
   Somit kann sie ohne weiteres wieder vom Zaun entfernt werden,
   wenn sie zuvor umgedreht wird.
*/
boolean trifftZaun() {
  if (mausDir == north)
    return fences.isFenceN(pixX, pixY);      
  if (mausDir == west)
    return fences.isFenceW(pixX, pixY);    
  if (mausDir == south)
    return fences.isFenceS(pixX, pixY);
  if (mausDir == east)
    return fences.isFenceE(pixX, pixY); 
    
    return false;
} 
/* Ziel erreicht?
*/
boolean trifftZiel() {
    if (goal.x == pixX/raster && goal.y == pixY/raster)
      return true;
    return false;
} 
  /* 
   Starte eine Bewegung der Maus um (cnt) Felder in Richtung (dir)
   * Der erste Parameter gibt die Anzahl der Felder an
   * der zweite die Richtung.
   * Wenn ein Zaun angetroffen wird, stoppt die Maus.
   * Wenn die Anzahl Null ist, wird an der nächsten Feldmitte angehalten;
   * wenn schon in Feldmitte, keine Bewegung; in beiden Fällen return 0
   * Andernfall wird zunächst die Feldmitte verlassen und sodann
   * die Anzahl der neu erreichten Feldmitten gezählt und
   * zurückgegeben; maximal bis zur Zahl im ersten Parameter.
   */
void bewege(int cnt, char dir) {
    fieldLimit = cnt;
    mausDir = dir;
    stopcode = 0;
    busy = true;
  }
 
 // gibt die Feldkoordinaten (1-basiert)
 Punkt whereis() {
   Punkt ret = new Punkt(pixX / raster, pixY / raster);
   return ret;
 }
 
   
   
}
