local M = {}


-- Middleware 1: Request Logger
function M.logger_middleware(req, res, next)
    print("[MIDDLEWARE] Logging Request: " .. req.method .. " " .. req.path)
    return next(req, res) -- Pass control to the next in pipeline
end


-- Middleware 2: Basic Authentication (simulated)
-- This middleware only allows requests to /admin paths if a specific token is present.
function M.auth_middleware(req, res, next)
    if string.match(req.path, "^/admin") then -- Check if path starts with /admin
        -- For simplicity, let's assume a "token" in request headers or query (not implemented yet)
        -- For now, let's just simulate a check.
        local is_authenticated = false -- Simulate authentication check
        if req.path == "/admin/authorized" then -- Allow one specific path for demo
            is_authenticated = true
        end

        if not is_authenticated then
            res.status = 401 -- Set response status code
            res.body = "401 Unauthorized: Access denied to " .. req.path
            return res.body -- Explicitly return response to stop pipeline
        end
    end
    return next(req, res) -- If authorized or not an admin path, continue
end


-- Middleware 3: Global Error Handler
-- This should ideally be the LAST middleware registered.
-- It wraps the 'next' call in a pcall to catch errors from downstream handlers/middleware.
function M.global_error_handler_middleware(req, res, next)
    local status, result = pcall(next, req, res) -- Execute next in a protected call
    if not status then
        -- An error occurred somewhere down the pipeline (handler or previous middleware)
        res.status = 500
        res.body = "500 Internal Server Error (Caught by Global Middleware): " .. result
        return res.body
    end
    -- If no error, just pass through the result
    return result
end


return M