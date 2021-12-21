from typing import Any

from docutils import nodes
from docutils.nodes import Element, Node
from sphinx.locale import _
from sphinx.writers.html import HTMLTranslator as BaseHTMLTranslator


class HTMLTranslator(BaseHTMLTranslator):

    permalink_text = '<i class="fa fa-link"></i>'

    def depart_title(self, node: Element) -> None:
        close_tag = self.context[-1]
        if (self.permalink_text and self.builder.add_permalinks and
                node.parent.hasattr('ids') and node.parent['ids']):
            # add permalink anchor
            if close_tag.startswith('</h') and not close_tag.startswith(
                    '</h1') or close_tag.startswith('</a></h'):
                self.add_permalink_ref_patched(node.parent,
                                               _('Permalink to this headline'))
            elif isinstance(node.parent, nodes.table):
                self.body.append('</span>')
                self.add_permalink_ref(node.parent,
                                       _('Permalink to this table'))
        elif isinstance(node.parent, nodes.table):
            self.body.append('</span>')

        if close_tag.startswith('</h') and not close_tag.startswith('</h1'):
            self.body.append('</div></div>')

        self.body.append(self.context.pop())

        if self.in_document_title:
            self.title = self.body[self.in_document_title:-1]
            self.in_document_title = 0
            self.body_pre_docinfo.extend(self.body)
            self.html_title.extend(self.body)
            del self.body[:]

    def add_permalink_ref_patched(self, node: Element, title: str) -> None:
        if node['ids'] and self.permalink_text and self.builder.add_permalinks:
            format = '<div class="b-doc-hlink"><div class="b-doc-hlink_left">' \
                     '<a class="headerlink" href="#%s" title="%s">%s</a>' \
                     '</div><div class="b-doc-hlink_right">'
            self.body.insert(-1, format % (node['ids'][0], title, self.permalink_text))

    def depart_term(self, node: Element) -> None:
        next_node: Node = node.next_node(descend=False, siblings=True)
        if isinstance(next_node, nodes.classifier):
            # Leave the end tag to `self.depart_classifier()`, in case
            # there's a classifier.
            pass
        else:
            self.body.append('</dt>')

    def depart_caption(self, node: Element) -> None:
        # overridden to disable permalinks for toctrees, images and code
        self.body.append('</span>')
        if isinstance(node.parent, nodes.container) and node.parent.get('literal_block'):
            self.body.append('</div>\n')
        else:
            self.body.append('</p>\n')


def setup(app):
    """
    Custom http formatter
    """
    app.set_translator("html", HTMLTranslator, override=True)
    app.set_translator("html5", HTMLTranslator, override=True)
