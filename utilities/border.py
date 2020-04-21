import argparse
import os
import pprint

from PIL import Image, ImageOps
from PIL.ImageColor import colormap


def add_border(filename, width, color, crop):
    im = Image.open(filename)

    base_name = os.path.basename(filename)
    file, ext = os.path.splitext(base_name)
    dest_path = os.path.dirname(os.path.abspath(filename))

    if crop:
        bordered = im.crop(box=(crop, crop, im.width - crop, im.height - crop))
        dest_file = f'{dest_path}/{file}-cropped-{crop}px{ext}'
    else:
        try:
            bordered = ImageOps.expand(im, border=width, fill=color)
        except ValueError as er:
            print(er)
            print('Available color names:')
            pprint.pprint(list(colormap.keys()))
            exit(0)

        dest_file = f'{dest_path}/{file}-border-{width}px{ext}'

    bordered.save(dest_file)
    print(f'Image saved to: \n{dest_file} ')


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="image to add a border")
    parser.add_argument("-w", "--width", help="border width", default=5, type=int)
    parser.add_argument("-c", "--color", help="border color", default='darkgray')
    parser.add_argument("-C", "--crop", help="crop width", default=0, type=int)
    args = parser.parse_args()

    if args.filename:
        add_border(args.filename, args.width, args.color, args.crop)
