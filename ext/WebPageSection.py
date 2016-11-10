from docutils import nodes
from docutils.parsers.rst import Directive, directives
from docutils.parsers.rst.roles import set_classes
from docutils.parsers.rst.directives.misc import Class
from sphinx.util.nodes import nested_parse_with_titles

# from pprint import pprint

class wp_section(nodes.Part, nodes.TextElement): pass

class WebPageSectionDirective(Directive):

    required_arguments = 0
    optional_arguments = 0
    # This enable content in directive
    has_content = True
    option_spec = {
        'title': directives.unchanged,
        'class': directives.class_option,
        'titlecls': directives.class_option,
        'careers_top': directives.unchanged,
    }

    def run(self):
        # self.assert_has_content()
        node = nodes.Element() # make anonymous container for text parsing
        self.state.nested_parse(self.content, self.content_offset, node)
        # nested_parse_with_titles(self.content, self.content_offset, node)
        wp_section_node = wp_section()
        wp_section_node.title = self.options.get('title', None)
        wp_section_node.clss = self.options.get('class', [])
        wp_section_node.noblockcls = bool(self.options.get('noblockcls', False))
        wp_section_node.titlecls = self.options.get('titlecls', ['b-section-title'])
        wp_section_node.careers = bool(self.options.get('careers_top', False))
        wp_section_node += node.children
        self.add_name(wp_section_node)
        return [wp_section_node] + []

def visit_wp_section_node(self, node):
    # pprint(node)
    # pprint(node.clss)
    sectioncls = ' '.join(node.clss)
    self.body.append(self.starttag(node, 'section', CLASS=sectioncls))
    self.body.append(self.starttag(node, 'div', CLASS='b-block-wrapper'))
    if node.careers:
        self.body.append("\n</div>\n")
    if node.title is not None:
        titlecls = ' '.join(node.titlecls)
        self.body.append(self.starttag(node, 'h2', CLASS=titlecls))
        self.body.append(node.title)
        self.body.append('</h2>\n')

def depart_wp_section_node(self, node):
    if not node.careers:
        self.body.append('\n</div>')
    self.body.append('\n</section>\n')

def setup(app):
    app.add_directive('wp_section', WebPageSectionDirective)
    app.add_node(wp_section, html=(visit_wp_section_node, depart_wp_section_node))
