float followFactor = 0.65;

class Person {
  ArrayList<Joint> joints;
  int id;
  boolean locked = false;
  Boundary boundary;

  Person(int x, int y, int w, int h, int id) {
    this.id = id;
    joints = new ArrayList<Joint>();
    joints.add(new Joint(0));
    boundary = new Boundary(x, y, w, h);
  }

  void update(KSkeleton skel) {
    if (locked && !skel.isTracked()) {
      reset();
    } else if (skel.isTracked() && !locked) {
      begin(skel.getJoints());
    } else if (skel.isTracked() && locked) {
      updateJoints(skel.getJoints());
    }
  }

  void begin(KJoint[] skelJoints) {
    locked = true;
    if (locked) {
      for (Joint j : joints) {
        int type = j.type;
        j.begin(skelJoints[type].getPosition());
      }
    }
  }

  void reset() {
    locked = false;
  }

  void updateJoints(KJoint[] skelJoints) {
    for (Joint j : joints) {
      int type = j.type;
      j.update(skelJoints[type].getPosition(), this.boundary);
    }
  }

  void display(int w, int sw) {
    if (locked) {
      for (Joint j : joints) {
        j.display(w, sw);
      }
    }
  }
}

class Joint {
  PVector lastPosition, nextPosition, averagePosition;
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  int type;
  int lastConsistent;


  boolean consistent = false;
  boolean viable = true;

  int timeOut = 2000;

  Joint(int type) {
    this.type = type;
    position = new PVector(0, 0);
    lastPosition = new PVector(0, 0);
    nextPosition = new PVector(0, 0);
    averagePosition = new PVector(0, 0);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    mass = 1;
    lastConsistent = millis();
  }



  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void begin(PVector p) {
    position = new PVector(p.x, p.y);
    lastPosition = new PVector(p.x, p.y);
    nextPosition = new PVector(p.x, p.y);
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);

    // Simple friction
    velocity.mult(0.95);
  }

  void display(int w, int sw) {

    noStroke();
    if (consistent && viable) fill(0, 255, 0, 200);
    else if (consistent)  fill(255, 0, 0, 200);
    else fill(0, 50);

    ellipse(position.x, position.y, w+sw, w+sw);
    //fill(0);
    //ellipse(position.x, position.y, w, w);
  }

  void update(PVector nextP, Boundary b) {
    update();
    setViable(b);

    if (isConsistent(nextP)) {
      lastPosition = nextPosition;
      nextPosition = nextP;
      averagePositions();
      pullToNextPosition();
    }
  }

  void averagePositions() {

    position.x = position.x * followFactor + nextPosition.x * (1 - followFactor);
    position.y = position.y * followFactor + nextPosition.y * (1 - followFactor);
  }

  void pullToNextPosition() {
    float ang = atan2(nextPosition.y - position.y, nextPosition.x - position.x);
    //if (ang > PI/2) ang -= 2*PI;
    float mag = map(dist(position.x, position.y, nextPosition.x, nextPosition.y), 0, width/2, 0, 1);
    PVector force = new PVector(mag*cos(ang), mag*sin(ang)); // this needs to be a force in the direction from the current position (position) to the nextPosition
    applyForce(force);
  }

  void setViable(Boundary b) {
    viable = b.within(position);
  }

  boolean isConsistent(PVector nextP) {
    if (dist(nextP.x, nextP.y, position.x, position.y) < 200) {
      lastConsistent = millis();
      consistent = true;
      return true;
    } else {
      if (millis() - lastConsistent > timeOut) {
        reset();
      }
      consistent = false;
    }
    return consistent;
  }

  void reset() {
    println("dunno... resetting joint after timeout?");
  }

  //void checkConsistency(PVector nextP) {
  //  if (dist(nextP.x, nextP.y, position.x, position.y) < 40) {
  //    consistent = true;
  //    lastConsistent = millis();
  //  }
  //  else if (dist(nextP.x, nextP.y, lastPosition.x, lastPosition.y) > 30) {
  //    lastPosition = nextP;
  //    consistent = false;
  //  } else {
  //    consistent = false;
  //    if (millis() - lastConsistent > timeOut) {
  //    }
  //  }
  //}

  void checkEdges() {

    if (position.x > width) {
      position.x = width;
      velocity.x *= -1;
    } else if (position.x < 0) {
      velocity.x *= -1;
      position.x = 0;
    }

    if (position.y > height) {
      velocity.y *= -1;
      position.y = height;
    }
  }
}

class Boundary {

  int w, h, x, y;

  Boundary (int x, int y, int w, int h) {
    this.w = w;
    this.h = h;
    this.x = x;
    this.y = y;
  }

  boolean within(PVector p) {
    float x = p.x;
    float y = p.y;
    return x > this.x && x < this.x + this.w && y < this.y + this.h && y > this.y;
  }
}
