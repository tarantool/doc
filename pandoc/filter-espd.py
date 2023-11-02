#! /usr/bin/env python
# encoding: utf-8
from panflute import run_filter, debug
from panflute import Link, Para, Str, Header, MetaInlines, Space, Div, HorizontalRule, \
    BulletList, RawBlock, Span, Emph, Strong, Image, Block, Inline, ListContainer

version = None

pb = RawBlock(u"<w:p><w:r><w:br w:type=\"page\" /></w:r></w:p>", format=u"openxml")


def handle_image(elem, doc):
    if isinstance(elem.content, ListContainer):
        attributes={'custom-style': 'image'}
    return elem


def handle_header(elem, doc):
    """
    Title page header
    """
    meta = MetaInlines(Str('Tarantool'))
    return meta


def handle_captions(elem, doc):
    """
    Image caption
    """
    if isinstance(elem.content[0], Span):
        _span = elem.content[0]
        classes = getattr(_span, 'classes', [])
        if 'caption-text' in classes:
            attrs = {'custom-style': 'image-caption'}
            caption_block = Div(elem, attributes=attrs)
            return caption_block
        return elem


def handle_link(elem, doc):
    """
    Transform html urls in docx format
    """
    elem.url = elem.url.replace('singlehtml.html', '')
    return elem


def handle_hr(elem, doc):
    """
    Remove hr
    """
    return []


def handle_default(elem, doc):
    with_classes = getattr(elem, 'classes', [])

    if 'caption-text' in with_classes:
        elem.attributes = {'custom-style': 'captiontext'}
        return elem

    if 'image' in with_classes:
        elem.attributes = {'custom-style': 'image'}
        return elem

    if 'headerlink' in with_classes:
        return []

    if 'toc-backref' in with_classes:
        """
        Remove headers backrefs
        """
        return Span(*elem.content)

    if 'local-toc' in with_classes:
        """
        Remove toctree from html template
        """
        return []

    if len(with_classes) and with_classes[0] == 'breadcrumbs_and_search':
        """
        Remove breadcrumbs
        """
        return []

    if len(with_classes) and 'admonition' in with_classes:
        """
        Customize admonition styles
        """
        elem.attributes = {'custom-style': 'admonitionlist'}
        elem.content[0].content[0] = Strong(Str('Note'))
        return elem


def action(elem, doc):
    switcher = {
        Image: handle_image,
        MetaInlines: handle_header,
        Para: handle_captions,
        Link: handle_link,
        HorizontalRule: handle_hr,
    }
    switcher.get(type(elem), handle_default)(elem, doc)


def main(doc=None):
    return run_filter(action, doc=doc)


if __name__ == '__main__':
    main()
