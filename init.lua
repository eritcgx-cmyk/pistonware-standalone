-- =========================================================================
-- PISTONWARE V4 -- STANDALONE MODULAR ENTRY POINT
-- Complete Standalone Source Tree.
-- Zero Loaders. Zero Key Systems. Zero Remote Dependencies.
-- =========================================================================

local cloneref = cloneref or function(obj) return obj end
local isfile = isfile or function(path) return false end
local isfolder = isfolder or function(path) return false end
local makefolder = makefolder or function(path) end
local readfile = readfile or function(path) return "" end
local writefile = writefile or function(path, content) end

-- Global session authentication override
local shared = shared or _G
shared.PistonwareAuthenticated = true
shared.PistonwareKey = "AUTHENTICATED_STANDALONE"
shared.PistonwareDeveloper = true
shared.PistonwareRelease = {
    schema = 1,
    channel = "main",
    branch = "main",
    sourceRef = "main",
    version = "main@standalone-modular",
    cacheReady = true,
    resolved = true
}

-- Ensure workspace directory structure
for _, folder in ipairs({"pistonware", "pistonware/games", "pistonware/profiles", "pistonware/assets", "pistonware/libraries", "pistonware/guis"}) do
    if not isfolder(folder) then pcall(makefolder, folder) end
end

-- Helper to safely load local files
local function loadLocalChunk(path, name)
    local candidates = {path, select(1, path:gsub('^pistonware/', '')), 'pistonware/' .. select(1, path:gsub('^pistonware/', ''))}
    for _, candidate in ipairs(candidates) do
        if isfile(candidate) then
            local ok, content = pcall(readfile, candidate)
            if ok and type(content) == 'string' and content ~= '' then
                local chunk, compileErr = loadstring(content, name or candidate)
                if chunk then
                    return chunk()
                else
                    warn("[Pistonware Init] Compile error in " .. candidate .. ": " .. tostring(compileErr))
                end
            end
        end
    end
    return nil
end

-- Set up dev loader hook to resolve from local directory
shared.PistonwareDevLoadSource = function(path)
    local candidates = {path, select(1, path:gsub('^pistonware/', '')), 'pistonware/' .. select(1, path:gsub('^pistonware/', ''))}
    for _, candidate in ipairs(candidates) do
        if isfile(candidate) then
            local ok, content = pcall(readfile, candidate)
            if ok and type(content) == 'string' and content ~= '' then
                return content
            end
        end
    end
    return ""
end

-- Load and execute main.lua
local mainChunk = loadLocalChunk("pistonware/main.lua", "main") or loadLocalChunk("main.lua", "main")
return mainChunk
