class Person {
  ArrayList<Joint> joints;
  int id;
  boolean locked = false;

  Person(int id) {
    this.id = id;
    joints = new ArrayList<Joint>();
    joints.add(new Joint(KinectPV2.JointType_Head));
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
      j.update(skelJoints[type].getPosition());
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
  PVector lastPosition, nextPosition;
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
    position = p;
    lastPosition = p;
    nextPosition = p;
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
    fill(255);
    ellipse(position.x, position.y, w+sw, w+sw);
    fill(0);
    ellipse(position.x, position.y, w, w);
  }

  void update(PVector nextP) {
    if (isViable(nextP) && isConsistent(nextP)) {
      lastPosition = nextPosition;
      nextPosition = nextP;
      pullToNextPosition();
      //averagePositions();
    }
  }
  
  void averagePositions() {
    
  }

  void pullToNextPosition() {
    float ang = atan2(position.y - nextPosition.y, position.x - nextPosition.x);
    if (ang > PI/2) ang -= 2*PI;
    float mag = 1.0;
    PVector force = new PVector(mag*cos(ang), mag*sin(ang)); // this needs to be a force in the direction from the current position (position) to the nextPosition
    applyForce(force);
  }

  boolean isViable(PVector nextP) {
    return (nextP.x > 0 && nextP.x < width && nextP.y > 200 && nextP.y < 600);
  }

  boolean isConsistent(PVector nextP) {
    if (dist(nextP.x, nextP.y, position.x, position.y) < 60) {
      lastConsistent = millis();
      return true;
    } else {
      if (millis() - lastConsistent > timeOut) {
        reset();
      }
      return false;
    }
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
