primitive_map = {
    "u8": "u8",
    "u16": "u16",
    "u32": "u32",
    "u64": "u64",

    "i8": "i8",
    "i16": "i16",
    "i32": "i32",

    "f32": "f32",

    "bool8": "bool",
    "bool16": "bool",
    "bool32": "bool",

    "string": "String",
    "ascii_string": "String",
}

def rust_type(tp):
    if not tp:
        raise ValueError("Empty type")
    if tp.name in primitive_map:
        return primitive_map[tp.name]
    elif tp.name == "sizedarray":
        type = rust_type(tp[0])
        return "[%s; %d]" % (type, int(tp[1].name))
    elif tp.name == "array":
        return "Vec<%s>" % (rust_type(tp[0]))
    elif tp.name == "struct":
        return tp[0].name
    elif tp.name == "enum":
        return tp[1].name
    elif tp.name == "map":
        return "HashMap<%s, %s>" % (tp[0].name, rust_type(tp[1]))
    elif tp.name == "option":
        return "Option<%s>" % rust_type(tp[0])
    elif tp.name == "bitflags":
        return tp[0].name
    elif tp.name == "object":
        return "Object"
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def update_type(tp):
    if not tp:
        raise ValueError("Empty type")
    if is_primitive(tp):
        return "Option<%s>" % primitive_map[tp.name]
    elif tp.name == "sizedarray":
        type = update_type(tp[0])
        return "[%s; %d]" % (type, int(tp[1].name))
    elif tp.name == "enum":
        return "Option<%s>" % (tp[1].name)
    elif tp.name == "map" and tp.arg == "ShipSystem":
        return "[Option<%s>; 8]" % tp[0].name
    elif tp.name == "map" and tp.arg == "BeamFrequency":
        return "[Option<%s>; 5]" % tp[0].name
    elif tp.name == "bitflags":
        return "Option<%s>" % tp[1].name
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def is_primitive(tp):
    return tp.name in primitive_map
