import fileinput
import textwrap
from pprint import pprint

SAME_LINE_BRACES = True
LINE_WIDTH = 80
MIN_TEXT_WIDTH = 20
MIN_HEX_WIDTH = 2

def section(name):
    print(("[ %s ]" % name).center(80, "-"))

def indent(lines, amount=4):
    indentation = " " * amount
    return [indentation + line for line in lines]

def text_width(cases):
    # find the longest string, go with that
    # unless smaller than MIN_TEXT_WIDTH, then go with that instead
    return max(max(len(case[0]) for case in cases), MIN_TEXT_WIDTH)

def hex_width(cases):
    # find an even number of hex digits that will fit all fields
    # unless smaller than MIN_HEX_WIDTH, then go with that instead
    return max(max(round(len("%x" % case[1]) / 2.0) * 2 for case in cases), MIN_HEX_WIDTH)

def format_field(name, typ, cmt, width):
    res = []
    ind = "/// "
    res.extend(
        textwrap.wrap(
            " ".join(cmt),
            initial_indent=ind,
            subsequent_indent=ind,
            width=LINE_WIDTH
        )
    )
    res.append("{:{width}}: {},".format(name, typ, width=width))
    return res

def format_case(name, fields, cmt):
    res = []
    if SAME_LINE_BRACES:
        res.append("%s {" % name)
    else:
        res.append(name)
        res.append("{")

    for index, field in enumerate(fields):
        if index > 0:
            res.append("")
        res.extend(indent(format_field(*field, width=text_width(fields))))
    res.append("},")
    return res

def format_packet(name, cases, cmt):
    res = []
    for index, case in enumerate(cases):
        if index > 0:
            res.append("")
        res.extend(format_case(*case))
    return "\n".join(["pub enum %s {" % name] + indent(res) + ["}", ""])

def format_enum(name, cases, cmt):
    res = []
    for index, case in enumerate(cases):
        res.append("{:{text_width}} = 0x{:0{hex_width}x},".format(case[0], case[1], text_width=text_width(cases), hex_width=hex_width(cases)))
    return "\n".join(["pub enum %s {" % name] + indent(res) + ["}", ""])

def format_struct(name, cases, cmt):
    res = []
    for index, case in enumerate(cases):
        res.append("%-20s: %s," % (case[0], case[1]))
    return "\n".join(["pub struct %s {" % name] + indent(res) + ["}", ""])

def generate(cortex, *args):
    sections = cortex.parse(fileinput.input(args))

    formatters = {
        "enum": format_enum,
        "struct": format_struct,
        "packet": format_packet,
    }

    for name, items in sections.items():
        if name not in formatters:
            print("Unknown type [%s]" % name)
            continue
        formatter = formatters[name]

        for item in items:
            print(formatter(*item))
