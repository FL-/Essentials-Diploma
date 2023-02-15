#===============================================================================
# * Diploma - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It displays a game diploma like in
# official games. This is a very simple scene that I made in a way with several
# comments that can be used as a guide to make simple scenes in Essentials.
#
#===============================================================================
#
# To this script works, put it above main. To show the diploma use 
# 'pbDiploma(maintext,imagepath)' where the maintext is the diploma maintext
# and the imagepath is the path of the diploma picture (like 
# "Graphics/Pictures/diploma"). If you call it without parameters (only
# 'pbDiploma') then the default main text and image path are used. 
# I suggest to call this script only when the condition 
# '$Trainer.pokedexOwned==PBSpecies.maxValue' is true.
# 
#===============================================================================

class DiplomaScene # The scene class
  def update
    # Updates all sprites in @sprites variable
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbStartScene(maintext,imagepath)
    # Initialize the sprite hash where all sprites are. This is better for
    # calling methods for all sprites once like pbUpdateSpriteHash
    @sprites={} 
    # Creates a viewpoint with z=99999, so you can see all sprites with 
    # z below 99999. The higher z sprites are above the lower ones.
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    # Creates a new IconSprite object and sets its bitmap to imagepath
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(imagepath)
    # A little trick to centralize if the background hasn't the screen size
    @sprites["background"].x=(Graphics.width-@sprites["background"].bitmap.width)/2
    @sprites["background"].y=(Graphics.height-@sprites["background"].bitmap.height)/2
    # Creates an overlay to write text over it
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    # Set the font defined in "options" on overlay
    pbSetSystemFont(@sprites["overlay"].bitmap)
    # Calls the pbDrawText method
    pbDrawText(maintext)
    # After everything is set, show the sprites with "FadeIn" effect.
    pbFadeInAndShow(@sprites) { update }
  end

  def pbDrawText(maintext)
    overlay=@sprites["overlay"].bitmap
    # Clear the overlay to write text over it. In this script the clear is
    # useless, but if you want to change the text without remake the overlay,
    # then this is necessary.
    overlay.clear 
    # I am using the _INTL for better others parameters (like $Trainer.name)
    # manipulation and to allow text translation (made in PBIntl script section) 
    playerName=_INTL("Player: {1}",$Trainer.name)
    # The margins sizes for each side
    marginLeft=112
    marginRight=96
    # Creates a new color for text baseColor and text shadowColor.
    # The three numbers are in RGB format.
    baseColor=Color.new(72,72,72)
    shadowColor=Color.new(160,160,160)
    # Creates an array with pbDrawTextPositions second parameter. Search for
    # 'def pbDrawTextPositions' to understand the second parameter.
    # 'Graphics.width-value' and 'Graphics.height-value' make the value counts
    # for the reverse side. This is also useful for different screen size 
    # graphics. Ex: Graphics.height-96 its the same than 288 if the 
    # graphics height is 384.
    # 'Graphics.width/2' and 'Graphics.height/2' returns the center point. 
    textPositions=[
       [playerName,Graphics.width/2,32,2,baseColor,shadowColor],
       [_INTL("Game Freak"),Graphics.width-marginRight,Graphics.height-64,1,baseColor,shadowColor]
    ]
    # Draw these text on overlay.
    pbDrawTextPositions(overlay,textPositions)
    # Using drawTextEx (search for 'def drawTextEx' to understand the
    # parameters) to make a line wrap text for main text.
    drawTextEx(overlay,marginLeft,96,Graphics.width-marginLeft-marginRight,8,maintext,baseColor,shadowColor)
  end

  def pbMain
    loop do
      # Updates the graphics
      Graphics.update
      # Updates the button input check
      Input.update
      # Calls the update method on this class (look at 'def update' in
      # this class)
      self.update
      # If button C or button B (trigger by keys C and X) is pressed, then
      # exits from loop and from pbMain, starts pbEndScene (look at 
      # 'def pbStartScreen')
      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        # To play the Decision SE (defined in database) when the diploma is
        # canceled, then uncomment the below line.
        #pbSEPlay($data_system.decision_se) 
        break
      end
      # If you wish to switch between two texts when the C button is 
      # pressed (with a method like pbDrawText2), then deletes the 
      # '|| Input.trigger?(Input::C)'. Before the 'loop do' put 'actualText=1',
      # then use something like:      
      #Input.trigger?(Input::C)
      #  if(actualText==1)
      #    actualText=2
      #    pbDrawText2
      #  elsif(actualText==2)
      #    actualText=1
      #    pbDrawText
      #  end  
      #end
    end 
  end

  def pbEndScene
    # Hide all sprites with "FadeOut" effect
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint
    @viewport.dispose
  end
end

class Diploma # The screen class
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(maintext,imagepath)
    # Put the method order in scene. The pbMain have the scene main loop 
    # that only closes the scene when the loop breaks.
    @scene.pbStartScene(maintext,imagepath)
    @scene.pbMain
    @scene.pbEndScene
  end
end

# Here a def for a quick script call. 
# If you don't put some parameter, then it uses default values.
def pbDiploma(maintext="",imagepath="")
  # Picks default text if maintext==""
  maintext=_INTL("This document is issued in recognition of your magnificent achievement - the completion of the National Pokédex.") if maintext==""
  # Picks default image path if imagepath==""
  imagepath="Graphics/Pictures/diploma" if imagepath==""
  scene=DiplomaScene.new
  screen=Diploma.new(scene)
  screen.pbStartScreen(maintext,imagepath)
end