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
}

def declare_type(tp):
    if not tp:
        raise ValueError("Empty type")
    if is_primitive(tp):
        return primitive_map[tp.name]
    elif tp.name in ("string", "ascii_string"):
        return "String"
    elif tp.name == "sizedarray":
        return "[%s; %d]" % (declare_type(tp[0]), int(tp[1].name))
    elif tp.name == "array":
        return "Vec<%s>" % declare_type(tp[0])
    elif tp.name == "struct":
        return tp[0].name
    elif tp.name == "enum":
        return tp[1].name
    elif tp.name == "map":
        return "HashMap<%s, %s>" % (tp[0].name, declare_type(tp[1]))
    elif tp.name == "option":
        return "Option<%s>" % declare_type(tp[0])
    elif tp.name == "bitflags":
        return tp[0].name
    elif tp.name == "object":
        return "Object"
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def declare_update_type(tp):
    if not tp:
        raise ValueError("Empty type")
    elif tp.name == "sizedarray":
        type = declare_update_type(tp[0])
        return "[%s; %d]" % (type, int(tp[1].name))
    elif tp.name == "map" and tp.arg == "ShipSystem":
        return "[Option<%s>; 8]" % tp[0].name
    elif tp.name == "map" and tp.arg == "BeamFrequency":
        return "[Option<%s>; 5]" % tp[0].name
    elif tp.name == "bitflags":
        return "Option<%s>" % tp[1].name
    else:
        return "Option<%s>" % declare_type(tp)

def is_primitive(tp):
    return tp.name in primitive_map

def reader_function(tp):
    if is_primitive(tp):
        return "read_%s" % primitive_map[tp.name]
    elif tp.name == "string":
        return "read_string"
    elif tp.name == "enum" and tp[0].name == "u8":
        return "read_enum8"
    elif tp.name == "enum" and tp[0].name == "u32":
        return "read_enum32"
    else:
        raise TypeError("No reader function for [%r]" % tp)

def writer_function(tp):
    if is_primitive(tp):
        return "write_%s" % primitive_map[tp.name]
    elif tp.name == "string":
        return "write_string"
    elif tp.name == "enum" and tp[0].name == "u8":
        return "write_enum8"
    elif tp.name == "enum" and tp[0].name == "u32":
        return "write_enum32"
    else:
        raise TypeError("No writer function for [%r]" % tp)
