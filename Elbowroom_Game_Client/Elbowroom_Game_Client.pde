import java.util.Map;

boolean DEV = true;

Map<String, Player> playerChannelMap = new HashMap<String, Player>();

ArrayList<Player> players;
static int PLAYERS = 20;
static int PLAYER_SIZE = 1; //Note this affects the speed; bigger players move faster

PGraphics mainG, playerLayer;

//color to compare for collision
int BGCOLOR = 0; 
ColorAPI colorAPI;

void setup() {
  size(1000, 800);

  initSpacebrewConnection();
  colorAPI = new ColorAPI();

  //initialize players
  players = new ArrayList(PLAYERS);
  Player p;
  for (int i=0; i < PLAYERS; ++i) {
    float x, y;
    Direction d;
    int col = colorAPI.getColor();
    
    if ( i < PLAYERS / 2 ) {
      x = (i+1)*0.1*width;
      y = 0.1*height;
      d = Direction.DOWN;
    } else {
      x = ((int(i - PLAYERS / 2)) + 0.5)*0.1*width;
      y = 0.9*height;
      d = Direction.UP;
    }

    p = new Player(getPlayerName(i), x, y, col, d);
    players.add(p);
    initSpacebrewPlayerChannel(p);

    //here setup Spacebrew mapping
    //could also create the spacebrew sub/pub
  }

  stroke(0);
  rect(3, 3, width-6, height-6);
  textSize(10);

  //setup player drawing layer
  mainG = getGraphics();
  playerLayer = mainG;
  BGCOLOR = color(255);
  background(BGCOLOR);



  spacebrewConnect();
}

void  update() {
  playerLayer.loadPixels();
  int pxlIndex, pxlColor;

  for ( Player p : players ) {
    if (p.alive) {
      p.update();
      //check to see if we are on a color
      //pixel at position
      //pxlIndex = floor(p.getPos().y*width + p.getPos().x); 
      //pxlColor = playerLayer.pixels[pxlIndex];
      //if (red(pxlColor) + green(pxlColor) + blue(pxlColor) > 0 ) {
      //  p.die();
      //}
      if(onColoredPixel(int(p.getPos().x),int(p.getPos().y), playerLayer, BGCOLOR)) {
        p.die();
      }
      
      //pixel at position is colored
      //if so the p.die()
    }
  }
}


void  draw() {
  update();
  for (Player p : players ) { 
    p.render(mainG);
  }

  //output framerate
  if (DEV) {
    fill(50);
    rect(0, 0, 100, 50);
    fill(200);
    text("fps: " + frameRate, 5, 20);
  }
}

boolean onColoredPixel(int x, int y,PGraphics layer, int bgColor) {
  int pxlIndex = floor(y*width + x); 
  if(pxlIndex >= layer.pixels.length || pxlIndex < 0) {
    return false;
  }
  
  int pxlColor = layer.pixels[pxlIndex];
  int R = int(red(BGCOLOR)),
      G = int(green(BGCOLOR)),
      B = int(blue(BGCOLOR));
  //println("[onColoredPixel BGCOLOR (r,g,b)] " + R + "," + G + "," + B);
  //println("[onColoredPixel (r,g,b)] " + red(pxlColor) + "," + green(pxlColor) + "," + blue(pxlColor));
  return ( ( red(pxlColor) != R ) && 
           ( green(pxlColor) != G) &&
           ( blue(pxlColor) != B ));
    
}

public enum Direction {
  UP, DOWN, LEFT, RIGHT, NONE
}

String getPlayerName(int i) {
  return "player"+i;
}

Direction directionFromString(String dir) {

  if (dir.equals("up")) return Direction.UP;
  if (dir.equals("down")) return Direction.DOWN;
  if (dir.equals("left")) return Direction.LEFT;
  if (dir.equals("right")) return Direction.RIGHT;

  return Direction.NONE;
}