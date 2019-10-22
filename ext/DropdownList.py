from docutils import nodes
from docutils.parsers.rst import Directive
# from docutils.parsers.rst import directives
# from docutils.parsers.rst.roles import set_classes
from sphinx.util.nodes import nested_parse_with_titles


class ddlistitem(nodes.Part, nodes.TextElement): pass


class ddlist(nodes.Sequential, nodes.FixedTextElement): pass


class DDListDirective(Directive):
    required_arguments = 0
    optional_arguments = 0
    # This enable content in directive
    has_content = True

    def run(self):
        self.assert_has_content()
        node = nodes.Element()  # make anonymous container for text parsing
        self.state.nested_parse(self.content, self.content_offset, node)
        ddnode = self.build_ddmenu_from_list(node)
        self.add_name(ddnode)
        return [ddnode] + []

    def build_ddmenu_from_list(self, node):
        if len(node) != 1 or not isinstance(node[0], (nodes.bullet_list,
                                                      nodes.enumerated_list)):
            self.severe("Error while processing ddlist directive")
        ddnode = ddlist()
        for id, item in enumerate(node[0]):
            new_item = ddlistitem()
            title = item.children.pop(0)
            title_ref = nodes.reference('', '', internal=False,
                                        refuri='#node%d' % id,
                                        classes=['dropdown-list-item-url',
                                                 'dropdown-close'],
                                        ids=['node%d' % id])
            title_ref += title

            content = nodes.container('', classes=['dropdown-list-item-content'])
            content += item.children

            new_item += [title_ref, content]
            # print(type(title_ref.parent), title_ref.parent)
            ddnode += new_item
        return ddnode


def visit_print_elem(node, tab):
    for child in node.children:
        print('\t' * tab, type(child))
        visit_print_elem(child, tab + 1)


def visit_ddlist_node(self, node):
    self.body.append(self.starttag(node, 'ul', CLASS='dropdown-list'))
    # visit_print_elem(node, 1)


def depart_ddlist_node(self, node):
    self.body.append('\n</ul>\n')


def visit_ddlistitem_node(self, node):
    self.body.append(self.starttag(node, 'li', CLASS='dropdown-list-item'))


def depart_ddlistitem_node(self, node):
    self.body.append('\n</li>\n')


def setup(app):
    app.add_directive('ddlist', DDListDirective)

    app.add_node(ddlist, html=(visit_ddlist_node, depart_ddlist_node))
    app.add_node(ddlistitem, html=(visit_ddlistitem_node, depart_ddlistitem_node))
