from transwarp.template import context

##### header #####

def header():
    return \
        "// ------------------------------------------\n" \
        "// Generated by Transwarp\n" \
        "//\n" \
        "// THIS FILE IS AUTOMATICALLY GENERATED.\n" \
        "// DO NOT EDIT. ALL CHANGES WILL BE LOST.\n" \
        "// ------------------------------------------"

##### type handling #####

primitive_types = {
    "bool8", "bool16", "bool32",
    "u8", "u16", "u32", "u64",
    "i8", "i16", "i32", "i64",
    "f32", "f64",
}

ref_types = {
    "string",
    "struct",
    "ascii_string",
    "array",
    "map",
    "packet",
}

declare_map = {
    "string": "String",
    "ascii_string": "AsciiString",
}

def fullname(blk):
    return "::".join(blk.path)

def declare_struct_type(tp):
    if not tp:
        raise ValueError("Empty type")
    elif tp.name in declare_map:
        return declare_map[tp.name]
    elif tp.name in primitive_types:
        return tp.name
    elif tp.name == "array":
        return "Vec<%s>" % declare_struct_type(tp[0])
    elif tp.name == "struct":
        return "structs::%s" % tp[0].name
    elif tp.name == "enum":
        return "Size<%s, %s>" % (declare_struct_type(tp[0][0]), fullname(tp.link))
    elif tp.name == "map":
        return "EnumMap<%s, %s>" % (fullname(tp[0].link), declare_struct_type(tp[1]))
    elif tp.name == "option":
        return "Option<%s>" % declare_struct_type(tp[0])
    elif tp.link:
        return fullname(tp.link)
    else:
        raise TypeError("No type mapping defined for [%s]" % tp)

def declare_update_type(tp):
    if tp.name == "map":
        return "EnumMap<%s, Field<%s>>" % (fullname(tp[0].link), declare_struct_type(tp[1]))
    else:
        return "Field<%s>" % declare_struct_type(tp)

##### struct fields #####

def _write_struct_field(fld):
    if fld.type.name == "string":
        return "_wtr.write(self.%s.as_str())?" % fld.name
    if fld.type.name in ref_types:
        return "_wtr.write(&self.%s)?" % fld.name
    else:
        return "_wtr.write(self.%s)?" % fld.name

def write_struct_field(name, fld):
    return 'write_field!("%s", "%s", self.%s, %s);' % (
        name,
        fld.name,
        fld.name,
        _write_struct_field(fld)
    )

##### updates fields #####

def write_update_field(fld):
    if fld.type.name == "string":
        return "wtr.write(self.%s.as_str())?" % fld.name
    elif fld.type.name == "map":
        return "wtr.write(&self.%s)?" % fld.name
    else:
        return "wtr.write(self.%s)?" % fld.name

##### packets #####

def generate_packet_ids(parsername):
    res = {}
    for field in context["parsers"].get(parsername).fields:
        if field.type.name == "struct":
            res[field.type[0].name] = (field.type, field.name, None, None)
        elif field.type.name == "parser":
            prs = context["parsers"].get(field.type[0].name)
            for fld in prs.fields:
                res[fld.type[0].name] = (fld.type, field.name, fld.name, prs.expr[0])
    return sorted(res.items())
