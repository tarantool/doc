import os
import time

from pprint import pprint

import xml.etree.ElementTree as ET

def add_html_link(app, pagename, templatename, context, doctree):
    """As each page is built, collect page names for the sitemap"""
    base_url = app.config['html_theme_options'].get('base_url', '')
    if not base_url or context.get('meta', {}).get('nositemap', False):
        return
    entry = {}

    if not base_url.endswith('/'):
        base_url += '/'
    base_url += (context.get('language', 'en') + '/')
    base_url += pagename + '.html'
    entry['loc'] = base_url

    # filename = pagename + '.rst'
    # if os.path.exists(filename):
    #     filetime = os.path.getmtime(filename)
    #     # <lastmod>2004-12-23T18:00:15+00:00</lastmod>
    #     entry['lastmod'] = time.strftime("%Y-%m-%dT%H:%M:%S+00:00",
    #                                      time.gmtime(filetime))

    entry['priority']    = context.get('meta', {}).get('priority',   '0.5')
    entry['changefreq']  = context.get('meta', {}).get('changefreq', 'weekly')

    app.sitemap_links.append(entry)
#
#    pprint(pagename)
#    pprint(templatename)

def create_sitemap(app, exception):
    """Generates the sitemap.xml from the collected HTML page links"""
    if (not app.config['html_theme_options'].get('base_url', '') or
           exception is not None or
           not app.sitemap_links):
        return

    filename = app.outdir + "/sitemap.xml"
    print("Generating sitemap.xml in %s" % filename)

    root = ET.Element("urlset")
    root.set("xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9")

#     pprint(app.sitemap_links)
#
    for link in app.sitemap_links:
        url = ET.SubElement(root, "url")
        for key, val in link.iteritems():
            ET.SubElement(url, key).text = val

    ET.ElementTree(root).write(filename)

def setup(app):
    """Setup conntects events to the sitemap builder"""
    app.connect('html-page-context', add_html_link)
    app.connect('build-finished', create_sitemap)
    app.sitemap_links = []
