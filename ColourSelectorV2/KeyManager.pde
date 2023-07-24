//Key Manager
void keyPressed() {
  if (key == 'x') {
    if (!captureActive) {
      mouseSelect = false;
      zoom = maxZoom; 
    }
    captureActive = !captureActive;
  }
  if (key == 'z') {
    if (zoom == maxZoom) {
      zoom = maxZoom*2;
    } else {
      zoom = maxZoom;
    }
  }
  if (char(keyCode) == 'R') {
    if (controlPressed) {
      rgbKeyPressed = true;
    } else {
      zoom = maxZoom;
      imagePos = centrePoint;
    }
  }
  if (char(keyCode) == 'H') hexKeyPressed = true;

  if (key == CODED)
  {
    if (keyCode == CONTROL && !controlPressed) {
      controlPressed = true;
    }
    if (!captureActive)
    {
      if (keyCode == UP) panningUp = true;
      if (keyCode == DOWN) panningDown = true;
      if (keyCode == RIGHT) panningRight = true;
      if (keyCode == LEFT) panningLeft = true;
    }
  }
}

void keyReleased()
{
  if (char(keyCode) == 'H') hexKeyPressed = false;
  if (char(keyCode) == 'R') rgbKeyPressed = false;
  if (key == CODED)
  {
    if (keyCode == CONTROL)
    {
      controlPressed = false;
    }
    if (!captureActive)
    {
      if (keyCode == UP) panningUp = false;
      if (keyCode == DOWN) panningDown = false;
      if (keyCode == RIGHT) panningRight = false;
      if (keyCode == LEFT) {panningLeft = false;}
    }
  }
}

void mousePressed()
{
  if (mouseButton == LEFT)
  {
    if (rgbButton.hover) copyToClipboard(r + ", " + g + ", " + b);
    else if (hexButton.hover) copyToClipboard("#" + hex(color(r, g, b), 6));
    else if (settingsButton.hover) {
      displaySettings = !displaySettings;
      if (displaySettings) 
      {
        captureActive = false;
      } else {
        captureActive = true;
      }
    }
    else if (resizeOnHoverToggle.hover) {
      resizeOnHoverToggle.toggledOn = !resizeOnHoverToggle.toggledOn;
      SaveSettings();
    } else if (darkModeToggle.hover) {
      darkModeToggle.toggledOn = !darkModeToggle.toggledOn;
      SaveSettings();
      ToggleDarkMode();
    } else if (forceFullResToggle.hover) {
      forceFullResToggle.toggledOn = !forceFullResToggle.toggledOn;
      captureSize = 350;
      maxZoom = 1;
      zoom = maxZoom;
      SaveSettings();
    } else if (!captureActive) {mouseSelect = !mouseSelect;}
  }
  
  if (mouseButton == RIGHT)
  {
    if (!panning) {
      mousePos = new PVector(mouseX, mouseY);
      panning = true;
    }
  }
}

void mouseReleased()
{
  if (mouseButton == RIGHT) panning = false;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoom -= e * 0.5;
  if (zoom < maxZoom) {
    zoom = maxZoom;
  }
}

void CheckCopyKeys() {
  if (controlPressed) {
    if (hexKeyPressed) {
      copyToClipboard("#" + hex(color(r, g, b), 6));
    } else if (rgbKeyPressed) {
      copyToClipboard(r + ", " + g + ", " + b);
    }
  }
}
