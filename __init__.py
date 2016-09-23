def section(name):
    print(("[ %s ]" % name).center(80, "-"))

def generate(cortex, *args):
    assert len(args) == 1
    template = args[0]

    sections = cortex.organize(cortex.parse(open(template, "r")))
    enums, packets, structs = [], [], []
    for typ, items in sections.items():
        # print("Parsing [%s] section.." % typ)
        if typ == "enum":
            for header, lines, comment in items:
                enums.append(cortex.parse_enum(header, lines))
        elif typ == "packet":
            for header, lines, comment in items:
                print(cortex.parse_packet(header, lines))
                packets.append(cortex.parse_packet(header, lines))
        elif typ == "struct":
            for header, lines, comment in items:
                structs.append(cortex.parse_struct(header, lines))
        elif typ == "flags":
            pass
        else:
            print("Unknown section type [%s]" % typ)
    # print(packets)
