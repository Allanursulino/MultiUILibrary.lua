--[[
    ███╗   ███╗██╗   ██╗██╗  ████████╗██╗██████╗ 
    ████╗ ████║██║   ██║██║  ╚══██╔══╝██║██╔══██╗
    ██╔████╔██║██║   ██║██║     ██║   ██║██████╔╝
    ██║╚██╔╝██║██║   ██║██║     ██║   ██║██╔══██╗
    ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║██║  ██║
    ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝  ╚═╝
    
    MultiUI v2.0 - UI Library Completa e Moderna
    Criada especialmente para você!
]]

local MultiUI = {
    Name = "MultiUI",
    Version = "2.0.0",
    Author = "Seu Nome",
    Debug = false
}

-- Serviços
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

-- Cache e configurações
MultiUI.Cache = {}
MultiUI.Windows = {}
MultiUI.Themes = {}
MultiUI.CurrentTheme = "Dark"
MultiUI.Connections = {}

-- Configurações padrão
MultiUI.DefaultConfig = {
    Font = "rbxassetid://12187365364",
    BackgroundImage = "",
    BackgroundTransparency = 0.8,
    CanDraggable = true,
    UICorner = 14,
    UIPadding = 16,
    ElementSpacing = 8
}

-- Função para carregar módulos
function MultiUI.Load(moduleName)
    if not MultiUI.Cache[moduleName] then
        MultiUI.Cache[moduleName] = { Loaded = MultiUI[moduleName]() }
    end
    return MultiUI.Cache[moduleName].Loaded
end

-- Módulo de utilidades
function MultiUI.Utils()
    local utils = {}

    function utils.SafeCallback(callback, ...)
        if callback then
            local success, result = pcall(callback, ...)
            if not success and MultiUI.Debug then
                warn("[MultiUI] Callback error:", result)
            end
        end
    end

    function utils.Tween(instance, duration, properties, easingStyle, easingDirection)
        easingStyle = easingStyle or Enum.EasingStyle.Quad
        easingDirection = easingDirection or Enum.EasingDirection.Out
        local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
        local tween = TweenService:Create(instance, tweenInfo, properties)
        tween:Play()
        return tween
    end

    function utils.CreateGradient(colors, rotation)
        local colorSequence = {}
        for i, color in ipairs(colors) do
            table.insert(colorSequence, ColorSequenceKeypoint.new((i-1)/(#colors-1), color))
        end
        return {
            Color = ColorSequence.new(colorSequence),
            Rotation = rotation or 0
        }
    end

    function utils.HexToColor3(hex)
        hex = hex:gsub("#", "")
        return Color3.fromRGB(
            tonumber("0x" .. hex:sub(1, 2)),
            tonumber("0x" .. hex:sub(3, 4)),
            tonumber("0x" .. hex:sub(5, 6))
        )
    end

    function utils.AddConnection(connection)
        table.insert(MultiUI.Connections, connection)
    end

    function utils.DisconnectAll()
        for _, connection in ipairs(MultiUI.Connections) do
            connection:Disconnect()
        end
        MultiUI.Connections = {}
    end

    return utils
end

-- Módulo principal
function MultiUI.Main()
    local m = {
        Font = MultiUI.DefaultConfig.Font,
        BackgroundImage = MultiUI.DefaultConfig.BackgroundImage,
        Themes = {},
        Components = {},
        Utils = MultiUI.Load("Utils")
    }

    -- Temas pré-definidos
    m.Themes = {
        Dark = {
            Name = "Dark",
            Primary = m.Utils.HexToColor3("#3b82f6"),
            Secondary = m.Utils.HexToColor3("#64748b"),
            Success = m.Utils.HexToColor3("#22c55e"),
            Warning = m.Utils.HexToColor3("#f59e0b"),
            Error = m.Utils.HexToColor3("#ef4444"),
            Background = m.Utils.HexToColor3("#0f172a"),
            Surface = m.Utils.HexToColor3("#1e293b"),
            Text = m.Utils.HexToColor3("#f8fafc"),
            TextSecondary = m.Utils.HexToColor3("#94a3b8"),
            Border = m.Utils.HexToColor3("#334155")
        },
        Light = {
            Name = "Light",
            Primary = m.Utils.HexToColor3("#2563eb"),
            Secondary = m.Utils.HexToColor3("#94a3b8"),
            Success = m.Utils.HexToColor3("#16a34a"),
            Warning = m.Utils.HexToColor3("#d97706"),
            Error = m.Utils.HexToColor3("#dc2626"),
            Background = m.Utils.HexToColor3("#ffffff"),
            Surface = m.Utils.HexToColor3("#f8fafc"),
            Text = m.Utils.HexToColor3("#0f172a"),
            TextSecondary = m.Utils.HexToColor3("#64748b"),
            Border = m.Utils.HexToColor3("#e2e8f0")
        },
        Purple = {
            Name = "Purple",
            Primary = m.Utils.HexToColor3("#8b5cf6"),
            Secondary = m.Utils.HexToColor3("#a78bfa"),
            Success = m.Utils.HexToColor3("#10b981"),
            Warning = m.Utils.HexToColor3("#f59e0b"),
            Error = m.Utils.HexToColor3("#ef4444"),
            Background = m.Utils.HexToColor3("#1e1b4b"),
            Surface = m.Utils.HexToColor3("#312e81"),
            Text = m.Utils.HexToColor3("#fafafa"),
            TextSecondary = m.Utils.HexToColor3("#c7d2fe"),
            Border = m.Utils.HexToColor3("#4c1d95")
        },
        Modern = {
            Name = "Modern",
            Primary = m.Utils.HexToColor3("#06b6d4"),
            Secondary = m.Utils.HexToColor3("#64748b"),
            Success = m.Utils.HexToColor3("#10b981"),
            Warning = m.Utils.HexToColor3("#f59e0b"),
            Error = m.Utils.HexToColor3("#ef4444"),
            Background = m.Utils.HexToColor3("#0a0a0a"),
            Surface = m.Utils.HexToColor3("#171717"),
            Text = m.Utils.HexToColor3("#fafafa"),
            TextSecondary = m.Utils.HexToColor3("#a3a3a3"),
            Border = m.Utils.HexToColor3("#404040")
        }
    }

    -- Função para criar instâncias
    function m.New(className, properties, children)
        local instance = Instance.new(className)
        
        for property, value in pairs(properties or {}) do
            if property ~= "ThemeTag" then
                instance[property] = value
            end
        end

        for _, child in pairs(children or {}) do
            if child then
                child.Parent = instance
            end
        end

        return instance
    end

    -- Função para criar frames arredondados
    function m.CreateRoundFrame(cornerRadius, properties, children)
        local frame = m.New("Frame", properties, children)
        local corner = m.New("UICorner", {
            CornerRadius = UDim.new(0, cornerRadius)
        })
        corner.Parent = frame
        return frame
    end

    -- Sistema de componentes
    m.Components.Button = function(config)
        local theme = m.Themes[MultiUI.CurrentTheme]
        local button = m.New("TextButton", {
            Size = config.Size or UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = theme.Primary,
            Text = config.Text or "Button",
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Medium),
            TextSize = 14,
            AutoButtonColor = false,
            Parent = config.Parent
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            m.New("UIStroke", {
                Color = theme.Border,
                Thickness = 1
            }),
            m.New("UIPadding", {
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16)
            })
        })

        -- Efeitos hover
        button.MouseEnter:Connect(function()
            m.Utils.Tween(button, 0.2, {BackgroundColor3 = theme.Primary:Lerp(Color3.new(1, 1, 1), 0.1)})
        end)

        button.MouseLeave:Connect(function()
            m.Utils.Tween(button, 0.2, {BackgroundColor3 = theme.Primary})
        end)

        button.MouseButton1Click:Connect(function()
            m.Utils.SafeCallback(config.Callback)
        end)

        return button
    end

    m.Components.Toggle = function(config)
        local theme = m.Themes[MultiUI.CurrentTheme]
        local toggleState = config.Default or false
        
        local toggleFrame = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = config.Parent
        }, {
            m.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 12)
            })
        })

        local label = m.New("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Text or "Toggle",
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Medium),
            TextSize = 14
        })

        local toggleButton = m.New("Frame", {
            Size = UDim2.new(0, 40, 0, 20),
            BackgroundColor3 = theme.Surface,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0)
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }),
            m.New("UIStroke", {
                Color = theme.Border,
                Thickness = 1
            }),
            m.New("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Name = "ToggleCircle"
            }, {
                m.New("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                })
            })
        })

        label.Parent = toggleFrame
        toggleButton.Parent = toggleFrame

        local function updateToggle()
            if toggleState then
                m.Utils.Tween(toggleButton, 0.2, {BackgroundColor3 = theme.Primary})
                m.Utils.Tween(toggleButton.ToggleCircle, 0.2, {
                    Position = UDim2.new(1, -18, 0.5, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1)
                })
            else
                m.Utils.Tween(toggleButton, 0.2, {BackgroundColor3 = theme.Surface})
                m.Utils.Tween(toggleButton.ToggleCircle, 0.2, {
                    Position = UDim2.new(0, 2, 0.5, 0),
                    BackgroundColor3 = theme.TextSecondary
                })
            end
        end

        toggleButton.MouseButton1Click:Connect(function()
            toggleState = not toggleState
            updateToggle()
            m.Utils.SafeCallback(config.Callback, toggleState)
        end)

        updateToggle()

        return {
            Set = function(value)
                toggleState = value
                updateToggle()
            end,
            Get = function()
                return toggleState
            end
        }
    end

    m.Components.Slider = function(config)
        local theme = m.Themes[MultiUI.CurrentTheme]
        local currentValue = config.Default or config.Min or 0
        
        local sliderFrame = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1,
            Parent = config.Parent
        }, {
            m.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 8)
            })
        })

        local topFrame = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1
        }, {
            m.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal
            })
        })

        local label = m.New("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Text or "Slider",
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Medium),
            TextSize = 14
        })

        local valueLabel = m.New("TextLabel", {
            Size = UDim2.new(0, 50, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(currentValue),
            TextColor3 = theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Medium),
            TextSize = 12
        })

        local sliderTrack = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 6),
            BackgroundColor3 = theme.Surface,
            Position = UDim2.new(0, 0, 0, 30)
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            }),
            m.New("UIStroke", {
                Color = theme.Border,
                Thickness = 1
            }),
            m.New("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = theme.Primary,
                Name = "Fill"
            }, {
                m.New("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                })
            }),
            m.New("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Name = "SliderButton"
            }, {
                m.New("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }),
                m.New("UIStroke", {
                    Color = theme.Border,
                    Thickness = 2
                })
            })
        })

        label.Parent = topFrame
        valueLabel.Parent = topFrame
        topFrame.Parent = sliderFrame
        sliderTrack.Parent = sliderFrame

        local function updateSlider(value)
            currentValue = math.clamp(value, config.Min or 0, config.Max or 100)
            local percentage = (currentValue - (config.Min or 0)) / ((config.Max or 100) - (config.Min or 0))
            
            valueLabel.Text = tostring(math.floor(currentValue))
            m.Utils.Tween(sliderTrack.Fill, 0.1, {Size = UDim2.new(percentage, 0, 1, 0)})
            m.Utils.Tween(sliderTrack.SliderButton, 0.1, {Position = UDim2.new(percentage, 0, 0.5, 0)})
        end

        local isSliding = false
        sliderTrack.SliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSliding = true
            end
        end)

        sliderTrack.SliderButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSliding = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                local sliderPos = sliderTrack.AbsolutePosition.X
                local sliderSize = sliderTrack.AbsoluteSize.X
                local mousePos = input.Position.X
                local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                local value = (config.Min or 0) + percentage * ((config.Max or 100) - (config.Min or 0))
                
                if config.Step then
                    value = math.floor(value / config.Step) * config.Step
                end
                
                updateSlider(value)
                m.Utils.SafeCallback(config.Callback, value)
            end
        end)

        updateSlider(currentValue)

        return {
            Set = function(value)
                updateSlider(value)
            end,
            Get = function()
                return currentValue
            end
        }
    end

    m.Components.TextBox = function(config)
        local theme = m.Themes[MultiUI.CurrentTheme]
        
        local textBoxFrame = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = config.Parent
        }, {
            m.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 6)
            })
        })

        if config.Text then
            local label = m.New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = config.Text,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Medium),
                TextSize = 12
            })
            label.Parent = textBoxFrame
        end

        local textBox = m.New("TextBox", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = theme.Surface,
            TextColor3 = theme.Text,
            PlaceholderText = config.Placeholder or "Enter text...",
            PlaceholderColor3 = theme.TextSecondary,
            Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Regular),
            TextSize = 14,
            ClearTextOnFocus = false
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            m.New("UIStroke", {
                Color = theme.Border,
                Thickness = 1
            }),
            m.New("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12)
            })
        })

        textBox.FocusLost:Connect(function()
            m.Utils.SafeCallback(config.Callback, textBox.Text)
        end)

        textBox.Parent = textBoxFrame

        return {
            Set = function(text)
                textBox.Text = text
            end,
            Get = function()
                return textBox.Text
            end
        }
    end

    m.Components.Dropdown = function(config)
        local theme = m.Themes[MultiUI.CurrentTheme]
        local isOpen = false
        local selectedOption = config.Default
        
        local dropdownFrame = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = config.Parent
        }, {
            m.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical
            })
        })

        local mainButton = m.New("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = theme.Surface,
            Text = selectedOption or "Select an option",
            TextColor3 = theme.Text,
            Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Regular),
            TextSize = 14,
            AutoButtonColor = false
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            m.New("UIStroke", {
                Color = theme.Border,
                Thickness = 1
            }),
            m.New("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12)
            }),
            m.New("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -12, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://10709790956",
                ImageColor3 = theme.TextSecondary
            })
        })

        local optionsFrame = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = theme.Surface,
            Visible = false,
            ClipsDescendants = true
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            m.New("UIStroke", {
                Color = theme.Border,
                Thickness = 1
            }),
            m.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical
            })
        })

        mainButton.Parent = dropdownFrame
        optionsFrame.Parent = dropdownFrame

        local function updateOptions()
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end

            for i, option in ipairs(config.Options or {}) do
                local optionButton = m.New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = theme.Surface,
                    Text = option,
                    TextColor3 = theme.Text,
                    Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Regular),
                    TextSize = 14,
                    AutoButtonColor = false
                }, {
                    m.New("UIPadding", {
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12)
                    })
                })

                optionButton.MouseEnter:Connect(function()
                    m.Utils.Tween(optionButton, 0.2, {BackgroundColor3 = theme.Primary})
                end)

                optionButton.MouseLeave:Connect(function()
                    m.Utils.Tween(optionButton, 0.2, {BackgroundColor3 = theme.Surface})
                end)

                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    mainButton.Text = option
                    toggleDropdown()
                    m.Utils.SafeCallback(config.Callback, option)
                end)

                optionButton.Parent = optionsFrame
            end
        end

        local function toggleDropdown()
            isOpen = not isOpen
            optionsFrame.Visible = isOpen
            
            if isOpen then
                updateOptions()
                m.Utils.Tween(optionsFrame, 0.3, {
                    Size = UDim2.new(1, 0, 0, math.min(#config.Options * 32, 160))
                })
            else
                m.Utils.Tween(optionsFrame, 0.3, {
                    Size = UDim2.new(1, 0, 0, 0)
                })
            end
        end

        mainButton.MouseButton1Click:Connect(toggleDropdown)

        updateOptions()

        return {
            Set = function(option)
                selectedOption = option
                mainButton.Text = option
            end,
            Get = function()
                return selectedOption
            end
        }
    end

    m.Components.Label = function(config)
        local theme = m.Themes[MultiUI.CurrentTheme]
        
        local label = m.New("TextLabel", {
            Size = config.Size or UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = config.Text or "Label",
            TextColor3 = theme.Text,
            TextXAlignment = config.Alignment or Enum.TextXAlignment.Left,
            Font = Enum.Font.fromName("Gotham", config.FontWeight or Enum.FontWeight.Regular),
            TextSize = config.TextSize or 14,
            Parent = config.Parent
        })

        return label
    end

    m.Components.Keybind = function(config)
        local theme = m.Themes[MultiUI.CurrentTheme]
        local currentKey = config.Default or Enum.KeyCode.Unknown
        
        local keybindFrame = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = config.Parent
        }, {
            m.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 12)
            })
        })

        local label = m.New("TextLabel", {
            Size = UDim2.new(1, -80, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Text or "Keybind",
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Medium),
            TextSize = 14
        })

        local keyButton = m.New("TextButton", {
            Size = UDim2.new(0, 70, 0, 25),
            BackgroundColor3 = theme.Surface,
            Text = currentKey.Name,
            TextColor3 = theme.Text,
            Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Medium),
            TextSize = 12,
            AutoButtonColor = false
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            }),
            m.New("UIStroke", {
                Color = theme.Border,
                Thickness = 1
            })
        })

        label.Parent = keybindFrame
        keyButton.Parent = keybindFrame

        local listening = false

        local function setKey(key)
            currentKey = key
            keyButton.Text = key.Name
            listening = false
            m.Utils.SafeCallback(config.Callback, key)
        end

        keyButton.MouseButton1Click:Connect(function()
            listening = true
            keyButton.Text = "..."
        end)

        m.Utils.AddConnection(UserInputService.InputBegan:Connect(function(input)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    setKey(input.KeyCode)
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setKey(Enum.KeyCode.MouseButton1)
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    setKey(Enum.KeyCode.MouseButton2)
                end
            elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                m.Utils.SafeCallback(config.Callback, currentKey)
            end
        end))

        return {
            Set = function(key)
                setKey(key)
            end,
            Get = function()
                return currentKey
            end
        }
    end

    -- Função para criar janelas
    function m.CreateWindow(config)
        local windowConfig = {
            Title = config.Title or "MultiUI Window",
            Size = config.Size or UDim2.new(0, 500, 0, 400),
            Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
            BackgroundImage = config.BackgroundImage or m.BackgroundImage,
            BackgroundTransparency = config.BackgroundTransparency or 0.8,
            Theme = config.Theme or MultiUI.CurrentTheme,
            Font = config.Font or m.Font,
            Acrylic = config.Acrylic or false
        }

        -- Aplicar tema
        MultiUI.CurrentTheme = windowConfig.Theme
        local theme = m.Themes[windowConfig.Theme]

        -- Criar janela principal
        local window = m.New("Frame", {
            Size = windowConfig.Size,
            Position = windowConfig.Position,
            BackgroundColor3 = theme.Background,
            AnchorPoint = Vector2.new(0.5, 0.5),
            ClipsDescendants = true
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(0, MultiUI.DefaultConfig.UICorner)
            }),
            m.New("UIStroke", {
                Color = theme.Border,
                Thickness = 2
            })
        })

        -- Adicionar imagem de fundo se fornecida
        if windowConfig.BackgroundImage ~= "" then
            local background = m.New("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                Image = windowConfig.BackgroundImage,
                ScaleType = "Crop",
                BackgroundTransparency = 1,
                ImageTransparency = windowConfig.BackgroundTransparency
            }, {
                m.New("UICorner", {
                    CornerRadius = UDim.new(0, MultiUI.DefaultConfig.UICorner)
                })
            })
            background.Parent = window
        end

        -- Topbar
        local topbar = m.New("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0
        }, {
            m.New("UICorner", {
                CornerRadius = UDim.new(0, MultiUI.DefaultConfig.UICorner),
                CornerMask = Enum.CornerMask.TopLeft + Enum.CornerMask.TopRight
            }),
            m.New("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = windowConfig.Title,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.fromName("Gotham", Enum.FontWeight.SemiBold),
                TextSize = 16
            }),
            m.New("TextButton", {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -35, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = theme.Error,
                Text = "X",
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.fromName("Gotham", Enum.FontWeight.Bold),
                TextSize = 14,
                AutoButtonColor = false
            }, {
                m.New("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                })
            })
        })
        topbar.Parent = window

        -- Área de conteúdo
        local content = m.New("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -60),
            Position = UDim2.new(0, 10, 0, 50),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        }, {
            m.New("UIListLayout", {
                Padding = UDim.new(0, MultiUI.DefaultConfig.ElementSpacing)
            }),
            m.New("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8)
            })
        })
        content.Parent = window

        -- Funções da janela
        local windowMethods = {}

        function windowMethods:SetBackground(imageUrl, transparency)
            if imageUrl then
                windowConfig.BackgroundImage = imageUrl
                -- Recriar background
                for _, child in pairs(window:GetChildren()) do
                    if child:IsA("ImageLabel") and child ~= topbar then
                        child:Destroy()
                    end
                end
                
                local newBackground = m.New("ImageLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = imageUrl,
                    ScaleType = "Crop",
                    BackgroundTransparency = 1,
                    ImageTransparency = transparency or windowConfig.BackgroundTransparency
                }, {
                    m.New("UICorner", {
                        CornerRadius = UDim.new(0, MultiUI.DefaultConfig.UICorner)
                    })
                })
                newBackground.Parent = window
            end
        end

        function windowMethods:SetFont(fontName)
            windowConfig.Font = fontName
            for _, element in pairs(window:GetDescendants()) do
                if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                    element.Font = Enum.Font.fromName(fontName, element.FontStyle or Enum.FontWeight.Regular)
                end
            end
        end

        function windowMethods:AddButton(config)
            config.Parent = content
            return m.Components.Button(config)
        end

        function windowMethods:AddToggle(config)
            config.Parent = content
            return m.Components.Toggle(config)
        end

        function windowMethods:AddSlider(config)
            config.Parent = content
            return m.Components.Slider(config)
        end

        function windowMethods:AddTextBox(config)
            config.Parent = content
            return m.Components.TextBox(config)
        end

        function windowMethods:AddDropdown(config)
            config.Parent = content
            return m.Components.Dropdown(config)
        end

        function windowMethods:AddLabel(config)
            config.Parent = content
            return m.Components.Label(config)
        end

        function windowMethods:AddKeybind(config)
            config.Parent = content
            return m.Components.Keybind(config)
        end

        function windowMethods:AddSection(title)
            local section = m.New("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = theme.Border,
                LayoutOrder = 999
            })
            section.Parent = content
            
            if title then
                local titleLabel = m.Components.Label({
                    Text = title,
                    TextSize = 12,
                    TextColor3 = theme.TextSecondary,
                    Alignment = Enum.TextXAlignment.Center,
                    Parent = content
                })
                titleLabel.LayoutOrder = 998
            end
        end

        function windowMethods:Destroy()
            window:Destroy()
        end

        -- Botão de fechar
        topbar.TextButton.MouseButton1Click:Connect(function()
            windowMethods:Destroy()
        end)

        -- Tornar a janela arrastável
        m.MakeDraggable(window, topbar)

        table.insert(MultiUI.Windows, windowMethods)

        return windowMethods, window
    end

    -- Função para tornar elementos arrastáveis
    function m.MakeDraggable(frame, handle)
        local dragToggle = nil
        local dragInput = nil
        local dragStart = nil
        local startPos = nil

        handle.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragToggle = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end)

        handle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragToggle then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    return m
end

-- API pública da MultiUI
function MultiUI:CreateWindow(config)
    local main = self.Load("Main")
    return main.CreateWindow(config)
end

function MultiUI:SetTheme(themeName)
    local main = self.Load("Main")
    if main.Themes[themeName] then
        self.CurrentTheme = themeName
        return true
    end
    return false
end

function MultiUI:GetThemes()
    local main = self.Load("Main")
    return main.Themes
end

function MultiUI:SetFont(fontName)
    self.DefaultConfig.Font = fontName
    for _, window in pairs(self.Windows) do
        if window.SetFont then
            window:SetFont(fontName)
        end
    end
end

function MultiUI:SetBackgroundImage(imageUrl, transparency)
    self.DefaultConfig.BackgroundImage = imageUrl
    self.DefaultConfig.BackgroundTransparency = transparency or 0.8
end

function MultiUI:CreateNotification(title, message, duration)
    -- Sistema de notificações simples
    local utils = self.Load("Utils")
    print(string.format("[MultiUI] %s: %s", title, message))
end

function MultiUI:DestroyAll()
    self.Load("Utils").DisconnectAll()
    for _, window in pairs(self.Windows) do
        if window.Destroy then
            window:Destroy()
        end
    end
    self.Windows = {}
end

-- Inicializar a library
MultiUI.Load("Utils")
MultiUI.Load("Main")

return MultiUI
