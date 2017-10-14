float WAIT_TIME =  100000;//150000;
PGraphics setupLayer; 
Timer gameStartTimer = new Timer(WAIT_TIME);
GameMode currentMode = GameMode.Setup;


class Timer {
  float finalT = 0;
  float duration = WAIT_TIME;
  boolean timerUp = false;

  Timer(float d) {
    duration = d;
  }

  void setDuration(float t) { 
    duration = t;
  }

  float setTimer() {
    finalT = millis() + duration;
    return seconds();
  }

  void reset() {
    setTimer();
    timerUp = false;
  }

  float seconds() {
    float t = constrain(finalT - millis(), 0, duration) * .001;
    if (t <= 1.0 ) {
      timerUp = true;
    }
    return t;
  }
}


public enum GameMode {
  Setup, Running
}

void renderSetupMode(PGraphics layer) {
  float lMargin = 0.10*width;
  int cursor = 0;
  float offset = 30;

  layer.beginDraw();
  layer.strokeWeight(3.0);
  //layer.background(50);
  layer.stroke(200);
  layer.fill(50, 100);
  layer.rect(10, 10, layer.width-20, layer.height-20);

  layer.textSize(64);
  layer.textAlign(CENTER);
  layer.fill(255);
  layer.text("Elbow Room", 0.5 * width, 0.5 * layer.height); //lMargin, 0.10 * layer.height );
  //layer.textAlign(LEFT);
  layer.textSize(32);
  //layer.text("players in the room: ", 0.5 * width, 0.55 * layer.height);
  layer.fill(200, 0, 50);
  layer.text("elbows start flying in ... ", 0.5 * width, 0.55 * layer.height);
  layer.textSize(64);  
  layer.text(""+Math.floor(gameStartTimer.seconds()), 0.5 * width, 0.65 * layer.height);



  for (Player p : players) {
    if (p.active) {
      layer.pushStyle();
      layer.fill(p.c);
      layer.textSize(16);
      layer.textAlign(CENTER);
      layer.text(p.name, p.initPos.x, p.initPos.y);
      layer.popStyle();
      cursor++;
    }
  }

  layer.endDraw();
}


class PlayScreen implements GameScreen {
  PGraphics _layer;
  PlayScreen(int w, int h) {
    _layer = createGraphics(w, h);
  }

  void render() {
    _layer.beginDraw();
    for (Player p : players ) {
      if (p.active) {
        //p.render(mainG);
        p.render(_layer);
        if (p.alive) {
          collider.renderPlayer(p);
        }
      }
    }
    _layer.endDraw();

    //image(layer,0,0);
  }

  void display(PGraphics pg, int x, int y) {
    pg.image(_layer, x, y);
  }

  GameMode mode() {
    return GameMode.Running;
  }
}


/*
 *   JOIN SCREEN
 */
class JoinScreen implements GameScreen {
  PGraphics _layer;


  JoinScreen(int w, int h) {
    _layer = createGraphics(w, h);
  }

  void render() {
    float lMargin = 0.10*width;
    PVector cursor = new PVector(0.5 * _layer.width, 0.1 * _layer.height);
    float lineHeight = 40;
    float offset = 30;


    _layer.beginDraw();
    _layer.strokeWeight(3.0);

    _layer.stroke(200);
    _layer.fill(50, 100);
    _layer.rect(10, 10, _layer.width-20, _layer.height-20);

    //elbow text
    _layer.textSize(64);
    _layer.textAlign(CENTER);
    _layer.fill(255);
    _layer.text("Elbow Room", cursor.x, cursor.y); //lMargin, 0.10 * _layer.height );

    cursor.y += (3.0 * lineHeight);

    _layer.textSize(32);
    _layer.fill(200, 0, 50);
    _layer.text("elbows start flying in ... ", cursor.x, cursor.y);

    //timer text
    cursor.y += (1.75 * lineHeight);
    _layer.textSize(64);  
    _layer.text(""+Math.floor(gameStartTimer.seconds()), cursor.x, cursor.y);

    cursor.y += (3.0* lineHeight);
    _layer.textSize(32);
    _layer.fill(200, 200, 200);
    _layer.text("players in the room:", cursor.x, cursor.y);
        
    
    //List the players that have joined
    for (Player p : players) {
      if (p.active) {
        _layer.pushStyle();
        _layer.fill(p.c);

        cursor.y += (1.0 *lineHeight);

        _layer.textSize(24);
        _layer.textAlign(CENTER);
        //_layer.text(p.name, p.initPos.x, p.initPos.y);
        _layer.text(p.name, cursor.x, cursor.y);
        _layer.popStyle();
      }
    }

    _layer.endDraw();
  }

  void display(PGraphics pg, int x, int y) {
    pg.image(_layer, x, y);
  }

  GameMode mode() { 
    return GameMode.Setup;
  }
}



interface GameScreen {
  void render();  
  void display(PGraphics layer, int x, int y);
  GameMode mode();
}