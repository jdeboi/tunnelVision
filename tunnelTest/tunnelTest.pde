
/*
Thomas Sanchez Lengeling. http://codigogenerativo.com/
 KinectPV2, Kinect for Windows v2 library for processing
 Skeleton depth tracking example
 
 Kinect Projector Toolkit created the calibration file
 */

import javax.swing.JFrame;

import KinectProjectorToolkit.*;

import java.util.ArrayList;
import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

KinectProjectorToolkit kpt;

PVector[] depthMap;

Person[] people;

void setup() {
  //size(512, 424, P3D);
  
  fullScreen(P3D);

  kinect = new KinectPV2(this);

  //Enables depth and Body tracking (mask image)
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true);

  kinect.init();

  kpt = new KinectProjectorToolkit(this, KinectPV2.WIDTHDepth, KinectPV2.HEIGHTDepth);
  kpt.loadCalibration("calibration.txt");

  depthMap = new PVector[KinectPV2.WIDTHDepth*KinectPV2.HEIGHTDepth];
  
  people = new Person[6];
  for (int i = 0; i < people.length; i++) {
    people[i] = new Person(i);
  }
}

void draw() {
  background(0);
  depthMap = depthMapRealWorld();
  kpt.setDepthMapRealWorld(depthMapRealWorld()); 



  //image(kinect.getDepthMaskImage(), 0, 0);


  drawSkeleton();
  fill(255, 0, 0);
  text(frameRate, 50, 50);
}


void drawSkeleton() {
  //get the skeletons as an Arraylist of KSkeletons
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

  //individual joints
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    //if the skeleton is being tracked compute the skleton joints
    people[i].update(skeleton);
    
  }
}

//draw the body
void drawBody(KJoint[] joints) {
  //drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  //drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  //drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  //drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
 
  int jointType = KinectPV2.JointType_Head;
  //int jointType = KinectPV2.JointType_SpineShoulder;
  fill(0, 255, 255);
  drawJoint(joints, jointType);

  fill(255);
  drawProjectedJoint(joints, jointType);
}

void displayDepthMap() {
  //int skip = 50;
  
  //for (int x = 0;  x < pWidth; x += skip) {
  //  for (int y = 0; y < pHeight; y += skip) {
  //    fill(255);
  //    ellipse(
}

//draw a single joint
void drawProjectedJoint(KJoint[] joints, int jointType) {
  int w = KinectPV2.WIDTHDepth;
  int h = KinectPV2.HEIGHTDepth;
  PVector pos = joints[jointType].getPosition();
  int idx = constrain(w * (int) pos.y + (int) pos.x, 0, w*h);
  PVector testPointP = kpt.convertKinectToProjector(depthMap[idx]);
  println("pos " + pos);
  println("testp " + testPointP);
  pushMatrix();
  float z = depthMap[idx].z;
  println("z " + z);
  float diam = map(z, 0, 4500, 400, 100);
  translate(testPointP.x, testPointP.y, testPointP.z);
  noFill();
  strokeWeight(4);
  stroke(255);
  ellipse(0, 0, diam, diam);
  popMatrix();
}

//draw a single joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

// all functions below used to generate depthMapRealWorld point cloud
PVector[] depthMapRealWorld()
{
  int w = KinectPV2.WIDTHDepth;
  int h = KinectPV2.HEIGHTDepth;

  int[] depth = kinect.getRawDepthData();
  int skip = 1;
  for (int y = 0; y < h; y+=skip) {
    for (int x = 0; x < w; x+=skip) {
      int offset = x + y * w;
      //calculate the x, y, z camera position based on the depth information
      PVector point = depthToPointCloudPos(x, y, depth[offset]);
      depthMap[w * y + x] = point;
    }
  }
  return depthMap;
}

PVector getDepthMapAt(int x, int y) {
  PVector dm = depthMap[KinectPV2.WIDTHDepth * y + x];
  return new PVector(dm.x, dm.y, dm.z);
}


//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue)/ (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}
