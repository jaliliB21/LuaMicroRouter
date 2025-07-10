-- main.lua
local router = require("router") -- Load our router module

-- Define handler functions for different routes
local function home_handler()
    return "Hello from the Home Page!"
end

local function users_list_handler()
    return "Listing all users."
end

local function products_handler()
    return "Products API endpoint."
end

local function create_user_handler()
    return "User created successfully (POST request)."
end

local function error_causing_handler()
    error("Something went wrong in this handler!") -- This handler will cause an error
end

-- NEW: Handler for user details by ID
-- This handler now expects a 'params' table as its first argument
local function user_detail_handler(params)
    -- params.id will contain the value extracted from the URL
    local user_id = params.id
    return "Displaying details for User ID: " .. tostring(user_id)
end

-- NEW: Handler for product details by ID and category
-- This handler also expects a 'params' table
local function product_detail_handler(params)
    local product_id = params.id
    local category_name = params.category
    return "Displaying details for Product ID: " .. tostring(product_id) .. " in Category: " .. tostring(category_name)
end


-- Register routes with the router
router.get("/", home_handler)
router.get("/users", users_list_handler)
router.get("/products", products_handler)
router.post("/users", create_user_handler)
router.get("/error-test", error_causing_handler)

-- NEW: Register routes with parameters
router.get("/users/:id", user_detail_handler) -- Example: /users/123
router.get("/products/:category/:id", product_detail_handler) -- Example: /products/electronics/456


--- Get HTTP method and path from command-line arguments ---
-- 'arg' is a global table in Lua for command-line arguments
-- arg[0] is the script name itself (main.lua)
-- arg[1] is the first argument (method)
-- arg[2] is the second argument (path)

local method = arg[1]
local path = arg[2]

if not method or not path then
    -- If no arguments are provided, print a message (useful when running main.lua directly for debugging)
    io.stderr:write("Usage: lua main.lua <METHOD> <PATH>\n")
    io.stderr:write("Example: lua main.lua GET /users\n")
    io.stderr:write("Example for parameters: lua main.lua GET /users/123\n")
    io.stderr:write("Example for multiple parameters: lua main.lua GET /products/books/xyz\n")
    os.exit(1) -- Exit with an error code
end

-- Dispatch the request and print the response to standard output
local response = router.dispatch(method, path)
print(response) -- This output will be captured by the Python server