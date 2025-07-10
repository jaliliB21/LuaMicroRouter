# server.py
import http.server
import socketserver
import subprocess
import json # We'll use this later to pass more complex data

PORT = 8000
LUA_ROUTER_SCRIPT = "main.lua" # The Lua script that uses our router

class LuaRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.handle_request_with_lua("GET")

    def do_POST(self):
        self.handle_request_with_lua("POST")

    def handle_request_with_lua(self, method):
        path = self.path # Get the requested URL path (e.g., /users)

        print(f"\n--- Python Server received {method} {path} ---")

        try:
            # Call the Lua script using subprocess
            # We pass method and path as command-line arguments to Lua
            # This simulates the HTTP request for our Lua router
            command = ["lua", LUA_ROUTER_SCRIPT, method, path]

            # Execute the command and capture its output
            result = subprocess.run(command, capture_output=True, text=True, check=True)

            lua_response = result.stdout.strip()
            print(f"--- Lua Router responded: {lua_response} ---")

            # Send the response back to the client
            self.send_response(200) # HTTP status code 200 (OK)
            self.send_header("Content-type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(lua_response.encode('utf-8'))

        except subprocess.CalledProcessError as e:
            # If the Lua script itself had an unhandled error and exited with non-zero status
            print(f"Error calling Lua script: {e}")
            print(f"Lua stderr: {e.stderr}")
            self.send_error(500, "Internal Server Error from Lua script")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            self.send_error(500, "Python server internal error")

with socketserver.TCPServer(("", PORT), LuaRequestHandler) as httpd:
    print(f"Python server serving at port {PORT}")
    print("To test, open your browser or use curl:")
    print(f"  curl http://localhost:{PORT}/")
    print(f"  curl http://localhost:{PORT}/users")
    print(f"  curl -X POST http://localhost:{PORT}/users")
    httpd.serve_forever()