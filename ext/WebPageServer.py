import os
import sys
import urlparse
import BaseHTTPServer

from SimpleHTTPServer import SimpleHTTPRequestHandler

__version__ = "0.1"

class WebPageHTTPRequestHandler(SimpleHTTPRequestHandler):
    server_version = "WebPageHTTP/" + __version__

    def send_not_found(self):
        self.log_error("code '404', message 'File not found'")
        # self.send_response(404)
        # self.send_header('Connection', 'close')
        # self.send_header("Content-type", 'text/html; charset=UTF-8')
        # self.end_headers()
        # with open(self.translate_path('/en/404.html'), 'r') as f:
        #     self.copyfile(f, self.wfile)
        # return None

        self.send_response(301)
        parts = urlparse.urlsplit(self.path)
        new_parts = (parts[0], parts[1], '/en/404.html', '', '')
        new_url = urlparse.urlunsplit(new_parts)
        self.send_header("Location", new_url)
        self.end_headers()
        return None

    def find_correct_path(self):
        ## Check basic path
        path = self.translate_path(self.path)
        if os.path.exists(path):
            return path
        ## Fallback to /en/...
        parts = urlparse.urlsplit(self.path)
        new_url = parts[2]
        if not new_url.startswith('/'):
            new_url = '/' + new_url
        new_url = '/en' + new_url
        new_parts = (parts[0], parts[1], new_url, parts[3], parts[4])
        new_url = urlparse.urlunsplit(new_parts)
        path = self.translate_path(new_url)
        if os.path.exists(path):
            return path
        ## Fallback to 404
        return None

    def send_head(self):
        """Common code for GET and HEAD commands.

        This sends the response code and MIME headers.

        Return value is either a file object (which has to be copied
        to the outputfile by the caller unless the command was HEAD,
        and must be closed by the caller under all circumstances), or
        None, in which case the caller has nothing further to do.

        """
        path = self.find_correct_path()
        if path is None:
            return self.send_not_found()
        if os.path.isdir(path):
            # print >> sys.stderr, "inside isdir"
            for index in ["index.html", "en/index.html"]:
                # print >> sys.stderr, "found %s" % index
                index = os.path.join(path, index)
                if os.path.exists(index):
                    path = index
                    break
            else:
                return self.send_error(403, "Forbidden")
        ctype = self.guess_type(path)
        f = None
        try:
            # Always read in binary mode. Opening files in text mode may cause
            # newline translations, making the actual size of the content
            # transmitted *less* than the content-length!
            f = open(path, 'rb')
            self.send_response(200)
            self.send_header("Content-type", ctype)
            fs = os.fstat(f.fileno())
            self.send_header("Content-Length", str(fs[6]))
            self.send_header("Last-Modified", self.date_time_string(fs.st_mtime))
            self.end_headers()
            return f
        except:
            if f is not None:
                f.close()
            raise

def test(HandlerClass = WebPageHTTPRequestHandler,
         ServerClass = BaseHTTPServer.HTTPServer):
    BaseHTTPServer.test(HandlerClass, ServerClass)

if __name__ == "__main__":
    test()
