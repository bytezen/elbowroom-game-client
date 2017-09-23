float WAIT_TIME = 5000;
PGraphics setupLayer; 
Timer gameStartTimer = new Timer(WAIT_TIME);
GameMode currentMode = GameMode.Setup;


class Timer {
  float finalT = 0;
  float duration = 10000;
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
    if (t <= .001 ) {
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
  //layer.textAlign(CENTER);
  layer.fill(255);
  layer.text("Elbow Room", lMargin, 0.10 * layer.height );
  layer.textAlign(LEFT);
  layer.textSize(32);
  layer.text("players in the room: ", lMargin, 0.2 * layer.height);
  layer.textSize(24);
  layer.fill(200, 0, 50);
  layer.text("elbows fly in ... " + Math.floor(gameStartTimer.seconds()), lMargin, 0.75 * layer.height);


  for (Player p : players) {
    if (p.active) {
      layer.pushStyle();
      layer.fill(p.c);
      layer.textSize(16);
      layer.text(p.name, lMargin, cursor * offset + 0.25 * height);
      layer.popStyle();
      cursor++;
    }
  }

  layer.endDraw();
}