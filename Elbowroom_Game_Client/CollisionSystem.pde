/*
 *
 * Manual Control and Collision
 *
 *
 */

// -------------
// -------------
// Collision Logic
// -------------
// -------------

class CollisionSystem {
  private int[] pixelBuffer;
  private int _w;
  private int clearColor = color(255);

  //CollisionSystem() {
  //}

  CollisionSystem(int size, int _width) {
    pixelBuffer = new int[size];
    _w = _width;
  }

  void clearBuffer() {
    for (int i=0; i < pixelBuffer.length; i++) {
      writeToBuffer(i, clearColor);
    }
  }

  //use the internal buffer for collision 
  boolean pixelCollision( int index, int bgcolor ) {
    return pixelCollision(index, pixelBuffer, bgcolor );
  }

  boolean pixelCollision( int index, int[] pxls, int bgcolor ) {
    if (index < 0 || index >= pxls.length) { 
      return false;
    }         
    return pxls[index] != bgcolor;
  }

  int getBufferIndex( int x, int y) {
    return floor(y*_w + x);
  }
  // block out the player path in the buffer
  // this does not account for stroke rendering 
  // and so it may be off by a pixel  and there
  // this should be good enough for collision detection though
  void renderPlayer(Player p) {
    int dx = p.x() - p.prevX();
    int dy = p.y() - p.prevY();
    int x = p.prevX();
    int y = p.prevY();
    int ind = 0;    
    int incx, incy;
    int steps = max(abs(dx), abs(dy));

    if (dx < 0 ) { 
      incx = -1;
    } else if (dx > 0) { 
      incx = 1;
    } else { 
      incx = 0;
    }

    if (dy < 0 ) { 
      incy = -1;
    } else if (dy > 0) { 
      incy = 1;
    } else { 
      incy = 0;
    }

    int limit = 10; //for debug
    while ( steps > 0 && limit > 0) {
      x += incx;
      y += incy; 
      ind = getBufferIndex(x, y);
      if (ind < 0 || ind >= pixelBuffer.length) {
        println("ArrayOutBounds: "+ ind);
        break;
      }

      writeToBuffer(ind, p.c);

      limit--;
      steps--;
    }
  }

  void writeToBuffer(int ind, int val) {
    pixelBuffer[ind] = val;
  }

  boolean playerCollision(Player p) {
    int dx = p.x() - p.prevX();
    int dy = p.y() - p.prevY();
    int x = p.prevX();
    int y = p.prevY();
    int ind;    
    int incx, incy;
    int steps = max(abs(dx), abs(dy));

    if (dx < 0 ) { 
      incx = -1;
    } else if (dx > 0) { 
      incx = 1;
    } else { 
      incx = 0;
    }

    if (dy < 0 ) { 
      incy = -1;
    } else if (dy > 0) { 
      incy = 1;
    } else { 
      incy = 0;
    }

    int limit = 10; //for debug
    while ( steps > 0 && limit > 0) {
      x += incx;
      y += incy; 
      ind = getBufferIndex(x, y);
      if (ind < 0 || ind >= pixelBuffer.length) {
        println(">>> ArrayOutBounds: "+ ind);
        return true;
      }

      if (pixelCollision(ind, clearColor)) {
        println("COLLISION");
        return true;
      }

      limit--;
      steps--;
    }
    //println();    

    return false;
  }
}

int getPixelIndex( int x, int y) {
  return floor(y*width + x);
}


// -------------
// -------------
// MANUAL CONTROL
// -------------
// -------------


void manualControls() {

  Player manual = getPlayer("player5");

  if (manual != null ) {
    if (keyCode == LEFT || key == 'a' ) { 
      move(manual.name, Direction.LEFT);
    }
    if (keyCode == RIGHT || key == 'd'  ) { 
      move(manual.name, Direction.RIGHT);
    }
    if (keyCode == UP || key == 'w' ) { 
      move(manual.name, Direction.UP);
    }
    if (keyCode == DOWN || key == 's' ) { 
      move(manual.name, Direction.DOWN);
    }   

    if (key == ' ' ) {
      move(manual.name, "jump");
    }
    //if(keyCode == LEFT ) { move(manual.name, "left"); }
    //if(keyCode == RIGHT ) { move(manual.name, "right");  }
    //if(keyCode == UP ) { move(manual.name, "up"); }
    //if(keyCode == DOWN ) { move(manual.name, "down"); }
  }
}

Player getPlayer(String id) {
  for (Player p : players ) {
    if (p.name.equals(id)) {
      return p;
    }
  }
  return null;
}


void move(String playerid, Direction d) {
  for (Player p : players) {
    if ( p.name.equals(playerid) ) {
      println("move player:: " + p.name );
      p.changeDirection(d);
    }
  }
}


void move(String playerid, String direction) {

  onStringMessage(playerid, direction);
}