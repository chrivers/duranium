import fileinput
import textwrap
from pprint import pprint

SAME_LINE_BRACES = True
LINE_WIDTH = 80

def section(name):
    print(("[ %s ]" % name).center(80, "-"))

def indent(lines, amount=4):
    indentation = " " * amount
    return [indentation + line for line in lines]

def format_field(name, typ, cmt):
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
    res.append("%s: %s," % (name, typ))
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
        res.extend(indent(format_field(*field)))
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
        res.append("%-20s = 0x%08x," % (case[0], case[1]))
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
