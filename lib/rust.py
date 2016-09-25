def rust_type(name):
    if name in ("u8", "u16", "u32", "i8", "i16", "i32", "f32"):
        return name
    elif name.startswith("bool"):
        return "bool"
    elif name == "string":
        return "String"
    elif name.startswith("array"):
        return "array"
    elif name.startswith("fixedarray"):
        return "array"
    elif name.startswith("enum"):
        return name.split("<")[1][:-1]
    elif name.startswith("Option"):
        return name
    else:
        raise TypeError("No type mapping defined for [%s]" % name)
