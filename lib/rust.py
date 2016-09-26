def rust_type(tp):
    if not tp:
        raise ValueError("Empty type")
    primitive_map = {
        "u8": "u8",
        "u16": "u16",
        "u32": "u32",

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
        return "HashMap<%s, %s>" % (rust_type(tp.target), tp.arg)
    elif tp.name == "option":
        return "Option<%s>" % rust_type(tp.target)
    elif tp.name:
        return "Object"
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)
