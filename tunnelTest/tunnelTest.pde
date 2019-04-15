
/*
Thomas Sanchez Lengeling. http://codigogenerativo.com/
 KinectPV2, Kinect for Windows v2 library for processing
 Skeleton depth tracking example
 
 Kinect Projector Toolkit created the calibration file
 */

import KinectProjectorToolkit.*;

import java.util.ArrayList;
import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

KinectProjectorToolkit kpt;


void setup() {
  size(512, 424, P3D);

  kinect = new KinectPV2(this);

  //Enables depth and Body tracking (mask image)
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true);

  kinect.init();

  kpt = new KinectProjectorToolkit(this, KinectPV2.WIDTHDepth, KinectPV2.HEIGHTDepth);
  kpt.loadCalibration("calibration.txt");
}

void draw() {
  background(0);

  kpt.setDepthMapRealWorld(getDepthValues()); 
  
  

  //image(kinect.getDepthMaskImage(), 0, 0);



  fill(255, 0, 0);
  text(frameRate, 50, 50);
}

PVector [] getDepthValues() {
  int skip = 1;
  int w = KinectPV2.WIDTHDepth;
  int h = KinectPV2.HEIGHTDepth;

  PVector [] points = new PVector[w*h];

  //raw Data int valeus from [0 - 4500]
  int [] depth = kinect.getRawDepthData();

  //values for [0 - 256] strip
  //int [] rawData256 = kinect.getRawDepth256Data();

  for (int x = 0; x < w; x += skip) {
    for (int y = 0; y < h; y += skip) {
      int offset = x + y * w;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      points[offset] = depthToPointCloudPos(x, y, rawDepth);
    }
  }
  return points;
}

void drawSkeleton() {
  //get the skeletons as an Arraylist of KSkeletons
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

  //individual joints
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    //if the skeleton is being tracked compute the skleton joints
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);

      drawBody(joints);
    }
  }
}

//draw the body
void drawBody(KJoint[] joints) {
  //drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  //drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  //drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  //drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawJoint(joints, KinectPV2.JointType_Head);
  
  //int jointType = KinectPV2.JointType_Head;
  int jointType = KinectPV2.JointType_SpineShoulder;
  PVector headPoint = new PVector(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  PVector projectedPoint = kpt.convertKinectToProjector(headPoint);
  
  //noFill();
  //stroke(255, 0, 0);
  fill(255, 0, 0);
  strokeWeight(6);
  ellipse(projectedPoint.x, projectedPoint.y, 30, 30);
}

//draw a single joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}



//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}