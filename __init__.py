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

def format_comment(comment, ind = "/// "):
    return textwrap.wrap(
        comment,
        initial_indent=ind,
        subsequent_indent=ind,
        width=LINE_WIDTH
    )

def format_case(name, fields, cmt):
    res = []
    if SAME_LINE_BRACES:
        res.append("%s {" % name)
    else:
        res.append(name)
        res.append("{")

    for index, field in enumerate(fields):
        name, typ, cmt = field
        if index > 0:
            res.append("")
        res.extend(indent(format_comment(" ".join(cmt))))
        res.extend(indent(["{}: {},".format(name, typ)]))
    res.append("},")
    return res

def format_packet(pkt):
    name, cases, cmt = pkt
    res = []
    for index, case in enumerate(cases):
        if index > 0:
            res.append("")
        res.extend(format_case(*case))
    return "\n".join(["pub enum %s {" % name] + indent(res) + ["}", ""])

def format_enum(enum):
    res = []
    for index, case in enumerate(enum.fields):
        res.append("{} = {},".format(case.aligned_name, case.aligned_hex_value))
    return "\n".join(["pub enum %s {" % enum.name] + indent(res) + ["}", ""])

def format_struct(struct):
    name, cases, cmt = struct
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
            print(formatter(item))
