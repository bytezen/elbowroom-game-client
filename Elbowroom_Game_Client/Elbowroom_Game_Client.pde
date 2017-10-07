/*
*  ElbowRoom 
 *  Inspired by Robert Ingram, Victoria University of Wellington
 *  MDDN242, 2014
 */
import java.util.Map;

boolean DEV = false
  , manualOverride =  true;

Map<String, Player> playerChannelMap = new HashMap<String, Player>();

ArrayList<Player> players;
ArrayList<PVector>startingBlocks;
static int PLAYERS = 20;
static int PLAYER_SIZE = 3; //Note this affects the speed; bigger players move faster

PGraphics mainG, playerLayer;
CollisionSystem collider;

//color to compare for collision
int BGCOLOR = 0; 
//int RED, GREEN, BLUE;

ColorAPI colorAPI;

void setup() {
  size(1000, 800);
  //fullScreen();
  noCursor();
  noSmooth();
  strokeCap(SQUARE);

  initSpacebrewConnection();
  colorAPI = new ColorAPI();


  //initialize starting Blocks
  startingBlocks = new ArrayList(PLAYERS);
  for (int i=0; i < PLAYERS; ++i) {
    if ( i < PLAYERS / 2 ) {
      startingBlocks.add(new PVector( (i+1)*0.1*0.95*width, 0.05*height ));
    } else {
      startingBlocks.add(new PVector( ((int(i - PLAYERS / 2)) + 0.5)*0.1*0.95*width, 0.95*height ));
    }
  }

  //initialize players
  players = new ArrayList(PLAYERS);
  //Player p;
  for (int i=0; i < PLAYERS; ++i) {
    float x, y;
    Direction d;
    int col = colorAPI.getColor();

    //if ( i < PLAYERS / 2 ) {
    x = startingBlocks.get(i).x; //(i+1)*0.1*0.95*width;
    y = startingBlocks.get(i).y; //0.05*height;
    d = Direction.NONE; //Direction.DOWN;

    players.add( new Player(getPlayerName(i), x, y, col, d) );
    //initSpacebrewPlayerChannel(p);
  }

  //Initialize spacebrew player channel

  for (Player p : players ) {
    initSpacebrewPlayerChannel(p);
  }

  stroke(0);
  rect(3, 3, width-6, height-6);
  textSize(10);

  //setup player drawing layer
  mainG = getGraphics();
  playerLayer = mainG;

  BGCOLOR = color(255);

  playerLayer.loadPixels();
  collider = new CollisionSystem(playerLayer.pixels.length, width);
  collider.clearBuffer();

  //setup setupScreen Layer
  setupLayer = createGraphics(width, height);

  // on start go ahead and get into setup Mode and start the timer
  gameStartTimer.setTimer();

  //should be all set to make the internets magic happen now
  spacebrewConnect();
}

void  update() {
  playerLayer.loadPixels();
  int pxlIndex, pxlColor;
  boolean isJumping = false;

  for ( Player p : players ) {
    p.update();
    if ( (p.x() < 0 || p.x() > width ) ||
      (p.y() < 0 || p.y() > height ) ) {
      
      p.die();
    }
    //if(isCollided(p)) {
    //  p.die();
    //}
  }

  for (Player p : players ) {
    if (p.alive && p.active && !p.isJumping()) {
      if (collider.playerCollision(p)) {
        p.die();
      }
    }

    p.resetFlags();
  }
}


void  draw() {
  update();

  for (Player p : players ) {
    if (p.active) {
      p.render(mainG);
      if(p.alive) {
      collider.renderPlayer(p);
      }
    }
  }

  if (currentMode == GameMode.Setup) {
    renderSetupMode(setupLayer);
    image(setupLayer, 0, 0);

    if (gameStartTimer.timerUp) {
      background(255);

      currentMode = GameMode.Running;
      //startEmUp();
      for (Player p : players) {

        //turn on everyone for kicks and giggles
        //comment this out for playing with only
        //registered users
        p.active = true;

        //if (p.name.equals("player5")) { 
        //  p.active = true;
        //}

        if (p.active) {
          //p.speed = 1;
          p.alive = true;
          if (p.getPos().y > height * 0.5) {
            p.direction = Direction.UP;
          } else {
            p.direction = Direction.DOWN;
          }
        }
      }
    }
  }

  //output framerate
  if (DEV) {
    fill(50);
    rect(0, 0, 100, 50);
    fill(200);
    text("fps: " + frameRate, 5, 20);
  }
}


void keyPressed() {
  if (key=='r') {
    resetGame();
  }

  if (manualOverride) {
    manualControls();
  }
}

void resetGame() {
  currentMode = GameMode.Setup;

  //reset the player image layer
  playerLayer.beginDraw();
  background(BGCOLOR);
  playerLayer.endDraw();
  //reset players
  for (Player p : players) {
    p.reset();
  }
  //reset timer to allow folks to join
  gameStartTimer.reset();
  collider.clearBuffer();
  //send the reset message to the clients so that they can join?
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