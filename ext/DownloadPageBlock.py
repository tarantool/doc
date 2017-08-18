from docutils import nodes
from docutils.parsers.rst import Directive, directives
from docutils.parsers.rst.roles import set_classes
from docutils.parsers.rst.directives.misc import Class
from sphinx.util.nodes import nested_parse_with_titles

class download_page_block(nodes.Part, nodes.TextElement): pass

class DownloadPageBlockDirective(Directive):

    required_arguments = 0
    optional_arguments = 0
    # This enable content in directive
    has_content = True
    option_spec = {
        'title': directives.unchanged,
        'buttontext': directives.unchanged,
        'class':  directives.class_option,
        'titleclass':  directives.class_option,
        'textclass':  directives.class_option,
        'icon':  directives.class_option,
        'buttonlink':  directives.unchanged
    }

    def run(self):
        node = nodes.Element()
        self.state.nested_parse(self.content, self.content_offset, node)
        download_page_block_node = download_page_block()
        download_page_block_node.title = self.options.get('title', None)
        download_page_block_node.button_text = self.options.get('buttontext', None)
        download_page_block_node.clss = self.options.get('class', [])
        download_page_block_node.title_clss = self.options.get('titleclass', [])
        download_page_block_node.text_clss = self.options.get('textclass', [])
        download_page_block_node.icon = self.options.get('icon', [])
        download_page_block_node.buttonlink = self.options.get('buttonlink', None)
        download_page_block_node += node.children
        self.add_name(download_page_block_node)
        return [download_page_block_node] + []

def visit_download_page_block_node(self, node):
    clss = ''
    if node.clss:
        clss = ' '.join([clss] + node.clss[:])
    self.body.append(self.starttag(node, 'div', CLASS=clss))

    self.body.append(self.starttag(node, 'div', CLASS='b-download-block-icon-container'))
    icon_clss = ' '.join(node.icon[:])
    self.body.append(self.starttag(node, 'i', CLASS=icon_clss))
    self.body.append('</i></div>\n')

    self.body.append(self.starttag(node, 'div', CLASS='b-download-block-text-group'))

    title_clss = 'b-download-block-title'
    if len(node.title_clss) > 0:
        title_clss = ' '.join(node.title_clss[:])
    self.body.append(self.starttag(node, 'div', CLASS=title_clss))
    self.body.append(node.title)
    self.body.append('</div>\n')

    text_clss = 'b-download-block-description'
    if len(node.text_clss) > 0:
        text_clss = ' '.join(node.text_clss[:])
    self.body.append(self.starttag(node, 'div', CLASS=text_clss))

def depart_download_page_block_node(self, node):
    self.body.append('</div>\n')
    if node.buttonlink:
        self.body.append(self.starttag(node, 'a', CLASS='b-download-block-button', href=node.buttonlink))
        self.body.append(node.button_text)
        self.body.append('</a>\n')

    self.body.append('</div>\n')
    self.body.append('\n</div>\n')

def setup(app):
    app.add_directive('download_page_block', DownloadPageBlockDirective)
    app.add_node(download_page_block, html=(visit_download_page_block_node, depart_download_page_block_node))
