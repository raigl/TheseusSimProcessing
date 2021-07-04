/* 
 Feldbegrenzungen (Zäune)
 Die 25 Felder werden relativ zu 1 als (1,1) bis (5,5) adressiert.
 Die Randzäune und die inneren Zäune werden in zwei
 Arrays für West-Ost und Nord-Süd gespeichert:
 ---   ---   ---   ---   ---
 | 1,1 | 1,2 | 1,3 | 1,4 | 1,5 |
 ---   ---   ---   ---   ---
 | 2,1 | 2,2 | 2,3 | 2,4 | 2,5 |
 ---   ---   ---   ---   ---
 | 3,1 | 3,2 | 3,3 | 3,4 | 3,5 | 
 ---   ---   ---   ---   ---
 | 4,1 | 4,2 | 4,3 | 4,4 | 4,5 | 
 ---   ---   ---   ---   ---
 | 5,1 | 5,2 | 5,3 | 5,4 | 5,5 |
 ---   ---   ---   ---   ---
 
 Unter Einschluss der Randzäune sind es 5 Zeilen (y) mit 6 Spalten (x) für West-Ost,
 und 6 Zeilen mit 5 Spalten für Nord-Süd.
 
 Aus der 1-basierten Feld-Koordinate (x, y) ist dann der jeweilige Zaun 0-basiert:
 - nördlich: auf (x-1, y-1) in NS
 - südlich:  auf (x-1, y) in NS
 - westlich: auf (x-1, y-1) in WE
 - östlich:  auf (x,   y-1) in WE
 
 
 
 */

class Fences {

  // Feld-Begrenzer (0-basierte Feldkoordinaten)
  boolean fencesNS[][] = new boolean[5][6];
  boolean fencesWE[][] = new boolean[6][5];
  boolean changed = false;
  // Initialisierung
  Fences() {
    // Alle mit keinem Zaun vorbesetzen
    for (int i=0; i<5; ++i)
      for (int j=0; j<6; ++j) {
        fencesNS[i][j] = false;
        fencesWE[j][i] = false;
      }

    // Randzäune setzen:
    for (int i=0; i<5; ++i) {
      fencesNS[i][0] = true;
      fencesNS[i][5] = true;
      fencesWE[0][i] = true;
      fencesWE[5][i] = true;
    }

    // einen inneren Zaun südlich von 1,1 setzen:
    fencesNS[0][1] = true;
  }

  /*
    Setzen und Löschen von Zäunen mit Feld-Koordinate
   */

  /* Hat Feld (x,y) einen aktiven Zaun in Richtung (dir) ?
   Die Randzäune werden auch aus dem Array abgefragt
   */
  boolean isFence(int x, int y, int dir) {
    if (dir==north) {
      return fencesNS[x-1][y-1];
    }
    if (dir==south) {
      return fencesNS[x-1][y];
    }
    if (dir==west) {
      return fencesWE[x-1][y-1];
    }
    if (dir==east) {
      return fencesWE[x][y-1];
    }
    return false;
  }

  /* Zeichne die Zäune und Pfosten
   mehrfaches Zeichnen braucht nicht unterdrückt zu werden
   */
  void draw() {
    // Zäune
    for (int x=1; x<6; ++x)
      for (int y=1; y<6; ++y) {

        if (isFence(x, y, north)) 
          fill(black);
        else 
          fill(white);
        rect(x*raster, y*raster-fencewidth/2, raster, fencewidth);  

        if (isFence(x, y, south)) 
          fill(black);
        else 
          fill(white);
        rect(x*raster, (y+1)*raster-fencewidth/2, raster, fencewidth);   

        if (isFence(x, y, west)) 
          fill(black);
        else 
          fill(white);
        rect(x*raster-fencewidth/2, y*raster-fencewidth/2, fencewidth, raster );   

        if (isFence(x, y, east)) 
          fill(black);
        else 
          fill(white);
        rect((x+1)*raster-fencewidth/2, y*raster, fencewidth, raster);
      }

    // Pfosten zeichnen (kaschiert die Übergänge)
    fill(black);
    for (int i=1; i<7; ++i)
      for (int j=1; j<7; ++j)
        circle(i*raster, j*raster, fencewidth*2);
  }

  // Feldkoordinaten aus Bildschirmkoordinaten
  Punkt fieldXY(int x, int y) {
    Punkt res = new Punkt(x / raster, y / raster);
    return res;
  }

  /* Prüfe, ob die Maus einen Zaun in einer Richtung berührt:
   - bestimme Feldkoordinate
   - ist in der Richtung ein Zaun?
   - bestimme Abstand zum Zaun
   */

  // Zaunelement im Westen ? 
  boolean isFenceW(int x, int y) {
    Punkt pt = fieldXY(x, y);
    // ist ein Zaunelement im Westen aktiv?
    if (!isFence(pt.x, pt.y, west))
      return false;    // nein
    // Schirmkoordinate des Zaunelements
    int fenceX = pt.x*raster;
    // Abstand in X-Richtung
    int dist = x - fenceX;
    return dist < raster/4;
  }  

  // Zaunelement im Osten ? 
  boolean isFenceE(int x, int y) {
    Punkt pt = fieldXY(x, y);
    // ist ein Zaunelement im Osten aktiv?
    if (!isFence(pt.x, pt.y, east))
      return false;    // nein
    // Schirmkoordinate des Zaunelements
    int fenceX = (pt.x+1)*raster;
    // Abstand in X-Richtung
    int dist = fenceX - x;
    return dist < raster/4;
  }  

  // Zaunelement im Norden ? 
  boolean isFenceN(int x, int y) {
    Punkt pt = fieldXY(x, y);
    // ist ein Zaunelement im Westen aktiv?
    if (!isFence(pt.x, pt.y, north))
      return false;    // nein
    // Schirmkoordinate des Zaunelements
    int fenceY = pt.y*raster;
    // Abstand in X-Richtung
    int dist = y - fenceY;
    return dist < raster/4;
  }  

  // Zaunelement im Süden ? 
  boolean isFenceS(int x, int y) {
    Punkt pt = fieldXY(x, y);
    // ist ein Zaunelement im Osten aktiv?
    if (!isFence(pt.x, pt.y, south))
      return false;    // nein
    // Schirmkoordinate des Zaunelements
    int fenceY = (pt.y+1)*raster;
    // Abstand in X-Richtung
    int dist = fenceY - y;
    return dist < raster/4;
  }  



  /*
    Interakives Setzen und Entfernen von Zäunen
   */

  // West-Ost-Zaun umschalten (Bildschirm-Koordinaten)
  boolean flipWE(int x, int y) {
    int x1 = x + fencewidth/2;
    int y1 = y - raster/4;
    if (x1%raster <= fencewidth && y1%raster <= raster/2) {
      int x2 = x1/raster - 1;
      int y2 = y1/raster - 1;
      if (x2 > 0 && x2 < fencewidth/2 && y2 >= 0 && y2 < fencewidth/2) {
        if (fencesWE[x2][y2] == true)
          fencesWE[x2][y2] = false;
        else
          fencesWE[x2][y2] = true;
        changed = true;
        return true;
      }
    }
    return false;
  }

  // Nord-Süd-Zaun umschalten
  boolean flipNS(int x, int y) {
    int y1 = y + fencewidth/2;
    int x1 = x - raster/4;
    if (y1%raster <= fencewidth && x1%raster <= raster/2) {
      int y2 = y1/raster - 1;
      int x2 = x1/raster - 1;
      if (y2 > 0 && y2 < fencewidth/2 && x2 >= 0 && x2 < fencewidth/2) {
        if (fencesNS[x2][y2] == true)
          fencesNS[x2][y2] = false;
        else
          fencesNS[x2][y2] = true;
        changed = true;
        return true;
      }
    }
    return false;
  }


  // Zaun ändern, wenn Koordinaten im Zaun liegen
  // true, wenn geändert; false sonst
  boolean flip(int x, int y) {
    if (flipWE(x, y)) return true;
    if (flipNS(x, y)) return true;
    return false;
  }
  
  /* Aktuelles Brett abspeichern */
  void saveFences(String filename) {
    println("Going " + filename);
    String[] brett = new String[11];
    String zeile = new String();
    for (int i = 0; i < 6; ++i) {
      zeile = "+";
      for (int j = 0; j < 5; ++j) {
        if (fencesNS[j][i])
            zeile += "--";
        else
            zeile += "  ";
        zeile += "+";
      }
      brett[i*2] = zeile;
    }
   for (int i = 0; i < 5; ++i) {
      zeile = "";
      for (int j = 0; j < 6; ++j) {
        if (fencesWE[j][i])
            zeile += "|";
        else
            zeile += " ";
        zeile += "  ";
      }
      brett[i*2+1] = zeile;
      
    }
   saveStrings(filename, brett);
   println("Saved to " + filename);
  }
  
  /* Brett aus Datei laden */
  void loadFences(String filename) {
    String[] brett = loadStrings(filename);
    String zeile;
    if (brett == null) return;
    changed = false;
   
    // alle Nord-Süd Eintraege:
    for (int i = 0; i < 6; ++i) {
      zeile = brett[i*2];
      for (int j = 0; j < 5; ++j) {
        println(zeile);
        if (zeile.charAt(j*3+1) == '-')
           fencesNS[j][i] = true;
        else
           fencesNS[j][i] = false;
      }
    }

    // alle West-Ost Eintraege:
    for (int i = 0; i < 5; ++i) {
      zeile = brett[i*2+1];
      for (int j = 0; j < 6; ++j) {
        if (zeile.charAt(j*3) == '|')
           fencesWE[j][i] = true;
        else
           fencesWE[j][i] = false;
      }
    }
  }
}
