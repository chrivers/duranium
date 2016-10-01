primitive_map = {
    "u8": "u8",
    "u16": "u16",
    "u32": "u32",
    "u64": "u64",

    "i8": "i8",
    "i16": "i16",
    "i32": "i32",

    "f32": "f32",

    "bool8": "bool8",
    "bool16": "bool16",
    "bool32": "bool32",
}

def declare_type(tp):
    if not tp:
        raise ValueError("Empty type")
    elif tp.name in ("bool8", "bool16", "bool32"):
        return "bool"
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
        return tp[1].name
    elif tp.name == "object":
        return "Object"
    elif is_primitive(tp):
        return primitive_map[tp.name]
    else:
        raise TypeError("No type mapping defined for [%s]" % tp.name)

def declare_update_type(tp):
    if not tp:
        raise ValueError("Empty type")
    elif tp.name == "sizedarray":
        return "[%s; %d]" % (declare_update_type(tp[0]), int(tp[1].name))
    else:
        return "Option<%s>" % declare_type(tp)

def is_primitive(tp):
    return tp.name in primitive_map

def reader_function(tp):
    if is_primitive(tp):
        return "read_%s" % primitive_map[tp.name]
    elif tp.name in "string":
        return "read_string"
    elif tp.name in "ascii_string":
        return "read_ascii_string"
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
    elif tp.name == "ascii_string":
        return "write_ascii_string"
    elif tp.name == "enum" and tp[0].name == "u8":
        return "write_enum8"
    elif tp.name == "enum" and tp[0].name == "u32":
        return "write_enum32"
    else:
        raise TypeError("No writer function for [%r]" % tp)

def read_struct_field(type):
    return "try!(rdr.%s())" % reader_function(type)

def read_struct_field_parse(type):
    if type.name in ("struct", "map"):
        return "try_parse!(rdr.read_item())"
    elif type.name == "array" and type[0] and type[0].name == "struct" and type[0][0].name == "ObjectUpdate":
        return "try_subparse!(read_frame_stream(buffer, &mut rdr))"
    elif type.name == "array":
        if type[1]:
            if len(type[1].name) <= 4:
                return "try_parse!(rdr.read_array_u8(%s))" % (type[1].name)
            else:
                return "try_parse!(rdr.read_array_u32(%s))" % (type[1].name)
        else:
            return "try_parse!(rdr.read_array())"
    elif type.name in ("bool8", "bool16", "bool32"):
        return "try_parse!(rdr.read_%s())" % type.name
    elif type.name == "option":
        if type[0] and type[0].name == "enum" and type[0][1].name == "ConsoleType":
            return "{ match try_parse!(rdr.read_u32()) { 0 => None, n => Some(try_enum!(ConsoleType, n - 1)) } }"
        elif type[0] and type[0].name == "string":
            return "rdr.read_string().ok()"
    elif type.name == "sizedarray":
        return "[ %s ]" % (", ".join([(read_struct_field_parse(type[0]))] * int(type[1].name)))
    else:
        return "try_parse!(rdr.%s())" % reader_function(type)

def write_struct_field(name, type):
    if type.name == "string":
        return "try!(wtr.%s(&%s))" % (writer_function(type), name)
    else:
        return "try!(wtr.%s(%s))" % (writer_function(type), name)

def write_field(name, fld, type):
    ## special cases
    if name == "ServerPacket::ConsoleStatus" and fld.name == "console_status":
        return "for console in ConsoleType::iter_enum() { try!(wtr.write_enum8(*console_status.get(&console).unwrap_or(&ConsoleStatus::Available))); }"
    elif name == "ClientPacket::GameMasterMessage" and fld.name == "console_type":
        return "try!(wtr.write_u32(console_type.map_or(0, |ct| ct as u32 + 1)))"
    ## ordinary cases
    elif type.name == "sizedarray" or (type.name == "array" and len(type._args) == 1):
        return "try!(wtr.write_array(%s))" % fld.name
    elif type.name == "array" and len(type._args) == 2:
        if len(type[1].name) <= 4:
            return "try!(wtr.write_array_u8(%s, %s))" % (fld.name, type[1].name)
        else:
            return "try!(wtr.write_array_u32(%s, %s))" % (fld.name, type[1].name)
    elif type.name == "option":
        return "try!(wtr.write_option(%s))" % fld.name
    elif type.name in ("struct", "map"):
        return "try!(%s.write(&mut wtr))" % (fld.name)
    elif type.name == "enum":
        if type[0].name == "u8":
            return "try!(wtr.write_enum8(%s))" % (fld.name)
        elif type[0].name == "u32":
            return "try!(wtr.write_enum32(%s))" % (fld.name)
    else:
        return "try!(wtr.%s(%s))" % (writer_function(type), fld.name)

def read_update_field(rdr, mask, object, field, type):
    if type.name == "enum" and type[1].name == "OrdnanceType":
        return "try_update_parse_opt!(%s, %s, OrdnanceType)" % (mask, rdr)
    elif type.name == "bitflags":
        return "try_update_parse!(%s, %s.read_item())" % (mask, rdr)
    elif type.name == "sizedarray":
        rep = int(type[1].name)
        return "[ %s ]" % ", ".join([read_update_field(rdr, mask, object, field, type[0])] * rep)
    else:
        return "try_update_parse!(%s, %s.%s())" % (mask, rdr, reader_function(type))

def write_update_field(wtr, mask, fieldname, type):
    if type.name == "string":
        return "write_single_field!(%s.as_ref(), %s, %s, write_string)" % (fieldname, wtr, mask)
    elif type.name == "bitflags":
        return "write_single_field!(%s.map(|v| v.bits()), %s, %s, write_u32)" % (fieldname, wtr, mask)
    elif type.name == "sizedarray":
        return "for _elem in %s.iter() { %s }" % (fieldname, write_update_field(wtr, mask, "*_elem", type[0]))
    else:
        return "write_single_field!(%s, %s, %s, %s)" % (fieldname, wtr, mask, writer_function(type))
