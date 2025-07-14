# LuaMicroRouter

LuaMicroRouter is a lightweight and flexible web router micro-framework built in Lua. It provides a simple yet powerful way to define and dispatch web routes, designed for building robust APIs and backend services. This project demonstrates core web routing concepts using Lua's powerful features and a Python server integration.

-----

## Implemented Features

  * **Core Routing:** Basic HTTP method (GET, POST) routing to specific handler functions. It handles route registration and dispatches incoming requests.
  * **Route Parameters:** Supports dynamic URL segments like `/users/:id` and `/products/:category/:id`. It automatically extracts parameter values from the URL and passes them to the handler functions. It also provides flexible matching for optional trailing slashes (e.g., `/users/123` and `/users/123/` both match).
  * **Middleware System:** Implements a customizable pipeline for executing middleware functions before route handlers. This enhances the router's functionality by allowing:
      * **Request Logging:** Logs details of incoming requests (method, path) for monitoring and debugging.
      * **Basic Authentication:** Provides a mechanism to intercept and control access to specific paths (e.g., `/admin/*` routes), allowing or denying access based on custom logic.
      * **Global Error Handling:** Acts as a centralized error catcher, gracefully handling unhandled errors from any middleware or route handler and returning a standardized `500 Internal Server Error` response.
  * **Python Integration (Lupa):** The Lua router is seamlessly embedded and integrated with a Python HTTP server using the `Lupa` library. This setup replaces inefficient `subprocess` calls with direct, efficient communication between Python and the Lua runtime, enabling real-world testing.
  * **Modular Structure:** Handler functions are organized into a separate **`views.lua`** module, and middleware functions are in **`middlewares.lua`**. This promotes clean code, better readability, and easier maintenance.

-----

## Project Structure

```
.
├── server.py             # Python HTTP server (integrates with Lua router via Lupa)
├── router.lua            # Core Lua router module (dispatching logic, route registration)
├── main.lua              # Registers routes and middleware
├── views.lua             # Contains all route handler functions
└── middlewares.lua       # Contains all middleware functions
```

-----

## How to Run and Test

1.  **Clone the repository:**

    ```bash
    git clone <your-repo-url>
    cd <your-repo-name>
    ```

2.  **Install Python dependencies:**
    Make sure you have `pip` installed.

    ```bash
    pip install lupa
    ```

3.  **Start the Python server:**
    Open your terminal, navigate to the project root, and run:

    ```bash
    python3 server.py
    ```

    Keep this terminal open as the server will be running here.

      * **Troubleshooting `Address already in use` error:** If you encounter `OSError: [Errno 98] Address already in use`, it means another process is already using port 8000. Find and kill it:
        ```bash
        sudo lsof -i :8000
        sudo kill -9 <PID_NUMBER_FROM_LSOF>
        ```
        Then, try starting the server again.

4.  **Send HTTP requests:**
    Open a **new terminal window** and send requests. You can use **`curl`** (command-line), **Postman**, **Insomnia**, or even your **web browser** for GET requests.

      * **Home Page:**

        ```bash
        curl http://localhost:8000/
        # Or open http://localhost:8000/ in browser
        ```

        *Expected Output:* `Hello from the Home Page!`

      * **Users List (GET):**

        ```bash
        curl http://localhost:8000/users
        ```

        *Expected Output:* `Listing all users.`

      * **User Detail (GET with parameter):**

        ```bash
        curl http://localhost:8000/users/123
        ```

        *Expected Output:* `Displaying details for User ID: 123`

      * **Product Detail (GET with multiple parameters):**

        ```bash
        curl http://localhost:8000/products/electronics/456
        ```

        *Expected Output:* `Displaying details for Product ID: 456 in Category: electronics`

      * **Create User (POST):**
        *(Requires `curl`, Postman, or Insomnia as browsers send GET requests by default.)*

        ```bash
        curl -X POST http://localhost:8000/users
        ```

        *Expected Output:* `User created successfully (POST request).`

      * **Admin Dashboard (Unauthorized - Middleware Test):**

        ```bash
        curl http://localhost:8000/admin/dashboard
        ```

        *Expected Output:* `401 Unauthorized: Access denied to /admin/dashboard`

      * **Admin Authorized (Middleware Test):**

        ```bash
        curl http://localhost:8000/admin/authorized
        ```

        *Expected Output:* `You are authorized to view this admin page!`

      * **Error Test (Global Error Handler Middleware Test):**

        ```bash
        curl http://localhost:8000/error-test
        ```

        *Expected Output:* `500 Internal Server Error (Caught by Global Middleware): Something went wrong in this handler!`

      * **Non-existent Route (404 Test):**

        ```bash
        curl http://localhost:8000/nonexistent
        ```

        *Expected Output:* `404 Not Found: GET /nonexistent`

-----