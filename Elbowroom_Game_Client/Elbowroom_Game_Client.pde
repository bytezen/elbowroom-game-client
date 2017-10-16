/*
*  ElbowRoom 
 *  Inspired by Robert Ingram, Victoria University of Wellington
 *  MDDN242, 2014
 */
import java.util.Map;
import java.util.List;
import java.util.Arrays;

boolean DEV = false
  , manualOverride =  true;

Map<String, Player> playerChannelMap = new HashMap<String, Player>();

ArrayList<Player> players, newPlayers, oldPlayers;
ArrayList<PVector>startingBlocks;
static int PLAYERS = 20;
static int PLAYER_SIZE = 3; //Note this affects the speed; bigger players move faster

PGraphics mainG;//, playerLayer;
CollisionSystem collider;

//color to compare for collision
int BGCOLOR = 0; 
//int RED, GREEN, BLUE;

ColorAPI colorAPI;
GameScreen currentScreen, playScreen, joinScreen;


void setup() {
  size(1000, 800);
  //fullScreen();
  noCursor();
  noSmooth();
  strokeCap(SQUARE);

  channelMap = new HashMap();
  clientPlayerMap = new HashMap();
  players = new ArrayList<Player>();
  newPlayers = new ArrayList<Player>();
  oldPlayers = new ArrayList<Player>();

  subscriptions = new ArrayList<Sub>();
  routes = new ArrayList<JSONObject>();


  initSpacebrewConnection();
  colorAPI = new ColorAPI();


  joinScreen = new JoinScreen(width, height);
  playScreen = new PlayScreen(int(width*0.5), int(0.5*height));
  currentScreen = joinScreen;


  //initialize starting Blocks
  /*
  startingBlocks = new ArrayList(PLAYERS);
   for (int i=0; i < PLAYERS; ++i) {
   if ( i < PLAYERS / 2 ) {
   startingBlocks.add(new PVector( (i+1)*0.1*0.95*width, 0.05*height ));
   } else {
   startingBlocks.add(new PVector( ((int(i - PLAYERS / 2)) + 0.5)*0.1*0.95*width, 0.95*height ));
   }
   }
   */


  background(100,100,100);
  stroke(0);
  rect(3, 3, width-6, height-6);
  textSize(10);

  //setup player drawing layer
  mainG = getGraphics();
  //playerLayer = mainG;
  //playerLayer = createGraphics(width, height);
  //playerLayer.beginDraw();
  //playerLayer.background(255);
  //playerLayer.endDraw();

  BGCOLOR = color(255);

  //playerLayer.loadPixels();
  //collider = new CollisionSystem(playerLayer.pixels.length, width);
  int playScreenPixels = ((PlayScreen)playScreen).renderWidth() * ((PlayScreen)playScreen).renderHeight();
  collider = new CollisionSystem(playScreenPixels, ((PlayScreen)playScreen).renderWidth());  
  collider.clearBuffer();

  //setup setupScreen Layer
  joinLayer = createGraphics(width, height);

  // on start go ahead and get into setup Mode and start the timer
  gameStartTimer.setTimer();

  //should be all set to make the internets magic happen now
  spacebrewConnect();
}

void  update() {
  //playerLayer.loadPixels();
  int pxlIndex, pxlColor;
  boolean isJumping = false;

  //if(players.size() > 0) { 
  //  println(players.size() + " players to update ");
  //}

  // add any players that have joined the game
  if (newPlayers.size() > 0 ) {
    println("[update] adding players to the game...");
    for ( Player p : newPlayers ) {
      players.add(p);
    }
    newPlayers.clear();
    println("[update] current players: " + players);
  }

  //remove anyone that has left the game
  if ( oldPlayers.size() > 0) {
    println("[update] removing players from the game...");
    for ( Player p : oldPlayers ) {
      players.remove(p);
    }
    oldPlayers.clear();
    println("[update] current players: " + players);
  }

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

  //update screens
  ///*
  if (currentMode == GameMode.Join ) {
    currentScreen = joinScreen;
  } else if ( currentMode == GameMode.Running ) {
    currentScreen = playScreen;
  } else {
    currentScreen = joinScreen;
  }

  if (gameStartTimer.timerUp && currentMode == GameMode.Join) {
    currentMode = GameMode.Running;

    //clear the background
    mainG.beginDraw();
    mainG.background(200,0,100);
    mainG.endDraw();

    //initialize start position for joined players
    calculateStartingPositions(int(((PlayScreen)playScreen).renderWidth())
      , int(((PlayScreen)playScreen).renderHeight()));

    for (Player p : players) {
      p.resetPosition();
      //turn on everyone for kicks and giggles
      //comment this out for playing with only
      //registered users
      //p.active = true;

      if (p.active) {
        //p.speed = 1;
        p.alive = true;
        if (p.getPos().y > height * 0.5) {
          p.direction = Direction.UP;
        } else {
          p.direction = Direction.DOWN;
        }
      }
      //*/
    }
  }
}


void  draw() {
  update();

  currentScreen.render();
  currentScreen.display(mainG);

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
  currentMode = GameMode.Join;

  //reset the player image layer
  //playerLayer.beginDraw();
  background(BGCOLOR);
  //playerLayer.endDraw();
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