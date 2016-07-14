--!The Make-like Build Utility based on Lua
-- 
-- XMake is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
-- 
-- XMake is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with XMake; 
-- If not, see <a href="http://www.gnu.org/licenses/"> http://www.gnu.org/licenses/</a>
-- 
-- Copyright (C) 2015 - 2016, ruki All rights reserved.
--
-- @author      ruki
-- @file        main.lua
--

-- imports
import("core.base.option")
import("core.project.cache")
import("core.project.config")
import("core.project.history")

-- the macro directories
function _directories()

    return {    path.join(config.directory(), "macros")
            ,   path.join(os.scriptdir(), "macros")}
end

-- the macro directory
function _directory(macroname)

    -- find macro directory
    local macrodir = nil
    for _, dir in ipairs(_directories()) do

        -- found?
        if os.isfile(path.join(dir, macroname .. ".lua")) then
            macrodir = dir
            break
        end
    end

    -- check
    assert(macrodir, "macro(%s) not found!", macroname)

    -- ok
    return macrodir
end

-- the readable macro file
function _rfile(macroname)

    -- is anonymous?
    if macroname == '.' then
        macroname = "anonymous"
    end

    -- get it
    return path.join(_directory(macroname), macroname .. ".lua")
end

-- the writable macro file
function _wfile(macroname)

    -- is anonymous?
    if macroname == '.' then
        macroname = "anonymous"
    end

    -- get it
    return path.join(path.join(config.directory(), "macros"), macroname .. ".lua")
end

-- list macros
function _list()

    -- trace
    print("macros:")

    -- find all macros
    for _, dir in ipairs(_directories()) do
        local macrofiles = os.match(path.join(dir, "*.lua"))
        for _, macrofile in ipairs(macrofiles) do

            -- get macro name
            local macroname = path.basename(macrofile)
            if macroname == "anonymous" then
                macroname = ".<anonymous>"
            end

            -- show it
            print("    " .. macroname)
        end
    end
end

-- show macro
function _show(macroname)

    -- show it
    local file = _rfile(macroname)
    if os.isfile(file) then
        io.cat(file)
    else
        raise("macro(%s) not found!", macroname)
    end
end

-- clear all macros
function _clear()

    -- clear all 
    os.rm(path.join(config.directory(), "macros"))
end

-- delete macro
function _delete(macroname)

    -- remove it
    if os.isfile(_wfile(macroname)) then
        os.rm(_wfile(macroname))
    elseif os.isfile(_rfile(macroname)) then
        raise("macro(%s) cannot be deleted!", macroname)
    else
        raise("macro(%s) not found!", macroname)
    end

    -- trace
    print("delete macro(%s) ok!", macroname)
end

-- import macro
function _import(macrofile, macroname)

    -- import all macros
    if os.isdir(macrofile) then

        -- the macro directory
        local macrodir = macrofile
        local macrofiles = os.match(path.join(macrodir, "*.lua"))
        for _, macrofile in ipairs(macrofiles) do

            -- the macro name
            macroname = path.basename(macrofile)

            -- import it
            os.cp(macrofile, _wfile(macroname))

            -- trace
            print("import macro(%s) ok!", macroname)
        end
    else

        -- import it
        os.cp(macrofile, _wfile(macroname))

        -- trace
        print("import macro(%s) ok!", macroname)
    end
end

-- export macro
function _export(macrofile, macroname)

    -- export all macros
    if os.isdir(macrofile) then

        -- the output directory
        local outputdir = macrofile

        -- export all macros
        for _, dir in ipairs(_directories()) do
            local macrofiles = os.match(path.join(dir, "*.lua"))
            for _, macrofile in ipairs(macrofiles) do

                -- export it
                os.cp(macrofile, outputdir)

                -- trace
                print("export macro(%s) ok!", path.basename(macrofile))
            end
        end
    else        
        -- export it
        os.cp(_rfile(macroname), macrofile)

        -- trace
        print("export macro(%s) ok!", macroname)
    end
end

-- begin to record macro
function _begin()

    -- patch begin tag to the history: cmdlines
    history.save("cmdlines", "__macro_begin__")
end

-- end to record macro
function _end(macroname)

    -- load the history: cmdlines
    local cmdlines = history.load("cmdlines")

    -- get the last macro block
    local begin = false
    local block = {}
    if cmdlines then
        local total = #cmdlines
        local index = total
        while index ~= 0 do
            
            -- the command line
            local cmdline = cmdlines[index]

            -- found begin? break it
            if cmdline == "__macro_begin__" then
                begin = true
                break
            end

            -- found end? break it
            if cmdline == "__macro_end__" then
                break
            end

            -- ignore "xmake m .." and "xmake macro .."
            if not cmdline:find("xmake%s+macro%s*") and not cmdline:find("xmake%s+m%s*") then

                -- save this command line to block
                table.insert(block, 1, cmdline)
            end

            -- the previous line
            index = index - 1
        end
    end

    -- the begin tag not found?
    if not begin then
        raise("please run: 'xmake macro --begin' first!")
    end

    -- patch end tag to the history: cmdlines
    history.save("cmdlines", "__macro_end__")

    -- open the macro file
    local file = io.open(_wfile(macroname), "w")

    -- save the macro begin 
    file:print("function main(argv)")

    -- save the macro block
    for _, cmdline in ipairs(block) do

        -- save command line
        file:print("    os.exec(\"%s\")", (cmdline:gsub("[\\\"]", function (w) return "\\" .. w end)))
    end

    -- save the macro end 
    file:print("end")

    -- exit the macro file
    file:close()

    -- show this macro
    _show(macroname)

    -- trace
    print("define macro(%s) ok!", macroname)
end

-- run macro
function _run(macroname)

    -- is anonymous?
    if macroname == '.' then
        macroname = "anonymous"
    end

    -- load macro
    local macro = import(macroname, {rootdir = _directory(macroname)})

    -- run macro
    macro.main(option.get("arguments") or {})

    -- trace
    print("run macro(%s) ok!", macroname)
end

-- main
function main()

    -- list macros
    if option.get("list") then

        _list()

    -- show macro
    elseif option.get("show") then

        _show(option.get("name"))

    -- clear macro
    elseif option.get("clear") then

        _clear()

    -- delete macro
    elseif option.get("delete") then

        _delete(option.get("name"))

    -- import macro
    elseif option.get("import") then

        _import(option.get("import"), option.get("name"))
    
    -- export macro
    elseif option.get("export") then

        _export(option.get("export"), option.get("name"))

    -- begin to record macro
    elseif option.get("begin") then

        _begin()

    -- end to record macro
    elseif option.get("end") then

        _end(option.get("name"))

    -- run macro
    else
        _run(option.get("name"))
    end
end
