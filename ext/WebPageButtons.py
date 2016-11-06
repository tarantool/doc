from docutils import nodes
from docutils.parsers.rst import Directive, directives
from docutils.parsers.rst.roles import set_classes
from docutils.parsers.rst.directives.misc import Class
from sphinx.util.nodes import nested_parse_with_titles

class wp_button(nodes.Part, nodes.TextElement): pass

class WebPageButtonDirective(Directive):

    required_arguments = 0
    optional_arguments = 0
    # This enable content in directive
    has_content = False
    option_spec = {
        'title': directives.unchanged,
        'class': directives.class_option,
        'icon':  directives.class_option,
        'link':  directives.unchanged
    }

    def run(self):
        wp_button_node = wp_button()
        wp_button_node.title = self.options.get('title', None)
        wp_button_node.clss = self.options.get('class', [])
        wp_button_node.icon = self.options.get('icon', [])
        wp_button_node.link = self.options.get('link', None)
        self.add_name(wp_button_node)
        return [wp_button_node] + []

def visit_wp_button_node(self, node):
    assert node.link, 'Empty link is not allowed'
    clss = 'b-button'
    if node.clss:
        clss = ' '.join([clss] + node.clss[:])
    self.body.append(self.starttag(node, 'a', CLASS=clss, href=node.link))
    if node.icon:
        icon_clss = ' '.join(['fa'] + node.icon[:])
        self.body.append(self.starttag(node, 'i', CLASS=icon_clss))
        self.body.append('\n</i>\n')
    self.body.append(node.title)

def depart_wp_button_node(self, node):
    self.body.append('\n</a>\n')

def setup(app):
    app.add_directive('wp_button', WebPageButtonDirective)
    app.add_node(wp_button, html=(visit_wp_button_node, depart_wp_button_node))
