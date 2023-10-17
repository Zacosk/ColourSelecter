public class ToggleButton
{
  PVector position;
  String description;
  public boolean hover, toggledOn;
  color textColour;
  
  public ToggleButton(boolean toggledOn, PVector position, String description) 
  {
    this.toggledOn = toggledOn;
    this.position = position;
    this.description = description;
  }
  
  public void Run()
  {
    Draw();
    CheckHover();
  }
  
  void Draw()
  {
    fill(textColour);
    textSize(20);
    textAlign(LEFT);
    text(description, position.x-6, position.y + 10);
    
    int togglePos = 0;
    noStroke();
    fill(80);
    if (toggledOn) {
      fill(0, 156, 184);
      togglePos = 30;
    }
    
    rect(position.x-50, position.y, 30, 8, 5);
    circle(position.x-50 + togglePos, position.y+4, 15);
  }
  
  void CheckHover()
  {
    hover = false;
    if (mouseX >= position.x - 60 && mouseX <= position.x - 10)
    {
      if (mouseY >= position.y - 5 && mouseY <= position.y + 10)
      {
        hover = true;
      }
    }
  }
  
  public void UpdateTextColour(boolean darkMode)
  {
    textColour = color(0);
    if (darkMode)
    {
      textColour = color(255);
    }
  }
}
