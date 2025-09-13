local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui base
local explorerGui = Instance.new("ScreenGui")
explorerGui.Name = "Notepad++"
explorerGui.ResetOnSpawn = false
explorerGui.Parent = playerGui
explorerGui.ScreenInsets = "None"

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.6, 0, 1, 0)
mainFrame.Position = UDim2.new(0,50,0,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 1
mainFrame.Parent = explorerGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,0,0,24)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
header.BorderSizePixel = 1
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "ScriptEditor"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.Legacy
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = header

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "Minimize"
minimizeButton.Size = UDim2.new(0,24,0,24)
minimizeButton.Position = UDim2.new(1,-24,0,0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
minimizeButton.Text = "X"
minimizeButton.TextSize = 14
minimizeButton.TextColor3 = Color3.fromRGB(255,0,0)
minimizeButton.Font = Enum.Font.Legacy
minimizeButton.Parent = header

local TweenService = game:GetService("TweenService")
local originalSize = mainFrame.Size -- Guardamos tamaño original
local minimized = false

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    -- Esperamos que los elementos existan
    local scroll = mainFrame:FindFirstChild("ScrollFrame")
    local keyboard = mainFrame:FindFirstChild("KeyboardFrame")

    if minimized then
        -- Minimizar: solo dejar visible el header
        TweenService:Create(mainFrame, TweenInfo.new(0.25), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, header.Size.Y.Offset)}):Play()
        if scroll then scroll.Visible = false end
        if keyboard then keyboard.Visible = false end
    else
        -- Restaurar al tamaño original
        TweenService:Create(mainFrame, TweenInfo.new(0.25), {Size = originalSize}):Play()
        if scroll then scroll.Visible = true end
        if keyboard then keyboard.Visible = true end
    end
end)

-- ScrollFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1,0,1,-160)
scrollFrame.Position = UDim2.new(0,0,0,55)
scrollFrame.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
scrollFrame.BorderSizePixel = 1
scrollFrame.ScrollBarThickness = 8
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.Parent = mainFrame

-- LineNumbers
local lineNumbersFrame = Instance.new("Frame")
lineNumbersFrame.Name = "LineNumbers"
lineNumbersFrame.Size = UDim2.new(0,40,1,0)
lineNumbersFrame.Position = UDim2.new(0,0,0,0)
lineNumbersFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
lineNumbersFrame.BorderSizePixel = 0
lineNumbersFrame.Parent = scrollFrame

-- TextBox
local textBox = Instance.new("TextBox")
textBox.Name = "ScriptTextBox"
textBox.Size = UDim2.new(1,-44,1,0)
textBox.Position = UDim2.new(0,44,0,0)
textBox.BackgroundTransparency = 1
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.Font = Enum.Font.Code
textBox.Interactable = false
textBox.TextSize = 14
textBox.TextColor3 = Color3.fromRGB(255,255,255)
textBox.Text = ""
textBox.TextWrapped = false
textBox.Parent = scrollFrame

-- Crear líneas numeradas
local maxLines = 300
local lineHeight = textBox.TextSize + 4
for i = 1,maxLines do
    local lineNumber = Instance.new("TextLabel")
    lineNumber.Name = "Line"..i
    lineNumber.Size = UDim2.new(1,-2,0,lineHeight)
    lineNumber.Position = UDim2.new(0,0,0,(i-1)*lineHeight)
    lineNumber.BackgroundTransparency = 1
    lineNumber.Font = Enum.Font.Code
    lineNumber.TextSize = textBox.TextSize
    lineNumber.TextXAlignment = Enum.TextXAlignment.Center
    lineNumber.TextColor3 = Color3.fromRGB(255,255,255)
    lineNumber.Text = tostring(i)
    lineNumber.Parent = lineNumbersFrame
end

scrollFrame.CanvasSize = UDim2.new(0,0,0,maxLines*lineHeight)

-- CURSOR
local cursor = Instance.new("Frame")
cursor.Name = "Cursor"
cursor.Size = UDim2.new(0, 1, 0, 13) -- ancho 1, alto 13
cursor.Position = UDim2.new(0, 44, 0, 0)
cursor.BackgroundColor3 = Color3.fromRGB(255,255,255) 
cursor.BorderColor3 = Color3.fromRGB(0,0,0) 
cursor.BorderSizePixel = 1
cursor.Parent = scrollFrame

local cursorLine, cursorColumn = 1, 0
local blink = true

local function updateCursor()
    local lines = string.split(textBox.Text,"\n")
    cursorLine = #lines
    local lastLine = lines[#lines] or ""
    cursorColumn = #lastLine
    local xPos = 44 + cursorColumn * (textBox.TextSize*0.6)
    local yPos = (cursorLine-1) * lineHeight
    cursor.Position = UDim2.new(0,xPos,0,yPos)
    local visibleY = scrollFrame.AbsoluteSize.Y
    if yPos < scrollFrame.CanvasPosition.Y then
        scrollFrame.CanvasPosition = Vector2.new(0,yPos)
    elseif yPos + lineHeight > scrollFrame.CanvasPosition.Y + visibleY then
        scrollFrame.CanvasPosition = Vector2.new(0,yPos + lineHeight - visibleY)
    end
end

spawn(function()
    while true do
        blink = not blink
        cursor.Visible = blink
        wait(0.5)
    end
end)

-- Funciones para insertar y borrar caracteres
local function insertChar(char)
    local lines = string.split(textBox.Text,"\n")
    local currentLine = lines[cursorLine] or ""
    local newLine = currentLine:sub(1,cursorColumn)..char..currentLine:sub(cursorColumn+1)
    lines[cursorLine] = newLine
    textBox.Text = table.concat(lines,"\n")
    cursorColumn = cursorColumn + #char
    updateCursor()
end

local function removeChar()
    local lines = string.split(textBox.Text,"\n")
    local currentLine = lines[cursorLine] or ""
    if cursorColumn > 0 then
        local newLine = currentLine:sub(1,cursorColumn-1)..currentLine:sub(cursorColumn+1)
        lines[cursorLine] = newLine
        textBox.Text = table.concat(lines,"\n")
        cursorColumn = cursorColumn - 1
    elseif cursorLine > 1 then
        local prevLine = lines[cursorLine-1]
        cursorColumn = #prevLine
        lines[cursorLine-1] = prevLine..currentLine
        table.remove(lines,cursorLine)
        cursorLine = cursorLine - 1
        textBox.Text = table.concat(lines,"\n")
    end
    updateCursor()
end

textBox:GetPropertyChangedSignal("Text"):Connect(updateCursor)

-- Teclado
local keyboardFrame = Instance.new("Frame")
keyboardFrame.Name = "KeyboardFrame"
keyboardFrame.Size = UDim2.new(1,0,0,100)
keyboardFrame.Position = UDim2.new(0,0,1,-100)
keyboardFrame.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
keyboardFrame.BorderSizePixel = 1
keyboardFrame.Parent = mainFrame

local spacing = 2
local startX, startY = 3,3
local rowHeight = (100 - 6*spacing)/5

local shiftPressed = false
local capsLock = false
local shiftMap = {
    ["1"]="!", ["2"]="@", ["3"]="#", ["4"]="$", ["5"]="%", ["6"]="^", ["7"]="&", ["8"]="*", ["9"]="(", ["0"] = ")",
    ["-"]="_", ["="]="+", ["["]="{", ["]"]="}", ["\\"]="|", [";"]=":", ["'"]='"', [","]="<", ["."]=">", ["/"]="?"
}

local rows = {
    {"`","1","2","3","4","5","6","7","8","9","0","-","=","<"},
    {"Tab","Q","W","E","R","T","Y","U","I","O","P","[","]","\\"},
    {"Caps","A","S","D","F","G","H","J","K","L",";","'","Enter"},
    {"Shift","Z","X","C","V","B","N","M",",",".","/","Shift"},
    {"Ctrl","Alt","Space","Alt","Ctrl"}
}

local keyWidth = 25
local function createKey(keyText,x,y,w,h)
    local key = Instance.new("TextButton")
    key.Name = "Key_"..keyText
    key.Size = UDim2.new(0,w,0,h)
    key.Position = UDim2.new(0,x,0,y)
    key.Text = keyText
    key.BackgroundColor3 = Color3.fromRGB(79, 79, 79)
    key.TextColor3 = Color3.fromRGB(255,255,255)
    key.Font = Enum.Font.Code
    key.TextSize = 12
    key.Parent = keyboardFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,5)
    corner.Parent = key

    key.MouseButton1Click:Connect(function()
        if keyText == "<" or keyText == "Backspace" then
            removeChar()
        elseif keyText == "Space" then
            insertChar(" ")
        elseif keyText == "Enter" then
            insertChar("\n")
        elseif keyText == "Tab" then
            insertChar("\t")
        elseif keyText == "Shift" then
            shiftPressed = not shiftPressed
        elseif keyText == "Caps" then
            capsLock = not capsLock
        else
            local char = keyText
            if char:match("%a") then
                if (shiftPressed and not capsLock) or (not shiftPressed and capsLock) then
                    char = char:upper()
                else
                    char = char:lower()
                end
            elseif shiftPressed and shiftMap[char] then
                char = shiftMap[char]
            end
            insertChar(char)
            if shiftPressed then shiftPressed = false end
        end
    end)
end

for rowIndex,row in ipairs(rows) do
    local y = startY + (rowIndex-1)*(rowHeight + spacing)
    local x = startX
    for _,keyText in ipairs(row) do
        local w = keyWidth
        if keyText == "Space" then w = 120 end
        if keyText == "Enter" then w = 50 end
        if keyText == "Shift" then w = 50 end
        if keyText == "Caps" then w = 50 end
        if keyText == "Tab" then w = 40 end
        if keyText == "Ctrl" or keyText == "Alt" then w = 35 end
        if keyText == "<" then w = 40 end
        createKey(keyText,x,y,w,rowHeight)
        x = x + w + spacing
    end
end
