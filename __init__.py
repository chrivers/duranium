from pprint import pprint

SAME_LINE_BRACES = True

def section(name):
    print(("[ %s ]" % name).center(80, "-"))

def indent(lines, amount=4):
    indentation = " " * amount
    return [indentation + line for line in lines]

def format_field(name, typ, cmt):
    res = []
    for line in cmt:
        res.append("/// %s" % line)
    res.append("%s: %s," % (name, typ))
    return res

def format_case(name, fields):
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

def format_packet(name, cases):
    res = []
    for index, case in enumerate(cases):
        if index > 0:
            res.append("")
        res.extend(format_case(*case))
    return "\n".join(["pub enum %s {" % name] + indent(res) + ["}"])

def generate(cortex, *args):
    assert len(args) == 1
    template = args[0]

    sections = cortex.organize(cortex.parse(open(template, "r")))
    enums, packets, structs = [], [], []
    for header, lines, comment in sections.get("packet", []):
        packets.append(cortex.parse_packet(header, lines))

    for packet in packets:
        print(format_packet(*packet))
