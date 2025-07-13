import lupa
import os
import http.server
import socketserver


PORT = 8000

try:
    # Initialize Lua runtime
    lua_runtime = lupa.LuaRuntime()

    # Configure Lua's package.path so 'require' can find our modules
    script_dir = os.path.dirname(os.path.abspath(__file__))
    current_lua_path = lua_runtime.globals().package.path
    lua_runtime.globals().package.path = f"{current_lua_path};{script_dir}/?.lua"

    # Load router module and then main.lua which defines routes
    # 'require' for modules, 'dofile' for scripts that set up global state
    lua_runtime.execute("router = require('router')")
    lua_runtime.execute("dofile('main.lua')")

    # Get a direct reference to the Lua dispatch function
    lua_dispatch_func = lua_runtime.globals().router.dispatch

    print("Lua runtime initialized and router loaded successfully.")

except Exception as e:
    print(f"FATAL ERROR: Failed to initialize Lua runtime or load scripts: {e}")
    # If Lua fails to initialize, set dispatch func to None to prevent server from starting
    lua_runtime = None
    lua_dispatch_func = None


class LuaRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.handle_request_with_lua("GET")

    def do_POST(self):
        self.handle_request_with_lua("POST")

    def handle_request_with_lua(self, method):
        # Prevent handling requests if Lua runtime failed to initialize
        if lua_dispatch_func is None:
            self.send_error(500, "Lua runtime not initialized.")
            return

        request_path = self.path # Get the requested URL path

        print(f"\n--- Python Server received {method} {request_path} ---")

        try:
            # Call the Lua router.dispatch function directly via Lupa
            lua_response = lua_dispatch_func(method, request_path)

            # Convert Lua response to Python string and send as HTTP response
            response_text = str(lua_response).strip()
            print(f"--- Lua Router responded: {response_text} ---")


            self.send_response(200) # HTTP status code 200 (OK)
            self.send_header("Content-type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(response_text.encode('utf-8'))

        except lupa.LuaError as e:
            # Catch errors originating from the Lua script itself
            print(f"Error executing Lua router: {e}")
            self.send_error(500, f"Lua Router Error: {e}")
        except Exception as e:
            # Catch any other unexpected Python-side errors
            print(f"An unexpected error occurred in Python: {e}")
            self.send_error(500, "Python server internal error")


# Start the Python HTTP server only if Lua runtime was successfully initialized
if lua_runtime is not None:
    with socketserver.TCPServer(("", PORT), LuaRequestHandler) as httpd:
        print(f"Python server serving at port {PORT}")
        print("To test, open your browser or use curl:")
        print(f"  curl http://localhost:{PORT}/")

        httpd.serve_forever()