from docutils import nodes
from docutils.parsers.rst import Directive, directives
from docutils.parsers.rst.roles import set_classes
from docutils.parsers.rst.directives.misc import Class
from sphinx.util.nodes import nested_parse_with_titles

class module_block(nodes.Part, nodes.TextElement): pass

class ModuleBlockDirective(Directive):

    required_arguments = 0
    optional_arguments = 0
    # This enable content in directive
    has_content = True
    option_spec = {
        'title': directives.unchanged,
        'specialtext':  directives.unchanged,
        'sourcelink':  directives.unchanged
    }

    def run(self):
        node = nodes.Element()
        self.state.nested_parse(self.content, self.content_offset, node)
        module_block_node = module_block()
        module_block_node.title = self.options.get('title', None)
        module_block_node.clss = self.options.get('class', [])
        module_block_node.specialtext = self.options.get('specialtext', None)
        module_block_node.sourcelink = self.options.get('sourcelink', None)
        module_block_node += node.children
        self.add_name(module_block_node)
        return [module_block_node] + []

def visit_module_block_node(self, node):
    self.body.append(self.starttag(node, 'div', CLASS='b-rock-block'))
    self.body.append(self.starttag(node, 'div', CLASS='b-rock-block-header'))
    self.body.append(self.starttag(node, 'p',))
    self.body.append(node.title)
    self.body.append(self.starttag(node, 'span', CLASS='special-text'))
    self.body.append(node.specialtext)
    self.body.append('\n</span>\n')
    self.body.append('\n</p>\n')
    if node.sourcelink:
        self.body.append(self.starttag(node, 'a', CLASS='b-rock-block-header-source-link', href=node.sourcelink))
        self.body.append(self.starttag(node, 'div', CLASS='github-icon'))
        self.body.append('</div>\n')
        self.body.append('</a>\n')
    self.body.append('</div>\n')

    self.body.append(self.starttag(node, 'p'))

def depart_module_block_node(self, node):
    self.body.append('\n</p></div>\n')

def setup(app):
    app.add_directive('module_block', ModuleBlockDirective)
    app.add_node(module_block, html=(visit_module_block_node, depart_module_block_node))
