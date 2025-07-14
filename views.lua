local M = {}


-- --- Define Handler Functions ---
-- All handlers now receive 'req' (request) and 'res' (response) objects

function M.home_handler(req, res)
    return "Hello from the Home Page!"
end

function M.users_list_handler(req, res)
    return "Listing all users."
end

function M.products_handler(req, res)
    return "Products API endpoint."
end

function M.create_user_handler(req, res)
    return "User created successfully (POST request)."
end

local function error_causing_handler(req, res)
    error("Something went wrong in this handler!")
end

-- Handler for user details by ID
function M.user_detail_handler(req, res)
    local user_id = req.params.id -- Access params via req.params
    return "Displaying details for User ID: " .. tostring(user_id)
end

-- Handler for product details by ID and category
function M.product_detail_handler(req, res)
    local product_id = req.params.id
    local category_name = req.params.category
    return "Displaying details for Product ID: " .. tostring(product_id) .. " in Category: " .. tostring(category_name)
end


function M.admin_dashboard_handler(req, res)
    return "Welcome to the Admin Dashboard (if authorized)!"
end

function M.admin_authorized_handler(req, res)
    return "You are authorized to view this admin page!"

end

return M