-- router.lua
local M = {}

local routes = {
    GET = {},
    POST = {},
    PUT = {},
    DELETE = {}
}

-- NEW: Helper function to match a requested path against a registered pattern
-- Returns captured parameters as a table, or nil if no match
local function match_pattern(registered_path, request_path)
    -- Escape special characters in the registered_path for Lua patterns, except for ':'
    -- We will replace :param_name with a capture group
    local escaped_registered_path = registered_path:gsub("([%.%+%-%*%?%[%]%^%$%(%)])", "%%%1")

    -- Replace :param_name with a capture group ([^/]+) for matching
    local pattern_to_match = escaped_registered_path:gsub(":%w+", "([^/]+)")

    -- Ensure exact match from start (^) to end ($) of the path, and handle optional trailing slash
    if pattern_to_match ~= "/" then
        pattern_to_match = pattern_to_match .. "/?" -- Make trailing slash optional for non-root paths
    end
    pattern_to_match = "^" .. pattern_to_match .. "$" -- Anchor to start and end

    print("DEBUG: Matching request_path '" .. request_path .. "' against generated pattern '" .. pattern_to_match .. "'")

    local captured_values = {string.match(request_path, pattern_to_match)}

    if captured_values[1] ~= nil then -- If any value was captured (i.e., a match occurred)
        -- Extract parameter names from the original registered_path
        local param_names = {}
        for param_name in registered_path:gmatch(":(%w+)") do
            table.insert(param_names, param_name)
        end

        local params_table = {}
        -- Map captured values to their respective parameter names
        for i, name in ipairs(param_names) do
            params_table[name] = captured_values[i]
        end
        print("DEBUG: Match successful. Captured params:", table.concat(param_names, ", "))
        return params_table -- Return the table of parameters
    else
        print("DEBUG: Match failed.")
        return nil -- No match
    end
end

-- General function to register a route for a given HTTP method
-- No change to how routes are stored, they are just original_path and handler
local function register_route(method_table, path, handler)
    -- Store the original path and handler directly
    table.insert(method_table, {
        path = path, -- Store the original path as defined by the user (e.g., /users/:id)
        handler = handler
    })
    print("DEBUG: Registered route:", path, "for method handler:", tostring(handler))
end

-- Update M.get to use the new register_route helper
function M.get(path, handler)
    register_route(routes.GET, path, handler)
end

-- Update M.post to use the new register_route helper
function M.post(path, handler)
    register_route(routes.POST, path, handler)
end

-- Private function to handle 404 Not Found errors
local function not_found_handler(method, path)
    return "404 Not Found: " .. method .. " " .. path
end

-- Main dispatch function - UPDATED
function M.dispatch(method, path)
    local upper_method = string.upper(method)
    local method_routes_list = routes[upper_method]

    print("DEBUG: Dispatch received method:", upper_method, "and path:", path)

    if method_routes_list then
        print("DEBUG: Found routes list for method:", upper_method, "with", #method_routes_list, "entries.")
        -- Iterate through all registered routes for the given method
        for i, route_entry in ipairs(method_routes_list) do
            -- Try to match the request path against the registered route's original path pattern
            local params = match_pattern(route_entry.path, path)

            if params ~= nil then -- If match_pattern returned a table of parameters (i.e., a match occurred)
                print("DEBUG: Route matched:", route_entry.path)
                local handler = route_entry.handler

                -- Execute the handler function in a protected call, passing the params table
                local status, result = pcall(handler, params)
                if status then
                    print("DEBUG: Handler executed successfully.")
                    return result
                else
                    print("DEBUG: Handler error:", result)
                    return "500 Internal Server Error: " .. result
                end
            end
        end
        print("DEBUG: No matching route found for path:", path)
    else
        print("DEBUG: No routes defined for HTTP method:", upper_method)
    end

    return not_found_handler(upper_method, path)
end

return M