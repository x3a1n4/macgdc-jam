class_name CalendarType

var name : String
var colour : Color

func _init(name : String, colour : Color):
	self.name = name
	self.colour = colour

const default_color = Color.BLACK

static var All_Types : Array[CalendarType] = [
	new("Error", Color.from_string("000000", default_color)),
	new("Default", Color.from_string("808080", default_color)),
	new("Eating", Color.from_string("048c61", default_color)),
	new("Sleeping", Color.from_string("182352", default_color)),
	new("Working", Color.from_string("5fa651", default_color))
]

static func names() -> Array[String] :
	var out : Array[String]
	
	for type in CalendarType.All_Types:
		out.append(type.name)
	
	return out

static func from_name(name : String) -> CalendarType :
	for type in All_Types:
		if type.name == name:
			return type
	
	return All_Types[0]
