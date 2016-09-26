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
}

def rust_type(tp):
    if not tp:
        raise ValueError("Empty type")
    if tp.name in primitive_map:
        return primitive_map[tp.name]
    elif tp.name == "sizedarray":
        type = rust_type(tp.target)
        return "[%s; %d]" % (type, tp.arg)
    elif tp.name == "array":
        return "Vec<%s>" % (rust_type(tp.target))
    elif tp.name == "struct":
        return tp.arg
    elif tp.name in ("enum8", "enum32"):
        return tp.target.name
    elif tp.name == "map":
        return "HashMap<%s, %s>" % (tp.arg, rust_type(tp.target))
    elif tp.name == "option":
        return "Option<%s>" % rust_type(tp.target)
    elif tp.name == "bitflags":
        return "u32"
    elif tp.name == "Object":
        return "Object"
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def object_type(tp):
    if not tp:
        raise ValueError("Empty type")
    if tp.name in primitive_map:
        return primitive_map[tp.name]
    elif tp.name == "sizedarray":
        type = object_type(tp.target)
        return "[%s; %d]" % (type, tp.arg)
    elif tp.name in ("enum8", "enum32"):
        if tp.target.name == "OrdnanceType":
            return "[%s try %s]" % (tp.target.name, tp.name)
        else:
            return "[%s is %s]" % (tp.target.name, tp.name)
    elif tp.name == "map" and tp.arg == "ShipSystem":
        return "[%s; 8]" % tp.target.name
    elif tp.name == "map" and tp.arg == "BeamFrequency":
        return "[%s; 5]" % tp.target.name
    elif tp.name == "bitflags":
        return "[%s is bitflags_u32]" % tp.arg
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def update_type(tp):
    if not tp:
        raise ValueError("Empty type")
    if is_primitive(tp):
        return "Option<%s>" % primitive_map[tp.name]
    elif tp.name == "sizedarray":
        type = update_type(tp.target)
        return "[%s; %d]" % (type, tp.arg)
    elif tp.name in ("enum8", "enum32"):
        return "Option<%s>" % (tp.target.name)
    elif tp.name == "map" and tp.arg == "ShipSystem":
        return "[Option<%s>; 8]" % tp.target.name
    elif tp.name == "map" and tp.arg == "BeamFrequency":
        return "[Option<%s>; 5]" % tp.target.name
    elif tp.name == "bitflags":
        return "Option<%s>" % tp.arg
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def is_primitive(tp):
    return tp.name in primitive_map

def is_simple(tp):
    return is_primitive(tp) or tp.name in ("enum8", "enum32")
