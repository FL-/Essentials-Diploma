#===============================================================================
# * Diploma - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It displays a game diploma like in
# official games. This is a very simple scene that I made with a lot of comments
# that can be used to understand how simple scenes work.
#
#== INSTALLATION ===============================================================
#
# To this script works, put it above main.
#
#== HOW TO USE =================================================================
#
# To show the diploma use 'pbDiploma(main_text,image_path)' where the main_text
# is the diploma main text and the image_path is the path of the diploma picture
# (like "Graphics/Pictures/diploma").
#
# If you call it without parameters (only 'pbDiploma') then the default main
# text and image path are used.
#
#== NOTES ======================================================================
#
# I suggest to call this script with the conditional branch: 
# '$player.pokedex.owned_count==GameData::Species.species_count'
# ('$Trainer.pokedexOwned==PBSpecies.maxValue' in older Essentials). You can
# also use '$player.pokedex.owned_count(pbGetPokedexRegion)' instead of 
# '$player.pokedex.owned_count' for current regional pokédex.
# 
#===============================================================================

# Check's if PluginManager is defined. The "defined?" return false on Essentials
# v17 and before, so it won't call an undefined class if this script is used on
# these Essentials versions.
# If PluginManager exists, checks if plugin is already installed to won't
# register it twice.
if defined?(PluginManager) && !PluginManager.installed?("Diploma")
  # Register it on PluginManager (and also in credits).
  PluginManager.register({                                                 
    :name    => "Diploma",                                        
    :version => "1.1.1",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=286554",
    :credits => "FL"
  })
  # This code is an equivalent of a plugin with meta.txt as:
  # Name      = Diploma
  # Version   = 1.1.1
  # Website   = https://www.pokecommunity.com/showthread.php?t=286554
  # Credits   = FL
end

class DiplomaScene # The scene class  
  def pbStartScene(main_text, image_path)
    # Initialize the sprite hash where all sprites are. This is used to easily
    # do things like update all sprites in pbUpdateSpriteHash.
    @sprites = {} 
    # Creates a Viewport (works similar to a camera) with z=99999, so player can
    # see all sprites with z below 99999. The higher z sprites are above the
    # lower ones.
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Creates a new IconSprite object and sets its bitmap to image_path
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(image_path)
    # A little trick to centralize if the background hasn't the screen size.
    # If the background and screen are the same size, it will set x/y as 0. 
    @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width)/2
    @sprites["background"].y = (Graphics.height - @sprites["background"].bitmap.height)/2
    # Creates an overlay to write text over it. This is declared after the
    # background, so it will be over it.
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    # Set the font defined in "options" on overlay
    pbSetSystemFont(@sprites["overlay"].bitmap)
    # Calls the draw_text method
    draw_text(main_text)
    # After everything is set, show the sprites with FadeIn effect.
    pbFadeInAndShow(@sprites) { update }
  end

  def draw_text(main_text)
    # This variable was made just to calls 'overlay' insteady of
    # '@sprites["overlay"].bitmap'.
    overlay = @sprites["overlay"].bitmap
    # Clear the overlay to write text over it. In this script the clear is
    # useless, but if you want to change the text without remake the overlay,
    # then this will be necessary.
    overlay.clear 
    # Below code line is only used to make the script works in Essentials v19 or
    # lower, you can even remove it in v20 or higher. It adds $Trainer (v19
    # variable) value in $player (newer variable) if $Trainer exists and
    # $player doesn't exist.
    $player = $Trainer if !$player && $Trainer
    # I am using the _INTL for better parameters (like $player.name) 
    # manipulation and to allow text translation (made in Intl_Messages script
    # section).
    player_name = _INTL("Player: {1}", $player.name)
    # The margins sizes for each side.
    margin_left = 112
    margin_right = 96
    # Creates a new color for text base_color and text shadow_color.
    # The three numbers are in RGB format.
    base_color = Color.new(72, 72, 72)
    shadow_color = Color.new(160, 160, 160)
    # Creates an array to be pbDrawTextPositions second parameter. Search for
    # 'def pbDrawTextPositions' to understand the second parameter.
    # 'Graphics.width-value' and 'Graphics.height-value' make the value counts
    # for the reverse side (starts at bottom right). This is also useful for
    # different screen size graphics. Ex: Graphics.height-96 its the same than
    # 288 if the graphics height is 384.
    # 'Graphics.width/2' and 'Graphics.height/2' returns the center point. 
    text_positions = [
       [player_name,Graphics.width/2,38,2,base_color,shadow_color],
       [_INTL("Game Freak"),Graphics.width - margin_right,Graphics.height - 64,1,base_color,shadow_color]
    ]
    # Draw these text on overlay.
    pbDrawTextPositions(overlay, text_positions)
    # Using drawTextEx (search for 'def drawTextEx' to understand the
    # parameters) to make a line wrap text for main text.
    drawTextEx(overlay,margin_left,96,Graphics.width - margin_left - margin_right,8,main_text,base_color,shadow_color)
  end

  def pbMain
    # Loop called once per frame.
    loop do
      # Updates the graphics.
      Graphics.update
      # Updates the button/key input check.
      Input.update
      # Calls the update method on this class (look at 'def update' in
      # this class).
      self.update
      # If button C or button B (trigger by keys C and X) is pressed, then
      # exits from loop and from pbMain (since the method contains only the
      # loop), starts pbEndScene (look at 'def pbStartScreen').
      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        # To play the Cancel SE (defined in database) when the diploma is
        # canceled, then uncomment the below line.
        #pbPlayCancelSE
        break
      end
      # If you wish to switch between two texts when the C button is 
      # pressed (with a method like draw_text_2), then deletes the 
      # '|| Input.trigger?(Input::C)'. Before the 'loop do' put 'actual_text=1',
      # then use something like:      
      #Input.trigger?(Input::C)
      #  if(actual_text == 1)
      #    actual_text = 2
      #    draw_text_2
      #  elsif(actual_text == 2)
      #    actual_text = 1
      #    draw_text_2
      #  end  
      #end
    end 
  end

  # Called every frame.
  def update
    # Updates all sprites in @sprites variable.
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    # Hide all sprites with FadeOut effect.
    pbFadeOutAndHide(@sprites) { update }
    # Remove all sprites.
    pbDisposeSpriteHash(@sprites)
    # Remove the viewpoint.
    @viewport.dispose
  end
end

class DiplomaScreen # The screen class
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(main_text,image_path)
    # Put the method order in scene. The pbMain have the scene main loop 
    # that only closes the scene when the loop breaks.
    @scene.pbStartScene(main_text,image_path)
    @scene.pbMain
    @scene.pbEndScene
  end
end

# A def for a quick script call. 
# If user doesn't put some parameter, then it uses default values.
def pbDiploma(main_text=nil,image_path=nil)
  # Set default text if main_text is nil.
  main_text = _INTL("This document is issued in recognition of your magnificent achievement - the completion of the National Pokédex.") if !main_text
  # Set default image path if image_path is nil.
  image_path = "Graphics/Pictures/diploma" if !image_path
  # Displays a fade out before the scene starts, and a fade in after the scene
  # ends
  pbFadeOutIn(99999) {
    scene = DiplomaScene.new
    screen = DiplomaScreen.new(scene)
    screen.pbStartScreen(main_text, image_path)
  }
end