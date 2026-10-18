#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys

PORT = 8000
DOCS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'docs'))

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DOCS_DIR, **kwargs)

    def end_headers(self):
        # Force aggressive cache invalidation across all modern browsers
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

    def do_GET(self):
        # Prevent 304 Not Modified responses by removing client conditional headers
        if 'If-Modified-Since' in self.headers:
            del self.headers['If-Modified-Since']
        if 'If-None-Match' in self.headers:
            del self.headers['If-None-Match']
        super().do_GET()

    def do_HEAD(self):
        if 'If-Modified-Since' in self.headers:
            del self.headers['If-Modified-Since']
        if 'If-None-Match' in self.headers:
            del self.headers['If-None-Match']
        super().do_HEAD()

class DualStackServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else PORT
    print(f"Serving YazaType web docs from: {DOCS_DIR}")
    print(f"Listening with zero-cache headers on http://localhost:{port} and http://127.0.0.1:{port}")
    with DualStackServer(('0.0.0.0', port), NoCacheHTTPRequestHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
