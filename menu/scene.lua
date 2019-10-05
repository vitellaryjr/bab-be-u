local scene = {}
game = require '../game/scene'

local scrollx = 0
local scrolly = 0

local music_on = true

local oldmousex = 0
local oldmousey = 0

local buttons = {}--{"play", "editor", "options", "exit"}
local git_btn = nil

local options = false

local splash = love.timer.getTime() % 1

function scene.load()
  metaClear()
  clear()
  was_using_editor = false
  resetMusic("bab be u them REEEMAZTUR", 0.5)
  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)
  local now = os.time(os.date("*t"))
  presence = {
    state = "main menu",
    details = "idling",
    largeImageKey = "titlescreen",
    largeimageText = "main menu",
    startTimestamp = now
  }
  nextPresenceUpdate = 0
  love.keyboard.setKeyRepeat(false)
  scene.buildUI()
  scene.selecting = true
end

function scene.buildUI()
  buttons = {}

  git_btn = ui.component.new()
    :setSprite(sprites["ui/github"])
    :setColor(1, 1, 1)
    :setPos(10, love.graphics.getHeight()-sprites["ui/github"]:getHeight()-10)
    :setPivot(0.5, 0.5)
    :onPreDraw(function(o) ui.buttonFX(o, {rotate = false}) end)
    :onReleased(function() love.system.openURL("https://github.com/lilybeevee/bab-be-u") end)

  local ox, oy
  if not options then
    scene.addButton("play", function() switchScene("play") end)
    scene.addButton("edit", function() switchScene("edit") end)
    scene.addButton("options", function() options = true; scene.buildUI() end)
    scene.addButton("exit", function() love.event.quit() end)
    ox, oy = love.graphics.getWidth()/2, love.graphics.getHeight()/2
  else
    scene.addOption("music_on", "music", {{"on", true}, {"off", false}})
    scene.addOption("sfx_on", "sound", {{"on", true}, {"off", false}})
    scene.addOption("particles_on", "particles", {{"on", true}, {"off", false}})
    scene.addOption("grid_lines", "grid lines", {{"off", false}, {"on", true}})
    scene.addOption("mouse_lines", "mouse lines", {{"off", false}, {"on", true}})   
    scene.addOption("stopwatch_effect", "stopwatch effect", {{"on", true}, {"off", false}})
    scene.addOption("fullscreen", "resolution", {{"windowed", false}, {"fullscreen", true}}, function(val)
      if val then
        if not love.window.isMaximized() then
          winwidth, winheight = love.graphics.getDimensions()
        end
        love.window.setMode(0, 0, {borderless=false})
        love.window.maximize()
        fullscreen = true
      else
        love.window.setMode(winwidth, winheight, {borderless=false, resizable=true, minwidth=705, minheight=510})
        love.window.maximize()
        love.window.restore()
        fullscreen = false
      end
    end)
    scene.addOption("themes", "menu themes", {{"on", true}, {"off", false}})
    scene.addButton("back", function() options = false; scene.buildUI() end)
    ox, oy = love.graphics.getWidth() * (3/4) , buttons[1]:getHeight()+10
  end

  for i,button in ipairs(buttons) do
    local width, height = button:getSize()
    button:setPos(ox - width/2, oy - height/2)
    oy = oy + height + 10
  end
end

function scene.addButton(text, func)
  local button = ui.menu_button.new(text, #buttons%2+1, func)
  table.insert(buttons, button)
  return button
end

function scene.addOption(id, name, options, changed)
  local option = 1
  for i,v in ipairs(options) do
    if settings[id] == v[2] then
      option = i
    end
  end
  scene.addButton(name .. ": " .. options[option][1], function()
    settings[id] = options[(((option-1)+1)%#options)+1][2]
    saveAll()
    if changed then
      changed(settings[id])
    end
    scene.buildUI()
  end)
end

function scene.update(dt)
  scrollx = scrollx+dt*50
  scrolly = scrolly+dt*50
end

function scene.draw(dt)
  local bgsprite 
  if os.date("%m") == "10" and settings["themes"] then
    bgsprite = sprites["ui/menu_background_halloween"]
  else
    bgsprite = sprites["ui/menu_background"]
  end

  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  local cells_x = math.ceil(width / bgsprite:getWidth())
  local cells_y = math.ceil(height / bgsprite:getHeight())

  if not spookmode then
    love.graphics.setColor(1, 1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .4)
  else
    love.graphics.setColor(0.2,0.2,0.2,1)
  end

  for x = -1, cells_x do
    for y = -1, cells_y do
      local draw_x = scrollx % bgsprite:getWidth() + x * bgsprite:getWidth()
      local draw_y = scrolly % bgsprite:getHeight() + y * bgsprite:getHeight()
      love.graphics.draw(bgsprite, draw_x, draw_y)
    end
  end

  for _,button in ipairs(buttons) do
    button:draw()
  end
  git_btn:draw()

  if not options then
    local bab_logo
    if os.date("%m") == "10" and settings["themes"] then
        bab_logo = sprites["ui/bab_be_u_halloween"]
    else
        bab_logo = sprites["ui/bab_be_u"]
    end    
        
    for _,pair in pairs({{1,0},{0,1},{1,1},{-1,0},{0,-1},{-1,-1},{1,-1},{-1,1}}) do
      local outlineSize = 2
      pair[1] = pair[1] * outlineSize
      pair[2] = pair[2] * outlineSize

      love.graphics.setColor(0,0,0)
      love.graphics.draw(bab_logo, width/2 - bab_logo:getWidth() / 2 + pair[1], height/20 + pair[2])
    end

    if not spookmode then
      love.graphics.setColor(1, 1, 1)
      setRainbowModeColor(love.timer.getTime()/3, .5)
      love.graphics.draw(bab_logo, width/2 - bab_logo:getWidth() / 2, height/20)
    end
    
    -- Splash text here
    
    love.graphics.push()
    
    if string.find(build_number, "420") or string.find(build_number, "1337") or string.find(build_number, "666") or string.find(build_number, "69") then
      love.graphics.setColor(hslToRgb(love.timer.getTime()%1, .5, .5, .9))
      splashtext = "nice"
    end
    if is_mobile then
      splashtext = "4mobile!"
    elseif os.date("%m") == "10" then
        if love.filesystem.read("author_name") == "lilybeevee" and splash > 0.5 then
            splashtext = "happy spooky month lily!"
        else
            splashtext = "spooky month!"
        end
    elseif splash > 0.5 then
        splashtext = "bab be u!"
    else
      splashtext = "splosh txt!"
    end
    
    local textx = width/2 + bab_logo:getWidth() / 2
    local texty = height/20+bab_logo:getHeight()

    love.graphics.translate(textx+love.graphics.getFont():getWidth(splashtext)/2, texty+love.graphics.getFont():getHeight()/2)
    love.graphics.rotate(0.7*math.sin(love.timer.getTime()*2))
    love.graphics.translate(-textx-love.graphics.getFont():getWidth(splashtext)/2, -texty-love.graphics.getFont():getHeight()/2)

    love.graphics.print(splashtext, textx, texty)
    
    love.graphics.pop()
  else
    local img = sprites["ui/bab cog"]
    local txt = sprites["ui/many toggls"]

    local full_height = img:getHeight()*2 + 10 + txt:getHeight()

    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() * (1/4), love.graphics.getHeight()/2)
    love.graphics.scale(2 * getUIScale())
    love.graphics.translate(0, -full_height/2)
    
    love.graphics.push()
    love.graphics.scale(2)
    love.graphics.translate(0, img:getHeight()/2)
    love.graphics.rotate(0.1*math.sin(love.timer.getTime()))
    love.graphics.draw(img, -img:getWidth()/2, -img:getHeight()/2)
    love.graphics.pop()

    local ox, oy = math.floor(math.random()*4)/2-1, math.floor(math.random()*4)/2-1
    love.graphics.draw(txt, -txt:getWidth()/2 + ox, full_height - txt:getHeight() + oy)

    love.graphics.pop()
  end

  if build_number and not debug_view then
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .6)
    --if haha number then make it rainbow anyways
    if string.find(build_number, "420") or string.find(build_number, "1337") or string.find(build_number, "666") or string.find(build_number, "69") then
      love.graphics.setColor(hslToRgb(love.timer.getTime()%1, .5, .5, .9))
    end
    love.graphics.print(spookmode and "error" or 'v'..build_number)
  end

  if is_mobile then
    local cursorx, cursory = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .5)
    love.graphics.draw(system_cursor, cursorx, cursory)
  end
end

function scene.keyPressed(key)
  if key == "escape" and options then
    options = false
    scene.buildUI()
  end
end

function scene.resize(w, h)
  scene.buildUI()
end

return scene
