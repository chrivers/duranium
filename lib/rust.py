from transwarp.template import context

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
    elif tp.name in primitive_map:
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

def reader_function(tp):
    if tp.name in primitive_map:
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
    if tp.name in primitive_map:
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
        return "try_parse!(rdr.read())"
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

def write_field(objname, fieldname, type):
    ## special cases
    if objname == "ServerPacket::ConsoleStatus" and fieldname == "console_status":
        return "for console in ConsoleType::iter_enum() { try!(wtr.write_enum8(*console_status.get(&console).unwrap_or(&ConsoleStatus::Available))); }"
    elif objname == "ClientPacket::GameMasterMessage" and fieldname == "console_type":
        return "try!(wtr.write_u32(console_type.map_or(0, |ct| ct.to_u32().unwrap_or(0) + 1)))"
    ## ordinary cases
    elif type.name == "sizedarray" or (type.name == "array" and len(type._args) == 1):
        return "try!(wtr.write_array(%s))" % fieldname
    elif type.name == "string" and objname == None:
        return write_field(True, "&" + fieldname, type)
    elif type.name == "array" and len(type._args) == 2:
        if len(type[1].name) <= 4:
            return "try!(wtr.write_array_u8(%s, %s))" % (fieldname, type[1].name)
        else:
            return "try!(wtr.write_array_u32(%s, %s))" % (fieldname, type[1].name)
    elif type.name == "option":
        return "try!(wtr.write_option(%s))" % fieldname
    elif type.name in ("struct", "map"):
        return "try!(%s.write(&mut wtr))" % (fieldname)
    elif type.name == "enum":
        if type[0].name == "u8":
            return "try!(wtr.write_enum8(%s))" % (fieldname)
        elif type[0].name == "u32":
            return "try!(wtr.write_enum32(%s))" % (fieldname)
    else:
        return "try!(wtr.%s(%s))" % (writer_function(type), fieldname)

def read_update_field(rdr, mask, object, field, type):
    if type.name == "enum" and type[1].name == "OrdnanceType":
        return "try_update_parse_opt!(%s, %s, OrdnanceType)" % (mask, rdr)
    elif type.name == "bitflags":
        return "try_update_parse!(%s, %s.read())" % (mask, rdr)
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

def get_packet(name):
    packets = context["packets"]
    if "::" in name:
        packetname, casename = name.split("::",1)
        return packets.get(packetname).fields.get(casename)
    else:
        return packets.get(name)

def get_parser(name):
    return context["parsers"].get(name)
