-- Carregar a library
local MultiUI = loadstring(game:HttpGet("URL_DA_SUA_MULTIUI"))()

-- Criar uma janela
local myWindow, windowInstance = MultiUI:CreateWindow({
    Title = "Minha Interface MultiUI",
    Size = UDim2.new(0, 450, 0, 500),
    BackgroundImage = "rbxassetid://1234567890",
    BackgroundTransparency = 0.7,
    Theme = "Modern"
})

-- Adicionar componentes
myWindow:AddLabel({Text = "Configurações", TextSize = 18, FontWeight = Enum.FontWeight.Bold})

myWindow:AddButton({
    Text = "Botão Principal",
    Callback = function()
        print("Botão clicado!")
    end
})

local myToggle = myWindow:AddToggle({
    Text = "Ativar Modo Noturno",
    Default = true,
    Callback = function(state)
        print("Toggle:", state)
    end
})

local mySlider = myWindow:AddSlider({
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 5,
    Callback = function(value)
        print("Volume:", value)
    end
})

local myTextBox = myWindow:AddTextBox({
    Text = "Nome de Usuário",
    Placeholder = "Digite seu nome...",
    Callback = function(text)
        print("Nome:", text)
    end
})

local myDropdown = myWindow:AddDropdown({
    Text = "Selecionar Opção",
    Options = {"Opção 1", "Opção 2", "Opção 3"},
    Default = "Opção 1",
    Callback = function(option)
        print("Opção selecionada:", option)
    end
})

local myKeybind = myWindow:AddKeybind({
    Text = "Atalho Rápido",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        print("Tecla pressionada:", key.Name)
    end
})

-- Adicionar seção
myWindow:AddSection("Configurações Avançadas")

-- Mudar tema
MultiUI:SetTheme("Purple")

-- Mudar fonte
MultiUI:SetFont("Gotham")
