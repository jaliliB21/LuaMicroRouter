local router = require("router") -- Load our router modules

-- Load handlers and middlewares from their respective files
local views = require("views")
local middlewares = require("middlewares")

-- --- Register Middleware ---
-- Order matters! Global error handler should be registered first.
router.use(middlewares.global_error_handler_middleware)
router.use(middlewares.logger_middleware)
router.use(middlewares.auth_middleware)


-- --- Register Routes ---
router.get("/", views.home_handler)
router.get("/users", views.users_list_handler)
router.get("/products", views.products_handler)
router.post("/users", views.create_user_handler)
router.get("/error-test", views.error_causing_handler)

-- Routes with parameters
router.get("/users/:id", views.user_detail_handler)
router.get("/products/:category/:id", views.product_detail_handler)

-- Admin routes for authentication test
router.get("/admin/dashboard", views.admin_dashboard_handler)
router.get("/admin/authorized", views.admin_authorized_handler)

