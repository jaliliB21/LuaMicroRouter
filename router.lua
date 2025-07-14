-- router.lua
local M = {}

local routes = {
    GET = {},
    POST = {},
    PUT = {},
    DELETE = {}
}

-- Table to store global middleware functions
local middleware_stack = {}

-- Helper function to match a requested path against a registered pattern
-- Returns captured parameters as a table, or nil if no match
local function match_pattern(registered_path, request_path)

    local escaped_registered_path = registered_path:gsub("([%.%+%-%*%?%[%]%^%$%(%)])", "%%%1")


    local pattern_to_match = escaped_registered_path:gsub(":%w+", "([^/]+)")


    if pattern_to_match ~= "/" then
        pattern_to_match = pattern_to_match .. "/?"
    end


    pattern_to_match = "^" .. pattern_to_match .. "$"

    local captured_values = {string.match(request_path, pattern_to_match)}

    if captured_values[1] ~= nil then
        local param_names = {}
        for param_name in registered_path:gmatch(":(%w+)") do
            table.insert(param_names, param_name)
        end

        local params_table = {}

        for i, name in ipairs(param_names) do
            params_table[name] = captured_values[i]
        end
        return params_table
    else
        return nil
    end
end

-- General function to register a route for a given HTTP method
local function register_route(method_table, path, handler)

    table.insert(method_table, {
        path = path,
        handler = handler
    })
end

-- Function to register a GET route
function M.get(path, handler)
    register_route(routes.GET, path, handler)
end

-- Function to register a POST route
function M.post(path, handler)
    register_route(routes.POST, path, handler)
end

-- Function to register a middleware
function M.use(middleware_func)
    table.insert(middleware_stack, middleware_func)
end

-- Private function to handle 404 Not Found errors
local function not_found_handler(method, path)
    return "404 Not Found: " .. method .. " " .. path
end

-- Main dispatch function - Corrected logic
function M.dispatch(method, path)
    local upper_method = string.upper(method)
    local method_routes_list = routes[upper_method]

    local req = {method = method, path = path, params = nil}
    local res = {status = 200, headers = {}, body = ""}

    local current_middleware_idx = 1

    -- The 'next' function, now designed to return the actual result
    local function next_in_pipeline(request_obj, response_obj)
        -- If there are more middleware functions to execute
        if current_middleware_idx <= #middleware_stack then
            local middleware_to_run = middleware_stack[current_middleware_idx]
            current_middleware_idx = current_middleware_idx + 1

            -- Execute middleware in a protected call
            local status, result = pcall(middleware_to_run, request_obj, response_obj, next_in_pipeline)
            if not status then
                -- Middleware itself threw an error
                response_obj.status = 500
                response_obj.body = "500 Internal Server Error (Middleware): " .. result
                return response_obj.body -- Return error immediately
            end
            -- If middleware explicitly returned a response, it's the final response
            if result ~= nil then
                return result
            end
            -- If middleware returned nil, it called next_in_pipeline, so we continue this chain.
            -- The actual response will come from deeper down the pipeline.
            -- This return is crucial to propagate the response from the final handler or 404.
            return next_in_pipeline(request_obj, response_obj) -- Continue the pipeline explicitly
        end

        -- If all middleware finished, now find and execute the route handler
        if method_routes_list then
            for i, route_entry in ipairs(method_routes_list) do
                local params = match_pattern(route_entry.path, request_obj.path)

                if params ~= nil then
                    local handler = route_entry.handler
                    request_obj.params = params -- Add extracted parameters to the request object

                    -- Execute the handler in a protected call
                    local status_handler, handler_result = pcall(handler, request_obj, response_obj)
                    if status_handler then
                        -- If handler returns a result, set it as the response body
                        if type(handler_result) == "string" then
                            response_obj.body = handler_result
                        elseif handler_result ~= nil then
                            response_obj.body = tostring(handler_result)
                        end
                        return response_obj.body -- Return handler's actual response
                    else
                        -- If handler threw an error
                        response_obj.status = 500
                        response_obj.body = "500 Internal Server Error (Handler): " .. handler_result
                        return response_obj.body -- Return handler's error response
                    end
                end
            end
        end

        -- If no route matched after all middleware and handlers checked
        return not_found_handler(request_obj.method, request_obj.path)
    end

    -- Start the middleware chain:
    -- This call to next_in_pipeline initiates the entire request processing pipeline.
    -- The result of this call (which will be the final response body or error) is what M.dispatch returns.
    return next_in_pipeline(req, res)
end


return M