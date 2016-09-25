def rust_type(tp):
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
    elif tp.name == "array":
        return "array"
    elif tp.name in ("enum8", "enum32"):
        return tp.args
    elif tp.name.startswith("Option"):
        return tp.args
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)
