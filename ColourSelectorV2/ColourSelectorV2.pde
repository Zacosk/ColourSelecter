import java.awt.*;
import java.awt.datatransfer.*;
import java.awt.image.BufferedImage;
import java.awt.Rectangle;
import java.awt.MouseInfo;
import java.awt.Point;

//initialise screen shot variables
PImage screenshot, icon;
Robot robot;
BufferedImage capturedImage;
Rectangle screenshotSize;

//initialise mouse variables
Point mouse;

//Button variables
Button rgbButton, hexButton, settingsButton;
ToggleButton resizeOnHoverToggle, darkModeToggle, forceFullResToggle;

Boolean captureActive, mouseSelect, panning, panningUp, panningDown, panningLeft, panningRight, surfaceChanging, surfaceExpanded, displaySettings, controlPressed, rgbKeyPressed, hexKeyPressed, colourIndicatorLerping;
color selectedColour, previousSelectedColour;
int red, green, blue, captureWidth, captureHeight;
PVector centrePoint, detectionPoint, imagePos, mousePos, crossHairPos, colourPreviewPos, colourPreviewMousePos, colourPreviewCornerPos, targetLerp;
float maxZoom, zoom, currentTime, lastTime, deltaTime, lerpPoint;
float[] last10FPS = new float[] {60, 60, 60, 60, 60, 60, 60, 60, 60, 60};

JSONObject settingsJSON;

void settings()
{ 
  size(330, 130, P2D);
  pixelDensity(displayDensity());
  //initialise window settings
  //smooth(8);
  PJOGL.setIcon("Icon.png");
}

void setup(){
  ((PGraphicsOpenGL)g).textureSampling(2);
  
  surface.setTitle("Colour Selector");
  surface.setAlwaysOnTop(true);
  surface.setIcon(icon);
  frameRate(120);
  
  captureActive = true;
  panning = false;
  surfaceExpanded = false;
  mouseSelect = false;
  surfaceChanging = false;
  displaySettings = false;
  panningUp = false;
  panningDown = false;
  panningRight = false;
  panningLeft = false;
  controlPressed = false;
  rgbKeyPressed = false;
  hexKeyPressed = false;
  colourIndicatorLerping = false;
  
  maxZoom = 1;
  zoom = maxZoom;
  captureWidth = 330;
  captureHeight = 100;
  lerpPoint = 0;
  
  
  centrePoint = new PVector(width/2, (height/2)+15);
  detectionPoint = new PVector(centrePoint.x * displayDensity(), centrePoint.y * displayDensity());
  crossHairPos = centrePoint;
  imagePos = centrePoint;
  colourPreviewMousePos = new PVector(centrePoint.x + 12, centrePoint.y + 12);
  colourPreviewCornerPos = new PVector(width-40, height-46);
  colourPreviewPos = colourPreviewCornerPos;
  lastTime = millis();
  
  //New screen capture variables
  try
  {
    robot = new Robot();
    screenshot = new PImage();
  } catch (AWTException e){
    throw new RuntimeException("Unable to Initialize", e);
  }

  //Initialise buttons
  rgbButton = new Button("Copy RGB", new PVector(0, 0), "BlankButton", new PVector(168, 30));
  hexButton = new Button("Copy HEX", new PVector(168, 0), "BlankButton", new PVector(134, 30));
  settingsButton = new Button("Settings", new PVector(width-30, 0), "SettingsButton", new PVector(30, 30));

  LoadSettings();

  //Initialise toggles
  resizeOnHoverToggle = new ToggleButton(settingsJSON.getBoolean("expandOnMouse"), new PVector(width-40, 45), "Expand on mouse mode  -  ");
  darkModeToggle = new ToggleButton(settingsJSON.getBoolean("darkMode"), new PVector(width-40, 75), "Dark mode  -  ");
  forceFullResToggle = new ToggleButton(settingsJSON.getBoolean("forceFullRes"), new PVector(width-40, 105), "Force full res screen capture  -  ");
  
  ToggleDarkMode();
  SaveSettings();
}
void draw(){
  background(0);
  
  if (captureActive && focused) {
    captureScreenShot();
  }
  
  if (panning)
  {
    imagePos = new PVector(imagePos.x + (mousePos.x - mouseX) * -1, imagePos.y + (mousePos.y - mouseY) * -1);
    mousePos = new PVector(mouseX, mouseY);  
  }
  
  //Screen image
  push();
  
  centrePoint = new PVector(width/2, (height/2)+15);
  translate(imagePos.x, imagePos.y);
  scale(zoom);
  imageMode(CENTER);
  image(screenshot,0, 0);
  pop();
  
  DrawTopBar();
  DrawColourPreview();
  CalculateDeltaTime();
  CheckPanning();
  
  SelectionMode();
  GetPixelColour();
  
  if (displaySettings) 
  {
    DrawSettings(); 
  }
  
  if (resizeOnHoverToggle.toggledOn)
  {
    RunChangeSurfaceSize();
  }
  
  DetectLowFPS();
  
  CheckCopyKeys();
  
  if (!focused) {
    DrawInactive();
  }
  //Lerp();
  //println(frameRate);
}

void captureScreenShot()
{
  mouse = MouseInfo.getPointerInfo().getLocation();
  
  screenshotSize = new Rectangle(mouse.x-(captureWidth/2), mouse.y-(captureHeight/2), captureWidth, captureHeight);
  
  capturedImage = robot.createScreenCapture(screenshotSize);//new Rectangle(Toolkit.getDefaultToolkit().getScreenSize()));
  screenshot = new PImage(capturedImage);
}

void DetectLowFPS()
{
  if (forceFullResToggle.toggledOn)
  {return;}
  
  for (int i = 0; i < last10FPS.length-1; i++)
  {
    last10FPS[i] = last10FPS[i+1];
  }
  last10FPS[9] = frameRate;
  
  int averageFPS = 0;
  for (int i = 0; i < last10FPS.length; i++)
  {
    averageFPS += last10FPS[i];
  }
  
  averageFPS /= 10;
  
  if (averageFPS < 40)
  {
    captureWidth = 198;
    captureHeight = 60;
    maxZoom = 1.7f;
    zoom = 1.7f;
  }
}

void GetPixelColour()
{
  red = int(red(get((int)detectionPoint.x, (int)detectionPoint.y)));
  green = int(green(get((int)detectionPoint.x, (int)detectionPoint.y)));
  blue = int(blue(get((int)detectionPoint.x, (int)detectionPoint.y)));
  selectedColour = color(red, green, blue);
}

void DrawInactive()
{
  filter(BLUR, 6);
  noStroke();
  fill(50, 150);
  rect(0, 0, width * displayDensity(), height * displayDensity());
    
  fill(50);
  rect(0, height/2-13, width, 40);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("WINDOW INACTIVE", width/2, height/2);
}

void SelectionMode()
{
  if (captureActive)
  {
    detectionPoint = new PVector(centrePoint.x * displayDensity(), centrePoint.y * displayDensity());
    imagePos = centrePoint;
    crossHairPos = centrePoint;
  } else if (mouseSelect){
    detectionPoint = new PVector(mouseX * displayDensity(), mouseY * displayDensity());
    crossHairPos = new PVector(mouseX, mouseY);  
}
  //Crosshair
  noFill();
  stroke(color(255-red, 255-green, 255-blue));
  strokeWeight(3);
  circle(crossHairPos.x, crossHairPos.y, 10);
}

void DrawTopBar() {
  //Draw buttons
  rgbButton.Run();
  hexButton.Run();
  settingsButton.Run();
  
  //Draw text
  fill(0);
  if (darkModeToggle.toggledOn)
  {
    fill(255);
  }
  textSize(20);
  textAlign(LEFT);
  text("RGB: " + formatNum(red) + ", " + formatNum(green) + ", " + formatNum(blue), 8, 22);
  text("HEX: #" + hex(selectedColour, 6), 176, 22);
}

void DrawColourPreview()
{
  //Draw colour preview
  stroke(color(255-red, 255-green, 255-blue));
  fill(selectedColour);
  push();
  translate(colourPreviewPos.x + 25, colourPreviewPos.y + 30);
  arc(0, 0, 30, 30, 3.14159, 6.28319);
  if (!captureActive) fill(previousSelectedColour);
  rotate(radians(180));
  arc(0, 0, 30, 30, 3.14159, 6.28319);
  pop();
}

void Lerp() 
{
  if (colourIndicatorLerping) {
    //Update mouse lerp pos
    colourPreviewMousePos = new PVector(detectionPoint.x + 12, detectionPoint.y + 12);
    
    colourPreviewPos.lerp(targetLerp, lerpPoint);
    
    lerpPoint += 0.01f;
    if (lerpPoint >= 1) {
      colourPreviewPos.x = targetLerp.x;
      colourPreviewPos.y = targetLerp.y;
      colourIndicatorLerping = false;
      println("finished lerping");
      lerpPoint = 0;
    }
  }
}

void DrawSettings()
{
  noStroke();
  fill(255);
  if (darkModeToggle.toggledOn)
  {
    fill(56);
  }
  rect(0, 30, width, height-30);
  
  resizeOnHoverToggle.Run();
  darkModeToggle.Run();
  forceFullResToggle.Run();
}

String formatNum(int num) 
{
  return String.format("%03d", num);
}

void CalculateDeltaTime()
{
  currentTime = millis();
  
  deltaTime = (currentTime - lastTime);
  lastTime = currentTime;
}

void RunChangeSurfaceSize() 
{
  try {
    if (mouseSelect && !surfaceExpanded)
    {
      /*
      surface.setSize(width, 300);
      surfaceExpanded = true; */
      surface.setSize(width, height + (int)(1 * deltaTime));
      imagePos = centrePoint;
      if (height >= 300) {
        surfaceExpanded = true;
        surface.setSize(width, 330);
        surfaceChanging = false;
      } 
      colourPreviewPos = new PVector(width-40, height-46);
    } else if (captureActive && surfaceExpanded)
    {
      /*
      surface.setSize(width, 130);
      surfaceExpanded = false;*/
    
      surface.setSize(width, height - (int)(1 * deltaTime));
      if (height <= 130) {
        surfaceExpanded = false;
        surface.setSize(width, 130);
        surfaceChanging = false;
        centrePoint = new PVector(width/2, (height/2)+15);
        imagePos = centrePoint;
      }
      colourPreviewPos = new PVector(width-40, height-46);
    }
    } catch (Exception e) {
      String[] export = {e.toString(), ""};
    saveStrings("CrashLog.txt", export);
  }
}

void LoadSettings()
{
  if (checkFileExists("data/settings.json"))
  {
    settingsJSON = loadJSONObject("settings.json");
  } else {
    settingsJSON = new JSONObject();
    settingsJSON.setBoolean("darkMode", true);
    settingsJSON.setBoolean("expandOnMouse", false);
    settingsJSON.setBoolean("forceFullRes", false);
  }
}

void SaveSettings()
{
  settingsJSON.setBoolean("darkMode", darkModeToggle.toggledOn);
  settingsJSON.setBoolean("expandOnMouse", resizeOnHoverToggle.toggledOn);
  settingsJSON.setBoolean("forceFullRes", forceFullResToggle.toggledOn);
  saveJSONObject(settingsJSON, "data/settings.json");
}

boolean checkFileExists(String fileName) {
  File file = new File(sketchPath(fileName));
  return file.exists();
}

void ToggleDarkMode()
{
  rgbButton.UpdateImg(darkModeToggle.toggledOn);
  hexButton.UpdateImg(darkModeToggle.toggledOn);
  settingsButton.UpdateImg(darkModeToggle.toggledOn);
  
  darkModeToggle.UpdateTextColour(darkModeToggle.toggledOn);
  resizeOnHoverToggle.UpdateTextColour(darkModeToggle.toggledOn);
  forceFullResToggle.UpdateTextColour(darkModeToggle.toggledOn);
}

void copyToClipboard(String stringToCopy){
  StringSelection selection = new StringSelection(stringToCopy);
  Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
  clipboard.setContents(selection, selection);
}

void CheckPanning() {
  if (panningUp) {
    imagePos.y += 0.5f * deltaTime;
  }
  if (panningDown) {
    imagePos.y -= 0.5f * deltaTime;
  }
  if (panningLeft) {
    imagePos.x += 0.5f * deltaTime;
  }
  if (panningRight) {
    imagePos.x -= 0.5f * deltaTime;
  }
}
