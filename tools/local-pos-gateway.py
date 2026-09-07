"""Local /api/um and /api/pos routing, matching the Firebase gateway paths."""
import http.client
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Gateway(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(204)
        self.cors()
        self.end_headers()

    def cors(self):
        origin = self.headers.get('Origin', '')
        if origin in ('http://127.0.0.1:8088', 'http://localhost:8088'):
            self.send_header('Access-Control-Allow-Origin', origin)
            self.send_header('Vary', 'Origin')
        self.send_header('Access-Control-Allow-Headers', 'Authorization, Content-Type')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS')

    def proxy(self):
        port = 8585 if self.path.startswith('/api/um/') else 8586 if self.path.startswith('/api/pos/') else None
        if port is None:
            self.send_error(404)
            return
        body = self.rfile.read(int(self.headers.get('Content-Length', 0)))
        headers = {k: v for k, v in self.headers.items() if k.lower() not in ('host', 'connection', 'origin')}
        headers['X-Forwarded-Host'] = '127.0.0.1'
        conn = http.client.HTTPConnection('127.0.0.1', port, timeout=30)
        try:
            conn.request(self.command, self.path, body=body, headers=headers)
            response = conn.getresponse()
            data = response.read()
            self.send_response(response.status)
            for key, value in response.getheaders():
                if key.lower() not in ('connection', 'transfer-encoding', 'content-length') and not key.lower().startswith('access-control-'):
                    self.send_header(key, value)
            self.cors()
            self.send_header('Content-Length', str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except OSError:
            self.send_error(502, 'Local API unavailable')
        finally:
            conn.close()

    do_GET = do_POST = do_PUT = do_PATCH = do_DELETE = proxy


if __name__ == '__main__':
    ThreadingHTTPServer(('127.0.0.1', 8587), Gateway).serve_forever()
