-- router.lua
local M = {} -- Module table

local routes = {
    GET = {},
    POST = {},
    PUT = {},
    DELETE = {}
}

-- Function to register a GET route
function M.get(path, handler)
    routes.GET[path] = handler
end

-- Function to register a POST route
function M.post(path, handler)
    routes.POST[path] = handler
end

-- Private function to handle 404 Not Found errors
local function not_found_handler(method, path)
    return "404 Not Found: " .. method .. " " .. path
end

-- Main dispatch function
function M.dispatch(method, path)
    -- Convert method to uppercase to match our route table keys (GET, POST, etc.)
    local upper_method = string.upper(method)

    -- Get the specific routes table for this HTTP method (e.g., routes.GET)
    local method_routes = routes[upper_method]

    -- Check if there are any routes defined for this method
    if method_routes then
        -- Try to find a handler for the exact path
        local handler = method_routes[path]
        if handler then
            -- If a handler is found, execute it
            -- For now, handlers take no arguments and return a string
            local status, result = pcall(handler)
            if status then
                return result -- Return the result from the handler
            else
                -- If the handler itself causes an error, return an internal server error message
                return "500 Internal Server Error: " .. result
            end
        end
    end

    -- If no handler was found for the method and path, return 404
    return not_found_handler(upper_method, path)
end

return M -- Return the module table